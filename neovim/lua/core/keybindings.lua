local vim = V

-- Remap some common typos
vim.cmd([[
    command! -bang E e<bang>
    command! -bang Q q<bang>
    command! -bang W w<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Wq wq<bang>
    command! -bang WQ wq<bang>
]])

-- Mapping
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>V", ":tabedit $MYVIMRC<cr>", opts)
vim.keymap.set("n", "<leader>VV", ":source $MYVIMRC | echo $MYVIMRC 'reloaded'<cr>", opts)
vim.keymap.set("n", "<leader><ESC>", ":LineInfosToggle<cr>", opts)
vim.keymap.set("n", "<F1>", ":NvimTreeFindFileToggle!<cr>", opts)
vim.keymap.set("n", "<F2>", ":Trouble symbols toggle win.size=50 focus=false<cr>", opts)
vim.keymap.set("n", "<F3>", ":set paste!<cr>", opts)
vim.keymap.set("n", "<F9>", ":BackgroundToggle<cr>", opts)
vim.keymap.set("n", "<F10>", ":Startify<cr>", opts)
vim.keymap.set("n", "<F12>", ":MouseToggle<cr>", opts)
vim.keymap.set("n", "<leader>a", ":execute 'RgWithFilePath' expand('<cword>')<cr>", opts)
vim.keymap.set("n", "<leader>A", ":execute 'Rg' expand('<cword>')<cr>", opts)
vim.keymap.set("n", "<leader>s", ":RgWithFilePath<cr>", opts)
vim.keymap.set("n", "<leader>S", ":Rg<cr>", opts)
vim.keymap.set("n", "<leader>f", ":Files<cr>", opts)
vim.keymap.set("n", "<leader>d", ":Neogen<cr>", opts)
vim.keymap.set("n", "<leader>b", ":Buffers<cr>", opts)
vim.keymap.set("n", "<leader>t", ":FZFCtags<cr>", opts)
vim.keymap.set("n", "<leader>c", ":BCommits<cr>", opts)
vim.keymap.set("n", "<leader>h", ":History<cr>", opts)
vim.keymap.set("n", "<leader>g", ":execute 'BlameToggle virtual'<cr>", opts)
vim.keymap.set("n", "<leader>m", ":Snippets<cr>", opts)
vim.keymap.set("n", "<C-a>", "^", opts)
vim.keymap.set("i", "<C-a>", "<C-o>^", opts)
vim.keymap.set("n", "<C-e>", "$", opts)
vim.keymap.set("i", "<C-e>", "<C-o>$", opts)
vim.keymap.set("n", "<C-Right>", "e", opts)
vim.keymap.set("n", "<C-Left>", "b", opts)
vim.keymap.set("n", "<leader>+", ":vsplit<cr>", opts)
vim.keymap.set("n", "<leader>=", ":split<cr>", opts)
vim.keymap.set("n", "<C-S-Up>", ":wincmd k<cr>", opts)
vim.keymap.set("n", "<C-S-Down>", ":wincmd j<cr>", opts)
vim.keymap.set("n", "<C-S-Right>", ":wincmd l<cr>", opts)
vim.keymap.set("n", "<C-S-Left>", ":wincmd h<cr>", opts)
vim.keymap.set("n", "<leader><Up>", ":wincmd k<cr>", opts)
vim.keymap.set("n", "<leader><Down>", ":wincmd j<cr>", opts)
vim.keymap.set("n", "<leader><Right>", ":wincmd l<cr>", opts)
vim.keymap.set("n", "<leader><Left>", ":wincmd h<cr>", opts)
vim.keymap.set("n", "<leader><leader>", ":noh<cr>", opts)
vim.keymap.set("n", "<leader><ENTER>", ":ZoomWinTabToggle <cr>", opts)
vim.keymap.set("n", "<leader>k", ":Trouble diagnostics toggle filter.buf=0 focus=false win.size=35<cr>", opts)
vim.keymap.set("n", "<leader>l", ":Trouble diagnostics toggle focus=false win.size=35<cr>", opts)
vim.keymap.set("n", "<leader>p", "\"0p", opts)
vim.keymap.set("i", "<C-p>", "<C-r>\"", opts)
vim.keymap.set("n", "<C-G>", ":ToggleTerm dir=%:p:h <cr>", opts)
vim.keymap.set("n", "<leader>?", ":Memo <cr>", opts)

