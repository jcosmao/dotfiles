return {
    {
        'hrsh7th/nvim-cmp',

        dependencies = {
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-cmdline' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'L3MON4D3/LuaSnip' },
            { 'ray-x/cmp-treesitter' },
        },

        config = function()
            local cmp = require('cmp')
            local lspconfig = require('lspconfig')
            local luasnip = require('luasnip')
            local lspkind = require('lspkind')

            cmp.setup {
                preselect = 'none',
                completion = {
                    completeopt = 'menu,menuone,noinsert,noselect'
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                window = {
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = lspkind.cmp_format({
                        mode = 'symbol_text', -- show only symbol annotations
                    })
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
                    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
                    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
                    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
                    ['<C-Up>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-Down>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = false
                    }),
                    ['<Tab>'] = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end,
                    ['<S-Tab>'] = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end,
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                    { name = 'treesitter' },
                    { name = 'buffer' },
                },
            }

            -- Enable completion for command-line
            cmp.setup.cmdline({ '/', '?' }, {
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol',
                    }),
                },
                mapping = cmp.mapping.preset.cmdline(),
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' },
                }
            })

            -- Enable completion for command-line (:)
            cmp.setup.cmdline(':', {
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol',
                    }),
                },
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'cmdline' },
                    { name = 'path' },
                }
            })

            -- -- Setup lspconfig.
            local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
            for _, lspobj in pairs(vim.lsp.get_active_clients()) do
                lspconfig[lspobj.name].setup {
                    capabilities = capabilities
                }
            end
        end,

    },
}
