local vim = V

vim.api.nvim_create_augroup('bufcheck', { clear = true })

-- Always quit nvimtree window when leaving tab by switching to previous file.
vim.api.nvim_create_autocmd('TabLeave', {
    group   = 'bufcheck',
    pattern = 'NvimTree*',
    command = 'wincmd p'
})

-- quit if nvimtree is last opened buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "NvimTree_*",
    callback = function()
        local layout = vim.api.nvim_call_function("winlayout", {})
        if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
            vim.cmd("confirm quit")
        end
    end
})

-- start git messages in insert mode
vim.api.nvim_create_autocmd('FileType', {
    group   = 'bufcheck',
    pattern = { 'gitcommit', 'gitrebase', },
    command = 'startinsert | 1'
})

-- pager mappings for Manual
vim.api.nvim_create_autocmd('FileType', {
    group    = 'bufcheck',
    pattern  = 'man',
    callback = function()
        vim.keymap.set('n', '<enter>', 'K', { buffer = true })
        vim.keymap.set('n', '<backspace>', '<c-o>', { buffer = true })
    end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
    group    = 'bufcheck',
    pattern  = '*',
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos('.', vim.fn.getpos("'\""))
            vim.cmd('silent! foldopen')
        end
    end
})

vim.api.nvim_create_autocmd('BufEnter', {
    group    = 'bufcheck',
    pattern  = '*',
    callback = function()
        vim.cmd('silent! execute ":NvimTreeRefresh"')
    end
})

-- startup in diff mode ?
vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        if vim.o.diff then
            SetupDiffMapping()
        end
    end,
})

vim.api.nvim_create_user_command("DiffToggle", function()
    DiffToggle()
end, { nargs = 0 })

vim.api.nvim_create_autocmd({ "OptionSet" }, {
    pattern = "diff",
    callback = function()
        SetupDiffMapping()
    end
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "BufWritePost" }, {
    pattern = "*",
    callback = function()
        SetGitRepo()
    end
})

vim.api.nvim_create_user_command("F", function()
    DisplayFilePath()
end, { nargs = 0 })

vim.api.nvim_create_user_command("M", function()
    vim.api.nvim_command('tabnew ' .. vim.fn.stdpath("config") .. '/help.md')
end, { nargs = 0 })

vim.api.nvim_create_user_command("HieraEncrypt", function()
    HieraEncrypt()
end, { nargs = 0 })

vim.api.nvim_create_user_command("MouseToggle", function()
    MouseToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DebugToggle", function()
    DebugToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("LineInfosToggle", function()
    LineInfosToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Black", function()
    PythonBlack()
end, { nargs = 0 })

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "puppet" },
    callback = function()
        vim.opt_local.iskeyword = vim.opt_local.iskeyword + ":"
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "yaml" },
    callback = function()
        vim.opt_local.indentkeys = vim.opt_local.indentkeys - "<:>"
        vim.opt_local.indentkeys = vim.opt_local.indentkeys - ":"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "javascript", "terraform" },
    callback = function()
        vim.opt_local.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "sh",
    callback = function()
        vim.opt_local.iskeyword = vim.opt_local.iskeyword + "$"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.api.nvim_set_keymap("n", "<leader><BS>", ":GoCodeLenAct<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<leader>=", ":GoIfErr<cr>", { noremap = true, silent = true })
    end,
})

-- remove trailing whitespaces
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Display everything in edit mode
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = { "json", "markdown" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = { "json", "markdown" },
    callback = function()
        vim.opt_local.conceallevel = 2
    end,
})

-- python max line len
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = "*",
    callback = function()
        AutoColorColumn()
    end
})

-- Close nvimtree and Trouble when diffview mode is opened
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DiffviewOpen", { clear = true }),
    pattern = "Diffview*",
    callback = function()
        vim.cmd(":NvimTreeClose")
        vim.cmd(":Trouble close")
        vim.diagnostic.disable()
        vim.keymap.set({ 'n', 'i' }, '<F1>', ':DiffviewToggleFiles <cr>', { buffer = true })
    end
})

vim.api.nvim_create_user_command('Opendev20231', 'DiffviewOpen opendev/stable/2023.1', {})

vim.api.nvim_create_augroup('trouble', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    group   = 'trouble',
    pattern = 'python',
    command = 'TroubleRefresh'
})

vim.api.nvim_create_user_command("BackgroundToggle", function()
    BackgroundToggle()
end, { nargs = 0 })


-- timeoutlen is timeout used for leader send key, reduce it in term mode and restore it outside
vim.api.nvim_create_autocmd("FileType", {
    group = TermGrp,
    pattern = 'toggleterm',
    command = [[
        set laststatus=0 noshowmode noruler timeoutlen=150 |
        autocmd BufEnter,CursorMoved <buffer> startinsert |
        autocmd BufLeave <buffer> set laststatus=2 showmode ruler timeoutlen=1000
    ]],
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = TermGrp,
    pattern = '*',
    callback = function()
        if vim.bo.filetype ~= 'toggleterm' then
            vim.opt.timeoutlen = 1000
        end
    end
})

-- Run gofmt + goimport on save
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = 'go',
    callback = function()
        require('go.format').goimport()
    end,
})

-- force reload IBL colorscheme on start
vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        IBLReload()
        -- fix weird issue when vim is launched with file as parameter, ft is not detected
        -- force redetect
        vim.cmd("filetype detect")
    end,
})