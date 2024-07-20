local vim = vim

vim.g.fzf_layout = { down = '60%' }
vim.g.fzf_preview_window = { 'right:hidden', '?' }

vim.env.FZF_DEFAULT_OPTS =
"--ansi --layout reverse --preview-window right:60% --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down --height=60% --margin 1,1"

vim.api.nvim_create_user_command("Rg", function(opts)
    local args = opts.args
    local bang = opts.bang
    vim.fn['fzf#vim#grep'](
        'rg --no-ignore --column --no-heading --line-number --color=always ' .. vim.fn.shellescape(args), 1,
        vim.fn['fzf#vim#with_preview']({ options = '--delimiter ":" --exact --nth 4..' }), bang)
end, { nargs = '*', bang = true })

vim.api.nvim_create_user_command("RgWithFilePath", function(opts)
    local args = opts.args
    local bang = opts.bang
    vim.fn['fzf#vim#grep'](
        'rg --no-ignore --column --no-heading --line-number --color=always ' .. vim.fn.shellescape(args), 1,
        vim.fn['fzf#vim#with_preview']({ options = '--exact' }), bang)
end, { nargs = '*', bang = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "fzf",
    callback = function()
        vim.o.laststatus = 0
        vim.o.showmode = false
        vim.o.ruler = false
    end
})

vim.api.nvim_create_autocmd({ "BufLeave" }, {
    buffer = 0,
    callback = function()
        vim.o.laststatus = 2
        vim.o.showmode = true
        vim.o.ruler = true
    end
})
