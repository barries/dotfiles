--------------------------------------------------------------------------------
-- vim-mark config
--
-- This must be done before vim-mark is loaded
--
-- vim-mark maps a fair number of sequences, including \r, which
-- I map for replace, and # and *, which make search on marks
-- not work intuitively for me.
--
-- Its \n (clear marks) has a caveat that repeating \m doesn't
-- have, and repeating \m to clear the highlighted mark is all
-- I need.

vim.g.mw_no_mappings               = 1   -- 1: Tell mark.vim not to install global mappings
vim.g.mwHistAdd                    = ""  -- "": Don"t auto add to search or input histories
vim.g.mwDefaultHighlightingPalette = "extended"

vim.keymap.set({"n", "x"}, "<Leader>m", "<Plug>MarkSet");

--------------------------------------------------------------------------------
-- disable netrw at the very start of your init.lua for nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--------------------------------------------------------------------------------
-- lazy.nvim config

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath);

local plugins = {
    "danro/rename.vim",
    "godlygeek/tabular",
    "inkarkat/vim-ingo-library",
    "inkarkat/vim-mark", -- sets maps on \r *after* .vimrc exit, see VimEnter_Initialize()
    "junegunn/fzf",
    "kana/vim-submode",
    "mbbill/undotree",
    "mfussenegger/nvim-dap",
    "nvim-tree/nvim-tree.lua", -- file explorer
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        keys = {
            { '<F8>',       mode = { "o" }, function() require("dap").continue();                                  end },
            { '<F10>',      mode = { "o" }, function() require("dap").step_over();                                 end },
            { '<F11>',      mode = { "o" }, function() require("dap").step_into();                                 end },
            { '<F12>',      mode = { "o" }, function() require("dap").step_out();                                  end },
            { '<Leader>b',  mode = { "o" }, function() require("dap").toggle_breakpoint();                         end },
            { '<Leader>dl', mode = { "o" }, function() require("dap").run_last();                                  end },
            { '<Leader>df', mode = { "o" }, function() require("dapui").float_element('scopes', { enter = true }); end },
        },
    },
    -- "vim-scripts/Align"
    { -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true }, -- Automatically install LSPs to stdpath for neovim
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim", tag = "legacy", opts = {} },

            "folke/lazydev.nvim", -- Additional lua configuration, makes nvim stuff amazing!
        },
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "gs",    mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash"               },
            { "gS",    mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash Treesitter"    },
            { "s",     mode = { "o"           }, function() require("flash").remote()            end, desc = "Remote Flash"        },
            { "S",     mode = { "o", "x"      }, function() require("flash").treesitter_search() end, desc = "Treesitter Search"   },
            { "<c-s>", mode = { "c"           }, function() require("flash").toggle()            end, desc = "Toggle Flash Search" },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    { -- optional completion source for require statements and module annotations
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
        end,
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },
    {
        'folke/which-key.nvim',
        event = "VeryLazy",
        opts = {
            preset = "helix",
            delay = function(ctx)
                return ctx.plugin and 0 or 1000
            end,
            expand = 2,
            sort = { "order", "alphanum", "groups", "mod" },
            win = {
                border="rounded",
                padding = { 1, 1 },
            }
        },
        keys = {
            {
                "<leader>\\",
                function()
                  require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    }, -- Useful plugin to show you pending keybinds.

    { -- Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
    },

    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        keys = {
            { "<leader>f", "<cmd>Neotree toggle<cr>", desc="Neotree" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            --"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
    },
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false, -- This plugin is already lazy
    },

    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
        }
    },
}

require("lazy").setup(plugins, {
    defaults = {
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- notify on update
    }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                -- "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

--------------------------------------------------------------------------------
-- Personal config

-- use existing directories for vim compatibility
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")

vim.cmd.colorscheme("barries")

vim.cmd([[source ~/.vimrc]])

vim.diagnostic.config({
    update_in_insert = false, -- Reduce noise when editing
    -- virtual_lines    = { current_line = true },
})

--------------------------------------------------------------------------------
-- Telescope
-- See `:help telescope` and `:help telescope.setup()`

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
                ["<CR>" ] = actions.select_tab_drop,
            },
        },
    },
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?",       require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers,  { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files,   { desc = "Search [G]it [F]iles"    })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files,  { desc = "[S]earch [F]iles"        })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags,   { desc = "[S]earch [H]elp"         })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep,   { desc = "[S]earch by [G]rep"      })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics"  })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume,      { desc = "[S]earch [R]esume"       })

