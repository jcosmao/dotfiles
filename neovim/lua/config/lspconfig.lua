local vim = vim

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
    vim.keymap.set('n', '<C-\\>', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '?', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<space>F', function() vim.lsp.buf.format { async = true } end, bufopts)
    vim.keymap.set('n', '<space>u', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', '<space>i', vim.lsp.buf.implementation, bufopts)
end

-- display result in FZF
require('lspfuzzy').setup {}

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
    })

-- Add border
local _border = "rounded"

require('lspconfig.ui.windows').default_options.border = _border

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = _border
    }
)

vim.diagnostic.config {
    float = {
        border = _border
    }
}

local signature_config = {
    log_path = vim.fn.expand("$HOME") .. "/.cache/vim_lsp_signature.log",
    debug = false,
    hint_enable = false,
    max_width = 80,
    doc_lines = 0,
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = _border
    },
    padding = ' ',
}

require("lsp_signature").setup(signature_config)

require("mason").setup({
    ui = {
        border = _border
    }
})
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

--
-- pylsp configuration
--

require("lspconfig").pylsp.setup {
    on_attach = on_attach,
    cmd = { "pylsp" },
    filetypes = { "python" },
    settings = {
        pylsp = {
            configurationSources = { "flake8" },
            plugins = {
                flake8 = { enabled = true },
                mccabe = { enabled = false },
                pycodestyle = { enabled = true },
                pyflakes = { enabled = true },
                yapf = { enabled = true },
            },
        },
    },
}
