return {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {
        enabled = true,
        indent = {
            char = "▏",
            tab_char = "▏",
        },
        scope = {
            show_start = false,
            show_end = false,
        },
        exclude = {
            filetypes = { "markdown" },
        },
    }
}
