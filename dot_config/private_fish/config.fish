if status is-interactive
    # Commands to run in interactive sessions can go here
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

set -gx EDITOR nvim
set -gx VISUAL nvim

zoxide init fish | source

# PATH / PNPM_HOME / OS-specific env now live in conf.d/path.fish so they
# stay machine-correct on both macOS and Linux. Don't add path exports here.
