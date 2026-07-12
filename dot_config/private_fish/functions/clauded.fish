function clauded --wraps='claude --dangerously-skip-permissions' --description 'Launch Claude Code with permission prompts disabled'
    claude --dangerously-skip-permissions $argv
end
