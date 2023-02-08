local vim = vim

-- display result in FZF
require('lspfuzzy').setup {}

-- -- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>,', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<space>.', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>L', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '?', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<space>F', function() vim.lsp.buf.format { async = true } end, bufopts)
    vim.keymap.set('n', '<space>y', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', '<space>u', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>i', vim.lsp.buf.implementation, bufopts)
end

local signs = {
    Error = " ",
    Warning = " ",
    Hint = " ",
    Information = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- disable diagnostic
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
    signs = true,
    underline = false,
    virtual_text = false,
}
)

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach,
        }
    end,
}

-- local function goto_definition_ctag_fallback(_, method, result)
--     if result == nil or vim.tbl_isempty(result) then
--         vim.fn.GoToDef(vim.fn.expand('<cword>'), vim.fn.getline('.'), 1)
--         return
--     end

--     -- textDocument/definition can return Location or Location[]
--     -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
--     if vim.tbl_islist(result) then
--         vim.lsp.util.jump_to_location(result[1])

--         if #result > 1 then
--             vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result))
--             vim.api.nvim_command("copen")
--             vim.api.nvim_command("wincmd p")
--         end
--     else
--         vim.lsp.util.jump_to_location(result)
--     end
-- end

-- vim.lsp.handlers["textDocument/definition"] = goto_definition_ctag_fallback
