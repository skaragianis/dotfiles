local opt = vim.opt

opt.autoindent = true
opt.autoread = true
opt.breakindent = true
opt.clipboard = "unnamedplus"

-- Over SSH / inside herdr on a headless box there's no system clipboard;
-- send yanks to the local terminal via OSC 52 instead.
local headless_linux = vim.fn.has("linux") == 1
  and not vim.env.DISPLAY
  and not vim.env.WAYLAND_DISPLAY
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or headless_linux then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- herdr doesn't pass OSC 52 reads back, so share yanks between Neovim
  -- instances on this host via a file. Paste from the host with Cmd+V.
  local clip_file = vim.fn.stdpath("state") .. "/clipboard.json"

  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      send(lines, regtype)
      local fd = vim.uv.fs_open(clip_file, "w", tonumber("600", 8))
      if fd then
        vim.uv.fs_write(fd, vim.json.encode({ lines = lines, regtype = regtype }))
        vim.uv.fs_close(fd)
      end
    end
  end

  local function paste()
    local ok, clip = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(clip_file), "\n"))
    end)
    if ok and type(clip) == "table" and clip.lines then
      return { clip.lines, clip.regtype }
    end
    return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end

  vim.g.clipboard = {
    name = "OSC 52 + shared file",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
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
opt.tabstop = 4
opt.termguicolors = true
opt.undofile = true
opt.wrap = false

vim.g.mapleader = " " -- Set spacebar as leader key

vim.g.netrw_liststyle = 3

-- rustfmt's default max_width
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.colorcolumn = "100"
  end,
})
