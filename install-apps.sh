# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# Install packages
# System utils
brew install hub zsh-syntax-highlighting diff-so-fancy tig autojump exa
npm install --global prettier yarn
# Apps
brew cask install visual-studio-code google-chrome iterm2

# Install ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
