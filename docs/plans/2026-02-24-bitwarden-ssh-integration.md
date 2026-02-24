# Bitwarden SSH Keys Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Zautomatyzować pobieranie kluczy SSH z Bitwarden podczas `chezmoi apply`, eliminując ręczny transfer AirDrop.

**Architecture:** Klucze SSH przechowywane jako Secure Notes w Bitwarden. chezmoi używa `.chezmoiexternal.toml.tmpl` z wywołaniami `bw get notes <id>` do pobrania zawartości kluczy i zapisania ich na dysk z permissions 0600. `bootstrap.sh` instaluje `bitwarden-cli` i obsługuje logowanie przed `chezmoi apply`.

**Tech Stack:** chezmoi (external files), Bitwarden CLI (`bw`), bash

---

### Task 1: Wgraj klucze SSH do Bitwarden

To jest krok manualny — wykonaj go przed implementacją reszty.

**Step 1: Zainstaluj Bitwarden CLI**

```bash
brew install bitwarden-cli
```

**Step 2: Zaloguj się**

```bash
bw login
```
Wpisz email i master password. Zapisz zwrócony session token:
```bash
export BW_SESSION="<token zwrócony przez bw login>"
```

**Step 3: Wgraj klucz prywatny id_ed25519 jako Secure Note**

```bash
bw get template item | \
  python3 -c "
import sys, json
t = json.load(sys.stdin)
t['type'] = 2  # SecureNote
t['name'] = 'SSH Key: id_ed25519'
t['notes'] = open('/Users/rafal/.ssh/id_ed25519').read()
t['secureNote'] = {'type': 0}
print(json.dumps(t))
" | bw encode | bw create item
```

Zanotuj `id` z outputu (np. `"id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`).

**Step 4: Wgraj klucz prywatny id_rsa_akiro jako Secure Note**

```bash
bw get template item | \
  python3 -c "
import sys, json
t = json.load(sys.stdin)
t['type'] = 2
t['name'] = 'SSH Key: id_rsa_akiro'
t['notes'] = open('/Users/rafal/.ssh/id_rsa_akiro').read()
t['secureNote'] = {'type': 0}
print(json.dumps(t))
" | bw encode | bw create item
```

Zanotuj `id`.

**Step 5: Zweryfikuj że oba klucze są w Bitwarden**

```bash
bw list items --search "SSH Key" | python3 -c "import sys,json; [print(i['id'], i['name']) for i in json.load(sys.stdin)]"
```

Powinieneś zobaczyć dwie pozycje z ich ID. **Zapisz oba ID** — potrzebne w Task 2.

---

### Task 2: Dodaj `.chezmoiexternal.toml.tmpl`

**Files:**
- Create: `~/workspace/dotfiles/.chezmoiexternal.toml.tmpl`

**Step 1: Stwórz plik**

Zastąp `<ID_ED25519>` i `<ID_RSA_AKIRO>` faktycznymi ID z Bitwarden (z Task 1).

```toml
{{- if (output "bw" "status" | fromJson).status | eq "unlocked" -}}

[".ssh/id_ed25519"]
    type = "file"
    executable = false
    encrypted = false
    [".ssh/id_ed25519".contents]
        command = "bw"
        args = ["get", "notes", "<ID_ED25519>"]

[".ssh/id_rsa_akiro"]
    type = "file"
    executable = false
    encrypted = false
    [".ssh/id_rsa_akiro".contents]
        command = "bw"
        args = ["get", "notes", "<ID_RSA_AKIRO>"]

{{- end -}}
```

Uwaga na `{{- if ... -}}` — chezmoi renderuje ten plik jako Go template. Blok `if` sprawdza czy Bitwarden jest odblokowany przed próbą pobierania kluczy. Jeśli `bw` nie jest odblokowany, plik zewnętrzny jest ignorowany (klucze nie są pobierane).

**Step 2: Sprawdź że chezmoi parsuje template bez błędów**

```bash
chezmoi execute-template < ~/workspace/dotfiles/.chezmoiexternal.toml.tmpl
```

