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
      "navarasu/onedark.nvim",
      lazy = false,
      priority = 1000, -- Forces Neovim to load this theme first to prevent visual flickering
      config = function()
        require('onedark').setup({
          -- Options: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', or 'light'
          style = 'dark', -- 'dark' provides the exact, faithful match to Zed's default

          -- Optional: Ensure syntax matching feels right with modern Neovim
          code_style = {
            comments = 'italic',
            keywords = 'none',
            functions = 'none',
            strings = 'none',
            variables = 'none'
          },
        })
        require('onedark').load()
      end,
    },
    {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = {
          go = { "gofmt" },

          javascript = { "biome" },
          javascriptreact = { "biome" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          markdown = { "prettier" },
          python = { "ruff" },
          sql = { "sql_formatter" },
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      },
    },
    {
      "mfussenegger/nvim-lint",
      ft = { "markdown" },
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
          markdown = { "markdownlint-cli2" },
        }

        local project_configs = {
          ".markdownlint-cli2.jsonc", ".markdownlint-cli2.yaml", ".markdownlint-cli2.cjs", ".markdownlint-cli2.mjs",
          ".markdownlint.jsonc", ".markdownlint.json", ".markdownlint.yaml", ".markdownlint.yml",
          ".markdownlint.cjs", ".markdownlint.mjs",
        }
        local global_config = vim.fn.expand("~/.config/markdownlint/config.yaml")

        local mdlint = lint.linters["markdownlint-cli2"]
        mdlint.args = {
          "--config",
          function()
            local found = vim.fs.find(project_configs, {
              upward = true,
              path = vim.fn.expand("%:p:h"),
            })
            return found[1] or global_config
          end,
          "-",
        }

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
          pattern = "*.md",
          callback = function()
            lint.try_lint()
          end,
        })
      end,
    },
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        local gs = require("gitsigns")

        vim.keymap.set('n', ']h', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Jump to next git change" })

        vim.keymap.set('n', '[h', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Jump to previous git change" })
      end
    },
    {
      "christoomey/vim-tmux-navigator",
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      lazy = false,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        close_if_last_window = true,
        source_selector = {
          winbar = true,
        },
        window = {
          width = 30,
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added = "+",
              modified = "~",
            },
          },
        },
        filesystem = {
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      },
      config = function(_, opts)
        require("neo-tree").setup(opts)
        local git_status_timer = vim.uv.new_timer()
        git_status_timer:start(3000, 3000, vim.schedule_wrap(function()
          for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local ok, source = pcall(vim.api.nvim_buf_get_var, bufnr, "neo_tree_source")
            if ok and source == "git_status" then
              require("neo-tree.sources.git_status").refresh()
              break
            end
          end
        end))
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            require("neo-tree.command").execute({ source = "filesystem", position = "right", action = "show" })
          end,
        })
      end,
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
        default_file_explorer = false,
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
          "sql",
        })

        -- the plugin only installs parsers; highlighting/indent must be started per-buffer
        vim.api.nvim_create_autocmd("FileType", {
          pattern = {
            "c",
            "lua",
            "vim",
            "help",
            "query",
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "go",
            "gomod",
            "gowork",
            "gosum",
            "vue",
            "html",
            "css",
            "sql",
          },
          callback = function()
            vim.treesitter.start()
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      end,
    },
    {
      "windwp/nvim-ts-autotag",
      ft = { "typescriptreact", "javascriptreact", "html", "vue" },
      opts = {},
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
      ft = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue", "go", "lua", "python", "markdown" },
      config = function()
        vim.lsp.config("ty", {
          filetypes = { "python" },
        })
        vim.lsp.config("vue_ls", {
          filetypes = { "vue" },
          -- Mason's vue-language-server ships TypeScript 7 (the native port), which has
          -- no JS API, so Volar crashes on `ts.server.protocol`. Hand it the project's
          -- own TypeScript instead. Must be --tsdk on argv; init_options is ignored.
          cmd = function(dispatchers, config)
            local root = config.root_dir or vim.fn.getcwd()
            local tsdk = root .. "/node_modules/typescript/lib"

            if not vim.uv.fs_stat(tsdk .. "/typescript.js") then
              vim.notify("vue_ls: no usable TypeScript at " .. tsdk, vim.log.levels.WARN)
            end

            return vim.lsp.rpc.start(
              { "vue-language-server", "--stdio", "--tsdk=" .. tsdk },
              dispatchers
            )
          end,
        })
        vim.lsp.config("eslint", {
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" },
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
        require("mason-lspconfig").setup({
          ensure_installed = { "vue_ls", "eslint", "gopls", "lua_ls", "marksman", },
        })
        vim.lsp.enable({ "tsc", "vue_ls", "eslint", "gopls", "lua_ls", "ty", "ruff", "marksman" })
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
