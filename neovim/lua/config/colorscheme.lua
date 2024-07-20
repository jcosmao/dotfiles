local vim = vim

require 'colorizer'.setup({ 'css', 'javascript', 'vim', 'lua', })

require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    background = {         -- :h background
        light = "latte",
        dark = "macchiato",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
    term_colors = true,             -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false,            -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15,          -- percentage of the shade to apply to the inactive window
    },
    no_italic = false,              -- Force no italic
    no_bold = false,                -- Force no bold
    no_underline = true,            -- Force no underline
    styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },    -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
    },
})

vim.g.gruvbox_material_disable_italic_comment = 0
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_visual = 'grey background'
vim.g.gruvbox_material_menu_selection_background = 'blue'
vim.g.gruvbox_material_statusline_style = 'mix'
vim.g.gruvbox_material_better_performance = 0
vim.g.gruvbox_material_palette = 'material'
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_colors_override = {
    red = { '#b20007', '88' },
    orange = { '#ce4200', '130' },
    yellow = { '#c88214', '136' },
    green = { '#7c9413', '100' },
    aqua = { '#51986d', '165' },
    blue = { '#09859c', '24' },
    purple = { '#af528c', '96' },
}


function setColorscheme(mode)
    if mode == 'light' then
        vim.g.color_palette = vim.fn['gruvbox_material#get_palette'](vim.g.gruvbox_material_background,
            vim.g.gruvbox_material_palette, vim.g.gruvbox_material_colors_override)
        vim.g.terminal_color_0 = vim.g.color_palette.bg5[1]
        vim.g.terminal_color_7 = vim.g.color_palette.fg0[1]
        vim.g.terminal_color_8 = vim.g.color_palette.bg5[1]
        vim.g.terminal_color_15 = vim.g.color_palette.fg0[1]

        vim.cmd('colorscheme gruvbox-material')

        vim.fn.setenv('BAT_THEME', 'gruvbox-light')
        vim.api.nvim_set_hl(0, 'DiffText', { bg = '#f0e5ec', fg = 'NONE' })
        vim.api.nvim_set_hl(0, 'Search', { fg = '#FF8700', bg = 'NONE', bold = true })
        vim.api.nvim_set_hl(0, 'CurSearch', { fg = '#f5edca', bg = '#FF8700', bold = true })
        vim.api.nvim_set_hl(0, 'IncSearch', { fg = '#f5edca', bg = '#FF8700', bold = true })
        vim.api.nvim_set_hl(0, 'Substitute', { bg = '#FF8700', reverse = true, bold = true })
        vim.api.nvim_set_hl(0, 'FoldColumn', { fg = '#c8ad81' })
        vim.api.nvim_set_hl(0, 'MatchParen', { bg = '#dacc94' })
    else
        vim.cmd('colorscheme catppuccin')
        vim.fn.setenv('BAT_THEME', 'TwoDark')

        vim.api.nvim_set_hl(0, 'Search', { fg = '#d8ff00', bg = 'NONE', bold = true })
        vim.api.nvim_set_hl(0, 'CurSearch', { fg = '#202e52', bg = '#d8ff00', bold = true })
        vim.api.nvim_set_hl(0, 'IncSearch', { fg = '#202e52', bg = '#d8ff00', bold = true })
        vim.api.nvim_set_hl(0, 'Substitute', { bg = '#d8ff00', reverse = true, bold = true })
        vim.api.nvim_set_hl(0, 'FoldColumn', { fg = '#897e6c' })
    end

    vim.api.nvim_set_hl(0, 'ErrorFloat', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'WarningFloat', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'InfoFloat', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = 'NONE', bg = 'NONE' })
end

setColorscheme(vim.o.background)

function backgroundToggle()
    if vim.o.background == "light" then
        vim.o.background = "dark"
    else
        vim.o.background = "light"
    end
    setColorscheme(vim.o.background)
end

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "*",
    callback = function()
        vim.cmd("command! -nargs=0 BackgroundToggle lua backgroundToggle()")
    end
})