--------------------------------------------------------------------------------
-- Treesitter

require("nvim-treesitter.configs").setup({
    modules = {}, -- silence lint warning
    sync_install = false, -- silence lint warning
    ensure_installed = {}, -- silence lint warning
    ignore_install = {}, -- silence lint warning

    auto_install = false, -- Don't auto install langs
    -- commenting out 2021-02-13, to avoid "string required" error after neovim update: ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true, -- false will disable the whole extension
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "+",
            node_incremental = "+",
            scope_incremental = "<c-s>",
            node_decremental = "-",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
    },
})

-- Diagnostic keymaps
vim.keymap.set("n", "[d",        function() vim.diagnostic.jump { count = -1, float = true } end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d",        function() vim.diagnostic.jump { count =  1, float = true } end, { desc = "Go to next diagnostic message"     })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float,                                       { desc = "Open floating diagnostic message"  })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist,                                       { desc = "Open diagnostics list"             })

--------------------------------------------------------------------------------
-- LSP

local on_attach = function(_, bufnr) --  This function gets run when an LSP connects to a particular buffer.
    vim.wo.signcolumn = "yes" -- Keep sign column from disappearing in insert mode

    local wk = require("which-key");

    wk.add({
        {"<F2>",       vim.lsp.buf.rename,                                         desc = "[R]e[n]ame"                 },
        {"<leader>ca", vim.lsp.buf.code_action,                                    desc = "[C]ode [A]ction"            },
        {"gd",         vim.lsp.buf.definition,                                     desc = "[G]oto [D]efinition"        },
        {"gr",         require("telescope.builtin").lsp_references,                desc = "[G]oto [R]eferences"        },
        {"gI",         require("telescope.builtin").lsp_implementations,           desc = "[G]oto [I]mplementation"    },
        {"<leader>D",  vim.lsp.buf.type_definition,                                desc = "Type [D]efinition"          },
        {"<leader>ds", require("telescope.builtin").lsp_document_symbols,          desc = "[D]ocument [S]ymbols"       },
        {"<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, desc = "[W]orkspace [S]ymbols"      },

        -- See `:help K` for why this keymap},
        {"K",          vim.lsp.buf.hover,                                          desc = "Hover Documentation"        },
        {"<C-k>",      vim.lsp.buf.signature_help,                                 desc = "Signature Documentation"    },
        -- Lesser used LSP functionality},
        {"gD",         vim.lsp.buf.declaration,                                    desc = "[G]oto [D]eclaration"       },
        {"<leader>wa", vim.lsp.buf.add_workspace_folder,                           desc = "[W]orkspace [A]dd Folder"   },
        {"<leader>wr", vim.lsp.buf.remove_workspace_folder,                        desc = "[W]orkspace [R]emove Folder"},
        {
            "<leader>wl",
            function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end,
            desc = "[W]orkspace [L]ist Folders"
        }
    });

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        })
    end,
})

vim.g.rustaceanvim = {
    server = {
        on_attach = on_attach,
    }
}

vim.api.nvim_create_autocmd('CursorHold',  { callback = function() vim.lsp.buf.document_highlight() end, } )
vim.api.nvim_create_autocmd('CursorHoldI', { callback = function() vim.lsp.buf.document_highlight() end, } )
vim.api.nvim_create_autocmd('CursorMoved', { callback = function() vim.lsp.buf.clear_references()   end, } )

--------------------------------------------------------------------------------
-- nvim-cmp
-- See `:help cmp`

local cmp = require("cmp")
local luasnip = require 'luasnip';
require('luasnip.loaders.from_vscode').lazy_load();
luasnip.config.setup {};

cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = function(fallback)
            fallback()
        end,
        --  if cmp.visible() then
        --    cmp.select_next_item();
        --  else
        --    fallback(); -- vim's builtin functionality is very nice at times
        --  end
        --end),
        ["<C-p>"] = function(fallback)
            fallback()
        end,
        --  if cmp.visible() then
        --    cmp.select_prev_item();
        --  else
        --    fallback(); -- vim's builtin functionality is very nice at times
        --  end
        --end),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            --elseif luasnip.expand_or_locally_jumpable() then
            --  luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            --elseif luasnip.locally_jumpable(-1) then
            --  luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})

--------------------------------------------------------------------------------
-- DAP

require("dapui").setup()

local dap, dapui = require("dap"), require("dapui");

dap.listeners.before.attach.dapui_config           = function() dapui.open()  end
dap.listeners.before.launch.dapui_config           = function() dapui.open()  end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
