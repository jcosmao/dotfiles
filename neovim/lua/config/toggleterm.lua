local vim = vim

require("toggleterm").setup{
    size = 20,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    start_in_insert = true,
    close_on_exit = true, -- close the terminal window when the process exits
}


local toggletermGrp = vim.api.nvim_create_augroup("ToggleTermGrp", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = 'toggleterm',
    command = "set laststatus=0 noshowmode noruler | autocmd BufLeave <buffer> set laststatus=2 showmode ruler",
    group = toggletermGrp,
})

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    group = toggletermGrp,
    callback = function()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<F9>', [[<Cmd>ToggleTerm <cr>]], opts)
        vim.keymap.set('t', '<leader><ENTER>', [[<Cmd>ZoomWinTabToggle <cr>]], opts)
        vim.keymap.set('t', '<leader><Up>', [[<Cmd>wincmd k <cr>]], opts)
    end
})