Jeśli `bw` jest odblokowany (z poprzedniego Task), powinien wypisać TOML z dwoma sekcjami. Jeśli nie jest odblokowany — pusty output (to jest ok).

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add .chezmoiexternal.toml.tmpl
git commit -m "feat: add bitwarden ssh key integration via chezmoi external"
```

---

### Task 3: Ustaw permissions SSH przez `.chezmoiexternal.toml.tmpl`

Pliki pobrane przez `chezmoiexternal` domyślnie mają permissions 0644. Klucze SSH muszą mieć 0600, inaczej SSH odmówi ich użycia.

**Step 1: Zaktualizuj `.chezmoiexternal.toml.tmpl`**

Dodaj `permissions` do obu wpisów:

```toml
{{- if (output "bw" "status" | fromJson).status | eq "unlocked" -}}

[".ssh/id_ed25519"]
    type = "file"
    permissions = 0600
    [".ssh/id_ed25519".contents]
        command = "bw"
        args = ["get", "notes", "<ID_ED25519>"]

[".ssh/id_rsa_akiro"]
    type = "file"
    permissions = 0600
    [".ssh/id_rsa_akiro".contents]
        command = "bw"
        args = ["get", "notes", "<ID_RSA_AKIRO>"]

{{- end -}}
```

(Usuń `executable = false` i `encrypted = false` — to są domyślne wartości, niepotrzebne.)

**Step 2: Zweryfikuj że chezmoi widzi klucze jako external**

```bash
chezmoi list --include=externals
```

Powinno wyświetlić `~/.ssh/id_ed25519` i `~/.ssh/id_rsa_akiro`.

**Step 3: Testowo pobierz klucze (dry-run)**

```bash
chezmoi apply --dry-run --verbose ~/.ssh/id_ed25519
```

Powinno pokazać że chezmoi chce zapisać plik do `~/.ssh/id_ed25519`.

**Step 4: Aplikuj klucze**

```bash
chezmoi apply ~/.ssh/id_ed25519 ~/.ssh/id_rsa_akiro
```

**Step 5: Zweryfikuj permissions**

```bash
ls -la ~/.ssh/id_ed25519 ~/.ssh/id_rsa_akiro
```

Oba powinny mieć `-rw-------` (0600).

**Step 6: Zweryfikuj zawartość (pierwsze 2 linie)**

```bash
head -2 ~/.ssh/id_ed25519
head -2 ~/.ssh/id_rsa_akiro
```

Powinny zaczynać się od `-----BEGIN OPENSSH PRIVATE KEY-----` lub `-----BEGIN RSA PRIVATE KEY-----`.

**Step 7: Commit**

```bash
cd ~/workspace/dotfiles
git add .chezmoiexternal.toml.tmpl
git commit -m "fix: set 0600 permissions on ssh keys from bitwarden"
```

---

### Task 4: Dodaj `bitwarden-cli` do Brewfile

**Files:**
- Modify: `~/workspace/dotfiles/Brewfile`

**Step 1: Dodaj `bitwarden-cli` do sekcji CLI tools w Brewfile**

Po linii `brew "bat"` dodaj:
```ruby
brew "bitwarden-cli"
```

**Step 2: Zweryfikuj że formula istnieje**

```bash
brew info bitwarden-cli | head -3
```

Powinno wyświetlić info o paczce.

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add Brewfile
git commit -m "feat: add bitwarden-cli to Brewfile"
```

---

### Task 5: Zaktualizuj `bootstrap.sh` o logowanie do Bitwarden

**Files:**
- Modify: `~/workspace/dotfiles/bootstrap.sh`

Dodaj krok logowania do Bitwarden **przed** `chezmoi init --apply`.

**Step 1: Dodaj sekcję Bitwarden po kroku 3 (chezmoi install)**

Znajdź linię:
```bash
# 4. Clone dotfiles i apply
echo "==> Applying dotfiles..."
chezmoi init --apply https://github.com/rlesniak/dotfiles.git
```

Zastąp całą sekcję 4 na:

