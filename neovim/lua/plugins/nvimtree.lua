return {
    'nvim-tree/nvim-tree.lua',
    opts = {
        sort_by = "case_sensitive",
        sync_root_with_cwd = true,
        reload_on_bufenter = true,
        respect_buf_cwd = true,
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
        git = {
            enable = true,
            ignore = false,
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
    }
}
