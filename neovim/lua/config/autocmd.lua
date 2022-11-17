local vim = vim

vim.api.nvim_create_augroup('bufcheck', {clear = true})

-- Always quit nvimtree window when leaving tab by switching to previous file.
vim.api.nvim_create_autocmd('TabLeave', {
    group    = 'bufcheck',
    pattern  = 'NvimTree*',
    command  = 'wincmd p'})

-- start git messages in insert mode
vim.api.nvim_create_autocmd('FileType',     {
    group    = 'bufcheck',
    pattern  = { 'gitcommit', 'gitrebase', },
    command  = 'startinsert | 1'})

-- pager mappings for Manual
vim.api.nvim_create_autocmd('FileType',     {
    group    = 'bufcheck',
    pattern  = 'man',
    callback = function()
      vim.keymap.set('n', '<enter>'    , 'K'    , {buffer=true})
      vim.keymap.set('n', '<backspace>', '<c-o>', {buffer=true})
    end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost',  {
    group    = 'bufcheck',
    pattern  = '*',
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos('.', vim.fn.getpos("'\""))
            -- vim.cmd('normal zz') -- how do I center the buffer in a sane way??
            vim.cmd('silent! foldopen')
        end
    end
})