```bash
# 4. Bitwarden — unlock for SSH key retrieval
if ! command -v bw &>/dev/null; then
  echo "==> Installing Bitwarden CLI..."
  brew install bitwarden-cli
fi

BW_STATUS="$(bw status 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unauthenticated'))" 2>/dev/null || echo "unauthenticated")"

if [ "$BW_STATUS" = "unauthenticated" ]; then
  echo "==> Logging into Bitwarden..."
  BW_SESSION="$(bw login --raw)"
  export BW_SESSION
elif [ "$BW_STATUS" = "locked" ]; then
  echo "==> Unlocking Bitwarden..."
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
else
  echo "==> Bitwarden already unlocked."
fi

# 5. Clone dotfiles i apply (includes SSH key retrieval from Bitwarden)
echo "==> Applying dotfiles..."
chezmoi init --apply https://github.com/rlesniak/dotfiles.git
```

**Step 2: Zaktualizuj numery kroków** (stary krok 4 → 5, 5 → 6, itd.)

**Step 3: Zaktualizuj końcowy komunikat** — usuń wzmiankę o ręcznym transferze SSH:

Znajdź:
```bash
echo "  1. Przenieś klucze SSH przez AirDrop: ~/.ssh/id_ed25519 i ~/.ssh/id_rsa_akiro"
```

Zastąp:
```bash
echo "  1. Klucze SSH pobrane automatycznie z Bitwarden."
```

**Step 4: Zweryfikuj składnię**

```bash
bash -n ~/workspace/dotfiles/bootstrap.sh
```

Brak błędów.

**Step 5: Commit**

```bash
cd ~/workspace/dotfiles
git add bootstrap.sh
git commit -m "feat: add bitwarden unlock step to bootstrap"
```

---

### Task 6: Zaktualizuj README

**Files:**
- Modify: `~/workspace/dotfiles/README.md`

**Step 1: Zaktualizuj sekcję "Po bootstrapie"**

Znajdź:
```markdown
1. Przenieś klucze SSH przez AirDrop: `~/.ssh/id_ed25519`, `~/.ssh/id_rsa_akiro`
```

Zastąp:
```markdown
1. Klucze SSH pobierane automatycznie z Bitwarden podczas bootstrap.
```

**Step 2: Dodaj sekcję "Bitwarden" do README**

Po sekcji "## Bootstrap na nowym Macu" dodaj:

```markdown
## Bitwarden — SSH keys

Klucze SSH przechowywane jako Secure Notes w Bitwarden:
- `SSH Key: id_ed25519` — klucz prywatny dla osobistego GitHub
- `SSH Key: id_rsa_akiro` — klucz prywatny dla firmowego GitHub

Podczas bootstrap skrypt automatycznie pyta o Bitwarden master password i pobiera klucze przez `bw get notes`. Klucze zapisywane do `~/.ssh/` z permissions 0600.

Aby ręcznie odświeżyć klucze:
```bash
export BW_SESSION="$(bw unlock --raw)"
chezmoi apply ~/.ssh/id_ed25519 ~/.ssh/id_rsa_akiro
```
```

**Step 3: Commit i push**

```bash
cd ~/workspace/dotfiles
git add README.md
git commit -m "docs: update README for bitwarden ssh key integration"
git push
```

---

### Task 7: Weryfikacja końcowa

**Step 1: Sprawdź strukturę nowych plików**

```bash
ls -la ~/workspace/dotfiles/.chezmoiexternal.toml.tmpl
```

**Step 2: Sprawdź że chezmoi list pokazuje external files**

```bash
chezmoi list --include=externals
```

Oczekiwany output:
```
/Users/rafal/.ssh/id_ed25519
/Users/rafal/.ssh/id_rsa_akiro
```

**Step 3: Sprawdź git log**

```bash
cd ~/workspace/dotfiles && git log --oneline -7
```

Oczekiwane commity:
```
feat: add bitwarden ssh key integration via chezmoi external
fix: set 0600 permissions on ssh keys from bitwarden
feat: add bitwarden-cli to Brewfile
feat: add bitwarden unlock step to bootstrap
docs: update README for bitwarden ssh key integration
```

**Step 4: Test SSH połączenia**

```bash
ssh -T git@github.com 2>&1
```

Oczekiwany output: `Hi rlesniak! You've successfully authenticated...`

**Step 5: Sprawdź że klucz firmowy też działa**

```bash
ssh -T akiro 2>&1
```

Oczekiwany output: `Hi <company-user>! You've successfully authenticated...`
