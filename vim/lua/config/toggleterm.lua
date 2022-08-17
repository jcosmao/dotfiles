require("toggleterm").setup{
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    start_in_insert = true,
    close_on_exit = true, -- close the terminal window when the process exits
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<F9>', [[<Cmd>set mouse= | :ToggleTerm <CR>]], opts)
  vim.keymap.set('t', '<leader><ENTER>', [[<Cmd>ZoomWinTabToggle <cr>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
