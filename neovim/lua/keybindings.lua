local vim = vim

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
vim.keymap.set("n", "<leader>\"", "ysiw\"", opts)
vim.keymap.set("n", "<leader>:", "ysiW\"", opts)
vim.keymap.set("n", "<leader>'", "ysiw'", opts)
vim.keymap.set("n", "<leader>;", "ysiW'", opts)
vim.keymap.set("n", "<M-Up>", "<cmd>call smoothie#do(\"<C-U>\")<cr>", opts)
vim.keymap.set("v", "<M-Up>", "<cmd>call smoothie#do(\"<C-U>\")<cr>", opts)
vim.keymap.set("n", "<M-Down>", "<cmd>call smoothie#do(\"<C-D>\")<cr>", opts)
vim.keymap.set("v", "<M-Down>", "<cmd>call smoothie#do(\"<C-D>\")<cr>", opts)
vim.keymap.set("n", "<C-G>", ":ToggleTerm dir=%:p:h <cr>", opts)

-- save without trim
vim.keymap.set("i", "<C-s>", "<Esc>:noautocmd w<CR>")
vim.keymap.set("n", "<C-s>", ":noautocmd w<CR>")

-- Tab
vim.keymap.set({ "n", "i" }, "<C-PageDown>", "<C-o>:tabprevious<CR>", opts)
vim.keymap.set({ "n", "i" }, "<S-PageDown>", "<C-o>:tabprevious<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-PageUp>", "<C-o>:tabnext<CR>", opts)
vim.keymap.set({ "n", "i" }, "<S-PageUp>", "<C-o>:tabnext<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-t>", "<C-o>:tabnew<CR>", opts)

-- for i = 1, 9 do
--     vim.keymap.set("n", "<leader>" .. i, i .. "gt", opts)
-- end
-- vim.keymap.set("n", "<leader>0", ":tablast<cr>", opt)
