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
      "refractalize/oil-git-status.nvim",

      dependencies = {
        "stevearc/oil.nvim",
      },

      config = true,
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
        win_options = {
          signcolumn = "yes:2"
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
          ensure_installed = { "ts_ls", "vue_ls", "gopls", "lua_ls", },
        })
        -- mason installs the server here; the plugin ships inside it
        local vue_language_server_path = vim.fn.stdpath("data")
            .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

        vim.lsp.config("ty", {
          filetypes = { "python" },
        })
        vim.lsp.config("ts_ls", {
          -- ts_ls does the TypeScript work for .vue too, via this plugin
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = vue_language_server_path,
                languages = { "vue" },
                configNamespace = "typescript",
              },
            },
          },
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        })
        vim.lsp.config("vue_ls", { filetypes = { "vue" } })
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

        vim.lsp.enable({ "ts_ls", "vue_ls", "gopls", "lua_ls", "ty", "ruff" })
      end,
    },
    {
      "saghen/blink.cmp",
      dependencies = {
        "saghen/blink.lib",
        -- optional: provides snippets for the snippet source
        "rafamadriz/friendly-snippets",
      },
      build = function()
        -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
        -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
        require("blink.cmp").build():pwait()
      end,

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = { preset = "super-tab" },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },

        -- (Default) list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = { default = { "lsp", "path", "snippets", "buffer" } },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"`
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "rust" },
      },
    },
  },
})

vim.cmd.colorscheme("catppuccin-mocha")
