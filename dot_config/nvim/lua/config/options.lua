local opt = vim.opt

opt.autoindent = true
opt.autoread = true
opt.breakindent = true
opt.clipboard = "unnamedplus"
opt.colorcolumn = "79"
opt.cursorline = true
opt.expandtab = true
opt.ignorecase = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"
opt.mousemodel = "popup_setpos"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 10
opt.shiftwidth = 2
opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smarttab = true
opt.softtabstop = 2
opt.spell = true
opt.spelllang = "en_au"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.undofile = true
opt.wrap = false

vim.g.mapleader = " " -- Set spacebar as leader key

vim.g.netrw_liststyle = 3
