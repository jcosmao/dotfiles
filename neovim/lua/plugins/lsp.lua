local efm_cfg = require("plugins.efm")

local lsp = {
    bashls = {},
    pyright = {
        settings = {
            pyright = {
                disableOrganizeImports = true,
                disableTaggedHints = false,
            },
            python = {
                analysis = {
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    diagnosticSeverityOverrides = {
                        -- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#type-check-diagnostics-settings
                        reportUnboundVariable = "warning",
                        reportPossiblyUnboundVariable = "information",
                        reportOptionalMemberAccess = "information",
                        reportAttributeAccessIssue = "information",
                    },
                },
            },
        },
    },
    jsonls = {},
    yamlls = {},
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                }
            }
        }
    },
    efm = {
        settings = efm_cfg.settings,
        filetypes = vim.tbl_keys(efm_cfg.settings.languages),
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
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
    gopls = {
        enabled = function()
            return vim.fn.executable('go') == 1
        end,
    },
    puppet = {},
    -- volar = {
    --     filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'html' }
    -- },
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
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        'mason-org/mason-lspconfig.nvim',
        config = function()

            -- Add the same capabilities to ALL server configurations.
            -- Refer to :h vim.lsp.config() for more information.
            vim.lsp.config("*", {
                capabilities = vim.lsp.protocol.make_client_capabilities(),
            })

            for server, config in pairs(lsp) do
                vim.lsp.config(server, config)
            end

            local filtered_lsp = vim.tbl_filter(
                function(server_name)
                    -- If the server has an "enabled" field and it's a function, call it
                    if lsp[server_name] and type(lsp[server_name].enabled) == "function" then
                        return lsp[server_name].enabled()
                    else
                        return true
                    end
                end,
                vim.tbl_keys(lsp)
            )

            require("mason-lspconfig").setup({
                ensure_installed = filtered_lsp,
                automatic_installation = true,
            })

            G.diagnostics_virtual_text = {
                format = function(diagnostic)
                    local lines = vim.split(diagnostic.message, '\n')
                    return lines[1]
                end,
                virt_text_pos = 'right_align',
                suffix = ' ',
                prefix = "■",
                spacing = 10,
            }

            function DiagnosticSetupDefaults()
                vim.diagnostic.config({
                    severity_sort = true,
                    underline = false,
                    update_in_insert = false,
                    virtual_box = true,
                    virtual_text = false,
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = G.signs.Error,
                            [vim.diagnostic.severity.WARN] = G.signs.Warn,
                            [vim.diagnostic.severity.INFO] = G.signs.Info,
                            [vim.diagnostic.severity.HINT] = G.signs.Hint,
                        },
                    },
                })
            end

            -- display config
            -- :lua vim.diagnostic.config()
            function DiagnosticVirtualTextToggle()
                if not vim.diagnostic.config().virtual_text then
                    vim.diagnostic.config({ virtual_text = G.diagnostics_virtual_text })
                    vim.notify("diagnostic.virtual_text enabled")
                else
                    vim.diagnostic.config({ virtual_text = false })
                    vim.notify("diagnostic.virtual_text disabled")
                end
            end

            function DiagnosticToggle()
                if vim.diagnostic.is_disabled() then
                    vim.diagnostic.enable()
                    vim.notify("diagnostic enabled")
                else
                    vim.diagnostic.disable()
                    vim.notify("diagnostic disabled")
                end
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                pattern = "*",
                callback = function()
                    LspKeymap()
                    DiagnosticSetupDefaults()
                end,
            })
        end,

        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
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
}
