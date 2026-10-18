local opt = vim.opt

opt.autoindent = true
opt.autoread = true
opt.breakindent = true
opt.clipboard = "unnamedplus"

-- Over SSH / inside tmux on a headless box there's no system clipboard;
-- send yanks to the local terminal via OSC 52 instead.
local headless_linux = vim.fn.has("linux") == 1
    and not vim.env.DISPLAY
    and not vim.env.WAYLAND_DISPLAY
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or headless_linux then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- OSC 52 reads don't come back, so inside tmux the newest tmux buffer is
  -- the clipboard shared with every other program in tmux. A file keeps the
  -- last yank too: it remembers whether it was linewise, and it is the
  -- clipboard between Neovim instances outside tmux. Paste from the host
  -- with Cmd+V.
  local clip_file = vim.fn.stdpath("state") .. "/clipboard.json"
  local in_tmux = vim.env.TMUX ~= nil

  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      if in_tmux then
        -- Waited for, so a paste right after the yank reads this buffer;
        -- -w has tmux pass the text on to the outside terminal.
        vim
            .system({ "tmux", "load-buffer", "-w", "-" }, { stdin = table.concat(lines, "\n") })
            :wait(500)
      else
        send(lines, regtype)
      end
      local fd = vim.uv.fs_open(clip_file, "w", tonumber("600", 8))
      if fd then
        vim.uv.fs_write(fd, vim.json.encode({ lines = lines, regtype = regtype }))
        vim.uv.fs_close(fd)
      end
    end
  end

  local function last_yank()
    local ok, clip = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(clip_file), "\n"))
    end)
    if ok and type(clip) == "table" and clip.lines then
      return clip
    end
  end

  local function paste()
    local clip = last_yank()
    if in_tmux then
      local got = vim.system({ "tmux", "save-buffer", "-" }):wait(500)
      if got.code == 0 and got.stdout ~= "" then
        if clip and table.concat(clip.lines, "\n") == got.stdout then
          return { clip.lines, clip.regtype }
        end
        return { vim.split(got.stdout, "\n"), "v" }
      end
    end
    if clip then
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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
