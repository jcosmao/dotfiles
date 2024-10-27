local vim = vim
require('utils')

vim.api.nvim_create_augroup('bufcheck', { clear = true })

-- Always quit nvimtree window when leaving tab by switching to previous file.
vim.api.nvim_create_autocmd('TabLeave', {
    group   = 'bufcheck',
    pattern = 'NvimTree*',
    command = 'wincmd p'
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

-- startup in diff mode ?
if vim.o.diff then
    SetupDiffMapping()
end

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
        DisplayFilePath()
        SetGitRepo()
    end
})

vim.api.nvim_create_user_command("Memo", function()
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

vim.api.nvim_create_user_command('Git', function(opts)
  vim.cmd('Gitsigns ' .. opts.args)
end, { nargs = '*' })

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

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.cmd("IBLDisable")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "json", "yaml" },
    callback = function()
        vim.cmd("IBLDisable")
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        vim.opt_local.conceallevel = 2
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "python",
    callback = function()
        vim.cmd("command! -nargs=0 Black lua PythonBlack()")
    end
})

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
