# Dotfiles

> My dotfiles and new machine configurations

## Installation

Warning: This might not be for you. If you'd like to try it, you should make a fork, review carefully, and remove anything that doesn't apply.

### MacOS configurations

```bash
defaults write -g ApplePressAndHoldEnabled -bool false
```

### Install homebrew

Follow the instructions [here](https://brew.sh/)

### Clone dotfile repo

```bash
cd ~
git clone https://github.com/skaragianis/dotfiles.git
cp ~/dotfiles .
```

### Install cli, cask and appstore applications

```bash
brew bundle
```

### Configure battery management

Go and install <https://github.com/mhaeuser/Battery-Toolkit>

### Configure fish (using Oh My Fish)

```bash
fish
fish_add_path /opt/homebrew/bin
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
omf install bobthefish
```

And add the following to config.fish

```bash
pyenv init - | source
```

### Configure nodejs (using nvm)

```fish
omf install nvm
nvm install --lts
npm install -g yarn
```

### Configure python (using pyenv)

```fish
set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
```

Now, add this to `~/.config/fish/config.fish`:

```fish
pyenv init - | source
```

### Random MacOS settings

Turn off System Settings / Keyboard / Languages / Add full stop with double-space. This otherwise messes with vim and using \<space\> as leader for easymotion.
