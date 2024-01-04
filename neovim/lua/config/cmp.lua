local vim = vim
local cmp = require('cmp')
local lspconfig = require('lspconfig')

cmp.setup {
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        format = function(entry, vim_item)
            -- fancy icons and a name of kind
            vim_item.kind = require("lspkind").presets.default[vim_item.kind] ..
            " " .. vim_item.kind
            -- set a name for each source
            vim_item.menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                nvim_lua = "[Lua]",
                look = "[Look]",
                path = "[Path]",
                treesitter = "[treesitter]",
                cmp_tabnine = "[Tab9]"
            })[entry.source.name]
            return vim_item
        end
    },
    mapping = {
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
        ['<Up>'] = cmp.mapping.select_prev_item(),
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<C-Up>'] = cmp.mapping.scroll_docs(-4),
        ['<C-Down>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }),
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif require("luasnip").jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-next", true, true, true), "")
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
            else
                fallback()
            end
        end,
    },
    sources = {
        { name = 'nvim_lsp' },
        -- { name = 'cmp_tabnine' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'treesitter' },
        { name = 'buffer' },
    },
    cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    }),
}

-- -- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lspobj in pairs(vim.lsp.get_active_clients()) do
    lspconfig[lspobj.name].setup {
        capabilities = capabilities
    }
end
