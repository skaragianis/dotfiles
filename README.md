# Dotfiles

> My dotfiles and new machine configurations

## Installation

Warning: This might not be for you. If you'd like to try it, you should make a fork, review carefully, and remove anything that doesn't apply.

### MacOS configurations

``` bash
defaults write -g ApplePressAndHoldEnabled -bool false
```

### Install Homebrew

Follwing the instructions [here](https://brew.sh/)

### Clone dotfile repo

``` bash
cd ~
git clone https://github.com/skaragianis/dotfiles.git
cp ~/dotfiles .
```

### Install cli, cask and appstore applications

``` bash
brew bundle
```

### Configure fish (using Oh My Fish)

``` bash
fish
fish_add_path /opt/homebrew/bin
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
omf install bobthefish
```

### Configure iterm2

Change the font of the default profile text to `hack nerd font mono`

### Configure nodejs (using nvm)

``` fish
omf install nvm
```

### Configure python (using pyenv)

``` fish
set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
```

Now, add this to `~/.config/fish/config.fish`:

``` fish
pyenv init - | source
```
