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

function n --wraps nnn --description 'support nnn quit and change directory'
    # Block nesting of nnn in subshells
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo "nnn is already running"
        return
    end

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "-x" from both lines below,
    # without changing the paths.
    if test -n "$XDG_CONFIG_HOME"
        set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
    else
        set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
    end

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command function allows one to alias this function to `nnn` without
    # making an infinitely recursive alias
    command nnn $argv

    if test -e $NNN_TMPFILE
        source $NNN_TMPFILE
        rm -- $NNN_TMPFILE
    end
end
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
