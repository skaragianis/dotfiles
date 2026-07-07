local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavour = "mocha",
      },
    },
    {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = {
          go = { "gofmt" },

          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },

          python = { "ruff" },
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
    },
    {
      "christoomey/vim-tmux-navigator",
    },
    {
      "nvim-mini/mini.statusline",
      version = false,
      opts = {
        set_vim_settings = true,
      },
    },
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        default_file_explorer = true,
        columns = {
          "icon",
          "mtime",
        },
        float = {
          padding = 2,
          max_width = 90,
          max_height = 0,
          border = "rounded",
          win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
        view_options = {
          is_hidden_file = function(_, _)
            return false
          end,
          is_always_hidden = function(name, _)
            return name == ".."
          end,
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local configs = require("nvim-treesitter")
        configs.install({
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "typescript",
          "tsx",
          "go",
          "gomod",
          "gowork",
          "gosum",
          "vue",
          "javascript",
          "html",
          "css",
        })
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.2.2",
      dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        })

        telescope.load_extension("fzf")

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope Find Files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope Live Grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope Help Tags" })
        vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions, { desc = "Telescope LSP Definitions" })
        vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Telescope LSP References" })
        vim.keymap.set(
          "n",
          "<leader>fs",
          builtin.lsp_document_symbols,
          { desc = "Telescope LSP Document Symbols" }
        )
        vim.keymap.set(
          "n",
          "<leader>fw",
          builtin.lsp_workspace_symbols,
          { desc = "Telescope LSP Document Symbols" }
        )
        vim.keymap.set("n", "<leader>fh", builtin.diagnostics, { desc = "Telescope LSP Diagnostics" })
      end,
    },
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      config = true,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
      ft = { "typescript", "typescriptreact", "javascript", "javascriptreact", "go", "lua", "python" },
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "ts_ls", "gopls", "lua_ls" },
        })
        vim.lsp.config("basedpyright", {
          filetypes = { "python" },
        })
        vim.lsp.config("ts_ls", {
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        })
        vim.lsp.config("gopls", {
          filetypes = { "go", "gomod", "gowork" },
        })
        vim.lsp.config("lua_ls", {
          filetypes = { "lua" },
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        })

        vim.lsp.enable({ "ts_ls", "gopls", "lua_ls", "basedpyright", "ruff" })
      end,
    },
  },
})

vim.cmd.colorscheme("catppuccin-mocha")
