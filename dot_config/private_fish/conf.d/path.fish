# PATH and OS-specific environment. Owned by chezmoi; safe on macOS + Linux.
#
# `fish_add_path -gP` writes directly to $PATH (global scope), so nothing is
# persisted to the universal `fish_variables` store — PATH is recomputed fresh
# on every shell start. That means this file is the single source of truth and
# there's no machine-local state to leak between the Mac and the Debian VM.
#
# Portable tool paths are added only when the directory exists on THIS machine,
# so a tool that's absent on one host simply isn't added.

for dir in \
    $HOME/.cargo/bin \
    $HOME/.local/bin \
    $HOME/.local/share/uv/python/bin \
    $HOME/go/bin \
    $HOME/.bun/bin
    test -d $dir; and fish_add_path -gP $dir
end

# pnpm: same tool, OS-specific home directory.
switch (uname)
    case Darwin
        set -gx PNPM_HOME "$HOME/Library/pnpm"
    case '*'
        set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
test -d $PNPM_HOME; and fish_add_path -gP $PNPM_HOME $PNPM_HOME/bin

# macOS-only: Homebrew and tools installed under it.
if test (uname) = Darwin
    for dir in \
        /opt/homebrew/bin \
        /opt/homebrew/opt/openjdk@21/bin \
        /opt/homebrew/opt/libpq/bin \
        $HOME/Projects/Flutter/flutter/bin \
        $HOME/.antigravity/antigravity/bin
        test -d $dir; and fish_add_path -gP $dir
    end

    if test -d /opt/homebrew/opt/openjdk@21
        set -gx JAVA_HOME /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
    end

    if test -d $HOME/.pyenv
        set -gx PYENV_ROOT $HOME/.pyenv
        fish_add_path -gP $PYENV_ROOT/bin
    end
end
