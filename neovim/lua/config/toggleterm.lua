local vim = vim
local toggleterm = require("toggleterm")

local shading_factor = "-25"
if vim.o.background == "light" then
    shading_factor = "-3"
end

toggleterm.setup{
    size = 20,
    open_mapping = [[<c-g>]],
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true,
    start_in_insert = true,
    close_on_exit = true, -- close the terminal window when the process exits
    winbar = {
        enabled = false,
        name_formatter = function(term) --  term: Terminal
            return  string.format("  Term %s  ", term.id)
        end,
    },
    shade_terminals = true,
    shading_factor = shading_factor,
}

local toggletermGrp = vim.api.nvim_create_augroup("ToggleTermGrp", { clear = true })

-- timeoutlen is timeout used for leader send key, reduce it in term mode and restore it outside
vim.api.nvim_create_autocmd("FileType", {
    pattern = 'toggleterm',
    command = "set laststatus=0 noshowmode noruler timeoutlen=150 | autocmd BufLeave <buffer> set laststatus=2 showmode ruler timeoutlen=1000",
    group = toggletermGrp,
})

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    group = toggletermGrp,
    callback = function()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<leader><ENTER>', [[<Cmd>ZoomWinTabToggle <cr>]], opts)
        vim.keymap.set('t', '<leader><Up>', [[<Cmd>wincmd k <cr>]], opts)
        vim.keymap.set('t', '<leader><Left>', [[<Cmd>wincmd h <cr>]], opts)
        vim.keymap.set('t', '<leader><Right>', [[<Cmd>wincmd l <cr>]], opts)
    end
})
