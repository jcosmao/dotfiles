local vim = V

local efm_cfg = require("plugins.efm")

local lsp = {
    bashls = {},
    basedpyright = {},
    jsonls = {},
    yamlls = {},
    lua_ls = {},
    efm = {
        settings = efm_cfg.settings,
        filetypes = vim.tbl_keys(efm_cfg.settings.languages),
        init_options = { documentFormatting = true },
    },
    terraformls = {
        filetypes = { 'terraform', 'hcl' },
        init_options = {
            experimentalFeatures = {
                prefillRequiredFields = true,
            },
        },
    },
    tflint = {
        filetypes = { 'terraform' },
    },
    ansiblels = {},
    eslint = {},
    gopls = {},
    puppet = {},
    volar = {
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'html' }
    },
    markdown_oxide = {
        filetypes = { 'markdown' },
    },

    -- shfmt = {},
    -- mypy = {},
    -- isort = {},
    -- prettierd = {},
    -- ["pyproject-flake8"] = {},
}


return {
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(lsp),
                automatic_installation = true,
            })

            require("mason-lspconfig").setup_handlers {
                -- This is a default handler that will be called for each installed server (also for new servers that are installed during a session)
                function(server_name)
                    local srv = lsp[server_name] or {}
                    local settings = srv.settings or nil
                    local filetypes = srv.filetypes or nil
                    local init_options = srv.init_options or nil
                    local capabilities = require('cmp_nvim_lsp').default_capabilities()
                    local lspconfig = require("lspconfig")
                    lspconfig[server_name].setup {
                        on_attach = function(_, bufnr)
                            -- Enable completion triggered by <c-x><c-o>
                            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                            LspKeymap()
                        end,
                        capabilities = capabilities,
                        settings = settings,
                        filetypes = filetypes,
                        init_options = init_options,
                    }
                end
            }
            require('lspconfig.ui.windows').default_options.border = Border

            local float = {
                focusable = false,
                style = "minimal",
                max_width = 100,
                border = Border,
                noautocmd = true,
            }
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float)
            -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, float)
        end,
        dependencies = {
            {
                'williamboman/mason.nvim',
                opts = {
                    ui = {
                        border = Border
                    }
                }
            },
            { 'neovim/nvim-lspconfig' },
        },
    },
    {
        'onsails/lspkind-nvim',
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {
            log_path = vim.fn.expand("$HOME") .. "/.cache/vim_lsp_signature.log",
            debug = false,
            hint_enable = false,
            max_width = 100,
            doc_lines = 0,
            wrap = true,
            bind = true, -- This is mandatory, otherwise border config won't get registered.
            handler_opts = {
                border = Border
            },
            padding = ' ',
            transparency = 0,
            noautocmd = true,
            -- toggle_key = '<M-k>',
            auto_close_after = 3000,
        },
        config = function(_, opts)
            require('lsp_signature').setup(opts)
        end
    },
    {
        'ojroques/nvim-lspfuzzy',
        opts = {
            methods = 'all',       -- either 'all' or a list of LSP methods (see below)
            jump_one = true,       -- jump immediately if there is only one location
            save_last = true,      -- save last location results for the :LspFuzzyLast command
            callback = nil,        -- callback called after jumping to a location
            fzf_modifier = ':~:.', -- format FZF entries, see |filename-modifiers|
            fzf_trim = true,       -- trim FZF entries
        }
    }
}
