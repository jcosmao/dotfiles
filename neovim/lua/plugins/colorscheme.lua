local vim = V
local M = {}

function M.lazy_config()
    return {
        {
            'sainnhe/gruvbox-material',
            priotity = 100,
            config = function()
                G.gruvbox_material_disable_italic_comment = 0
                G.gruvbox_material_enable_bold = 1
                G.gruvbox_material_enable_italic = 1
                G.gruvbox_material_visual = 'grey background'
                G.gruvbox_material_menu_selection_background = 'blue'
                G.gruvbox_material_statusline_style = 'mix'
                -- set to 1 fuck override
                G.gruvbox_material_better_performance = 0
                G.gruvbox_material_palette = 'material'
                G.gruvbox_material_background = 'hard'
                G.gruvbox_material_float_style = 'dim'
                G.gruvbox_material_diagnostic_virtual_text = 'colored'
                G.gruvbox_material_dim_inactive_windows = 0
                G.gruvbox_material_colors_override = {
                    bg0 = { '#f9efd5', '230' },
                    bg1 = { '#f7e2c6', '230' },
                    bg2 = { '#f5dec2', '230' },
                    bg3 = { '#ecd7b1', '230' },
                    bg4 = { '#eed8b7', '223' },
                    bg5 = { '#e6d2b0', '230' },
                    bg_statusline1 = { '#f5e6ca', '230' },
                    bg_statusline2 = { '#f3dfc7', '230' },
                    bg_statusline3 = { '#eed6b7', '230' },
                    bg_dim = { '#f3e5c7', '229' },
                    red = { '#b20007', '88' },
                    orange = { '#ce4200', '130' },
                    yellow = { '#c88214', '136' },
                    green = { '#7c9413', '100' },
                    aqua = { '#51986d', '165' },
                    blue = { '#09859c', '24' },
                    purple = { '#af528c', '96' },
                }
            end
        },
        {
            'catppuccin/nvim',
            priotity = 100,
            main = "catppuccin",
            opts = {
                flavour = "frappe",             -- latte, frappe, macchiato, mocha
                transparent_background = false, -- disables setting the background color.
                show_end_of_buffer = true,      -- shows the '~' characters after the end of buffers
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
            },
        },
        {
            'norcalli/nvim-colorizer.lua',
            priotity = 100,
            opts = { 'css', 'javascript', 'vim', 'lua', 'xml' }
        },
    }
end

function M.setColorscheme()
    local colors = {}

    if vim.o.background == 'light' then
        vim.cmd('colorscheme gruvbox-material')
        vim.fn.setenv('BAT_THEME', 'Gruvbox')

        G.gruvbox_material_colors = vim.fn['gruvbox_material#get_palette'](
            G.gruvbox_material_background,
            G.gruvbox_material_palette,
            G.gruvbox_material_colors_override
        )

        for k, v in pairs(G.gruvbox_material_colors) do
            colors[k] = v[1]
        end

        colors.search = '#FF8700'
        colors.bg = colors.bg0

        G.terminal_color_0 = colors.bg5
        G.terminal_color_7 = colors.fg0
        G.terminal_color_8 = colors.bg5
        G.terminal_color_15 = colors.fg0

        vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = '#6c85c0' })
        vim.api.nvim_set_hl(0, 'DiffText', { bg = '#f0e5ec', fg = colors.none })
        vim.api.nvim_set_hl(0, 'FoldColumn', { fg = colors.grey0 })
        vim.api.nvim_set_hl(0, 'MatchParen', { bg = '#dacc94' })
        vim.api.nvim_set_hl(0, "IblScope", { fg = colors.grey0 })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.orange })
    else
        vim.cmd('colorscheme catppuccin')
        vim.fn.setenv('BAT_THEME', 'Catppuccin Macchiato')

        colors = require('catppuccin.palettes').get_palette()
        colors.search = '#d8ff00'
        colors.none = 'NONE'
        colors.bg = colors.mantle

        vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.overlay1 })
        vim.api.nvim_set_hl(0, "IblScope", { fg = colors.overlay0 })
        vim.api.nvim_set_hl(0, "Comment", { fg = colors.overlay0 })
    end

    G.colors = colors

    M.highlight_override()
    IBLReload()
end

function M.highlight_override()

    vim.api.nvim_set_hl(0, 'Search', { fg = G.colors.search, bg = 'NONE', bold = true })
    vim.api.nvim_set_hl(0, 'CurSearch', { fg = G.colors.bg, bg = G.colors.search, bold = true })
    vim.api.nvim_set_hl(0, 'IncSearch', { fg = G.colors.bg, bg = G.colors.search, bold = true })
    vim.api.nvim_set_hl(0, 'Substitute', { bg = G.colors.search, reverse = true, bold = true })
    vim.api.nvim_set_hl(0, 'ErrorFloat', { bg = G.colors.none })
    vim.api.nvim_set_hl(0, 'WarningFloat', { bg = G.colors.none })
    vim.api.nvim_set_hl(0, 'InfoFloat', { bg = G.colors.none })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = G.colors.none })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = G.colors.none, bg = G.colors.none })

    G.fzf_colors = {
        ['bg+'] = { 'bg', 'CursorLine', 'CursorColumn' },
        bg      = { 'bg', 'Normal' },
        border  = { 'fg', 'NonText' },
        spinner = { 'fg', 'Yellow' },
        fg      = { 'fg', 'Normal' },
        pointer = { 'fg', G.colors.blue },
        info    = { 'fg', 'Aqua' },
        ['fg+'] = { 'fg', 'CursorLine', 'CursorColumn', 'Normal' },
        marker  = { 'fg', 'Yellow' },
        header  = { 'fg', '' },
        prompt  = { 'fg', 'Orange' },
        hl      = { 'fg', 'Search' },
        ['hl+'] = { 'fg', 'Search' }
    }

    vim.api.nvim_set_hl(0, 'TSDanger', { bg = '#fcccc8' })
    vim.api.nvim_set_hl(0, 'TSNote', { bg = '#e6f6a3' })
    vim.api.nvim_set_hl(0, '@comment.note', { bg = '#e6f6a3' })
    vim.api.nvim_set_hl(0, 'TSWarning', { bg = '#ffdead' })
    vim.api.nvim_set_hl(0, 'TSTodo', { bg = '#b8edff' })
    vim.api.nvim_set_hl(0, '@comment.todo', { bg = '#b8edff' })

    -- Python
    vim.api.nvim_set_hl(0, "@constant.python", { link = 'Label' })

    -- disable lsp hilight, let treesitter do its job
    local reset_hl_ignore = { "@lsp.type.namespace" }

    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        if not Contains(reset_hl_ignore, group) then
            vim.api.nvim_set_hl(0, group, {})
        end
    end
end

return M