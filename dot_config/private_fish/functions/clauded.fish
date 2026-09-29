function clauded --wraps='claude --dangerously-skip-permissions' --description 'Launch Claude Code with permission prompts disabled'
    command ~/.local/bin/claude --dangerously-skip-permissions $argv
end
