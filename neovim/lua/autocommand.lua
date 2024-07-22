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
    setup_diff_mapping()
end

vim.api.nvim_create_user_command("DiffToggle", function()
    diff_toggle()
end, { nargs = 0 })

vim.api.nvim_create_autocmd({ "OptionSet" }, {
    pattern = "diff",
    callback = function()
        setup_diff_mapping()
    end
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "BufWritePost" }, {
    pattern = "*",
    callback = function()
        display_file_path()
        set_git_repo()
    end
})

vim.api.nvim_create_user_command("HieraEncrypt", function()
    hiera_encrypt()
end, { nargs = 0 })

vim.api.nvim_create_user_command("MouseToggle", function()
    mouse_toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DebugToggle", function()
    debug_toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("LineInfosToggle", function()
    line_infos_toggle()
end, { nargs = 0 })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.lib", "*.source" },
    command = "setfiletype sh",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.pp",
    command = "setfiletype puppet",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.inc",
    command = "setfiletype perl",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.tf",
    command = "setfiletype terraform",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.conf",
    command = "setfiletype ini",
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
