return {
    'akinsho/toggleterm.nvim',
    opts = function()
        local shading_factor = "-30"
        if vim.o.background == "light" then
            shading_factor = "-2"
        end

        return {
            size = 20,
            -- open_mapping = [[<c-g>]],
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
            terminal_mappings = true,
            start_in_insert = true,
            close_on_exit = true, -- close the terminal window when the process exits
            winbar = {
                enabled = false,
                name_formatter = function(term) --  term: Terminal
                    return string.format("  Term %s  ", term.id)
                end,
            },
            shade_terminals = true,
            shading_factor = shading_factor,
        }
    end
}
