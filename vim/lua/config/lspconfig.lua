local vim = vim
local lspconfig = require('lspconfig')
local lspinstall = require('lspinstall')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- show signature when typing
    require'lsp_signature'.on_attach()

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '?', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<space>F', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    -- buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    -- buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

end

-- disable diagnostic
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = false,
    }
)

local function goto_definition_ctag_fallback(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
        vim.fn.GoToDef(vim.fn.expand('<cword>'), vim.fn.getline('.'))
        return
    end

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
    if vim.tbl_islist(result) then
        vim.lsp.util.jump_to_location(result[1])

        if #result > 1 then
            vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result))
            vim.api.nvim_command("copen")
            vim.api.nvim_command("wincmd p")
        end
    else
        vim.lsp.util.jump_to_location(result)
    end
end

vim.lsp.handlers["textDocument/definition"] = goto_definition_ctag_fallback

-- https://langserver.org/
-- Install langserver with :LspInstall xxx
local function setup_servers()
    lspinstall.setup()
    local servers = lspinstall.installed_servers()

    -- Replace pyright by pylsp
    -- for i, s in ipairs(servers) do
    --     if s == 'python' then
    --     	table.remove(servers, i)
    --     end
    -- end
    -- table.insert(servers, 'pylsp')

    for _, server in pairs(servers) do
        lspconfig[server].setup{
            on_attach = on_attach,
            flags = {
                debounce_text_changes = 150,
            }
        }
    end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function ()
    setup_servers() -- reload installed servers
    vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end
