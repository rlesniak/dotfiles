{
  description = "Rafal's macOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs }: {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ ./nix/darwin.nix ];
      specialArgs = {
        username = let u = builtins.getEnv "NIX_USER"; in
          if u != "" then u
          else throw "NIX_USER is not set.";
      };
    };
  };
}