local vim = vim

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    sync_root_with_cwd = true,
    reload_on_bufenter = true,
    view = {
        cursorline = true,
        width = 50,
        side = "left",
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
    update_focused_file = {
        enable = true,
        update_root = true,
        ignore_list = {},
    },
    tab = {
        sync = {
            open = true,
            close = true,
            ignore = {},
        },
    },
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
    pattern = "NvimTree_*",
    callback = function()
        local layout = vim.api.nvim_call_function("winlayout", {})
        if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
            vim.cmd("confirm quit")
        end
    end
})
