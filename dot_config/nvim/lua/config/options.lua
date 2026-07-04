local opt = vim.opt

opt.number = true            -- Show line numbers
opt.relativenumber = true    -- Relative line numbers for easier jumps
opt.tabstop = 4              -- Number of spaces a tab counts for
opt.shiftwidth = 4           -- Number of spaces for auto-indent
opt.expandtab = true         -- Turn tabs into spaces
opt.smartindent = true       -- Smart auto-indenting
opt.wrap = false             -- Disable line wrapping
opt.ignorecase = true        -- Case-insensitive searching
opt.smartcase = true         -- Case-sensitive if capitals are typed
opt.termguicolors = true     -- True color support
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.splitright = true        -- Vertical splits open to the right
opt.splitbelow = true        -- Horizontal splits open below

