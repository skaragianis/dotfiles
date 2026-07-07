local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.mouse = "a"
opt.showmode = false
opt.signcolumn = "yes"
opt.scrolloff = 10
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.g.mapleader = " " -- Set spacebar as leader key

vim.g.netrw_liststyle = 3

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
