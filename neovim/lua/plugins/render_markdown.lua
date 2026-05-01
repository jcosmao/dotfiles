return {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown", "norg", "rmd", "org" },
    opts = {
        enabled = true,
        -- This function takes the buffer number as an input
        -- If it returns true, the plugin will NOT attach to that buffer
        ignore = function(buf)
            local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
            return buftype == 'nofile'
        end,
        completions = { lsp = { enabled = true } },
        heading = {
            enabled = true,
            sign = true,
            position = 'overlay',
            icons = { '❯ ', '❯❯ ', '❯❯❯ ', '❯❯❯❯ ', '❯❯❯❯❯ ' },
            signs = { '󰫎 ' },
            width = 'full',
            left_margin = 1,
            left_pad = 1,
            right_pad = 5,
            right_margin = 20,
            border = false,
            border_virtual = true,
            border_prefix = true,
            backgrounds = {
                'RenderMarkdownH1',
                'RenderMarkdownH2',
                'RenderMarkdownH3',
            },
            foregrounds = {
                'RenderMarkdownH1',
                'RenderMarkdownH2',
                'RenderMarkdownH3',
                'RenderMarkdownH4',
                'RenderMarkdownH5',
                'RenderMarkdownH6',
            },
        },
        code = {
            enabled = true,
            sign = true,
            position = 'left',
            right_pad = 20,
            language_name = true,
            width = 'block',
            border = 'thin',
            left_margin = 1,
            left_pad = 2,
            right_margin = 20,
            hl = 'RenderMarkdownCode',
            border_hl = 'RenderMarkdownCodeBorder',
        },
        link = {
            enabled = true,
            hl = 'RenderMarkdownLink',
        },
    }
}