-- Set key mappings using Vimscript commands within Lua
-- not working with pure lua...

-- nvim surround
vim.cmd([[
    map <silent> <leader>" ysiw"
    map <silent> <leader>: ysiW"
    map <silent> <leader>' ysiw'
    map <silent> <leader>; ysiW'
]])

-- save without trim
vim.keymap.set("i", "<C-s>", "<Esc>:noautocmd w<CR>")
vim.keymap.set("n", "<C-s>", ":noautocmd w<CR>")

-- Tab
vim.keymap.set({ "n", "i" }, "<C-PageDown>", "<C-o>:tabprevious<CR>", opts)
vim.keymap.set({ "n", "i" }, "<S-PageDown>", "<C-o>:tabprevious<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-PageUp>", "<C-o>:tabnext<CR>", opts)
vim.keymap.set({ "n", "i" }, "<S-PageUp>", "<C-o>:tabnext<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-t>", "<C-o>:tabnew<CR>", opts)

vim.keymap.set('n', '<leader>]', ':lua GotoCtags(vim.fn.expand("<cword>"))<cr>', opts)
vim.keymap.set('n', '<leader>\\', ':lua GotoCscope(vim.fn.expand("<cword>"))<cr>', opts)

-- Terminal
vim.api.nvim_create_autocmd("TermOpen", {
    group = TermGrp,
    pattern = "term://*",
    callback = function()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<leader><ENTER>', [[<Cmd>ZoomWinTabToggle <cr>]], opts)
        vim.keymap.set('t', '<leader><Up>', [[<Cmd>wincmd k <cr>]], opts)
        vim.keymap.set('t', '<leader><Left>', [[<Cmd>wincmd h <cr>]], opts)
        vim.keymap.set('t', '<leader><Right>', [[<Cmd>wincmd l <cr>]], opts)
    end,
})

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>,', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>.', vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>j", function() DiagnosticVirtualTextToggle() end)
vim.keymap.set("n", "<leader>J", function() DiagnosticToggle() end)

-- LSP
function LspKeymap()
    local opts = { noremap = true, silent = true }
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-\\>', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '?', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'i' }, '<C-k>', function() require('lsp_signature').toggle_float_win() end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)
    vim.keymap.set('n', '<leader>u', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>i', vim.lsp.buf.implementation, opts)
end

function SetupScrollKeybinding()
    local cinnamon = require('cinnamon')
    local keymap = {
        ["<M-Up>"]   = function() cinnamon.scroll("<C-U>zz") end,
        ["<M-Down>"] = function() cinnamon.scroll("<C-D>zz") end,
    }
    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
    end
end

-- scroll
vim.cmd([[
    map <silent> <M-z> zt
    map <silent> <M-x> zz
    map <silent> <M-c> zb
]])

-- Fold toggle
vim.cmd([[
    map <silent> <M-/> za
    map <silent> <M-.> zA
]])

-- Diff mode
function SetupDiffMapping()
    vim.cmd(':IBLDisable')
    if vim.fn.winnr() ~= vim.fn.winnr('h') then
        vim.api.nvim_set_keymap('n', '<<', ':diffput<cr>', opts)
        vim.api.nvim_set_keymap('n', '>>', ':diffget<cr>', opts)
    else
        vim.api.nvim_set_keymap('n', '<<', ':diffput<cr>', opts)
        vim.api.nvim_set_keymap('n', '>>', ':diffget<cr>', opts)
    end
end