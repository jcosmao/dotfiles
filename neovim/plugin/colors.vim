:lua << EOF
require'colorizer'.setup({'css'; 'javascript'; 'vim';})

require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "macchiato",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
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
        gitsigns = false,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
    },
})

EOF

let g:gruvbox_material_disable_italic_comment = 0
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_visual = 'grey background'
let g:gruvbox_material_menu_selection_background = 'orange'
let g:gruvbox_material_statusline_style = 'mix'
let g:gruvbox_material_better_performance = 0

if &background ==# "light"
    let g:colorscheme = 'gruvbox-material'
    let g:gruvbox_material_palette = 'material'
    let g:gruvbox_material_background = 'hard'
    let $BAT_THEME = 'gruvbox-light'
    let g:gruvbox_material_colors_override = {
    \   'red':              ['#b20007',   '88'],
    \   'orange':           ['#ce4200',   '130'],
    \   'yellow':           ['#c88214',   '136'],
    \   'green':            ['#7c9413',   '100'],
    \   'aqua':             ['#51986d',   '165'],
    \   'blue':             ['#09859c',   '24'],
    \   'purple':           ['#af528c',   '96'],
    \ }
    let s:match_paren = ['#dacc94', '229']
else
    let g:colorscheme = 'catppuccin'
    let g:gruvbox_material_palette = 'material'
    let g:gruvbox_material_background = 'medium'
    let $BAT_THEME = 'TwoDark'
    let g:gruvbox_material_colors_override = {}
    let s:match_paren = ['#6a665f',   '232']
endif

" for i in [0, 1, 2, 3, 4, 5, 6, 7 ,8 ,9 , 10, 11, 12, 13, 14, 15] | exec 'let g:terminal_color_' . i | endfor
let g:color_palette = gruvbox_material#get_palette(g:gruvbox_material_background, g:gruvbox_material_palette, g:gruvbox_material_colors_override)
let g:terminal_color_0 = g:color_palette.bg5[0]
let g:terminal_color_7 = g:color_palette.fg0[0]
let g:terminal_color_8 = g:color_palette.bg5[0]
let g:terminal_color_15 = g:color_palette.fg0[0]

exec 'colorscheme ' . g:colorscheme

call gruvbox_material#highlight('MatchParen', g:color_palette.none, s:match_paren)
let s:palette = g:lightline#colorscheme#gruvbox_material#palette
let s:palette.tabline.tabsel = [ [ g:color_palette.bg0[0], g:color_palette.green[0] , 238, 10, 'bold' ] ]
unlet s:palette

" override colorscheme config

" Signify gutter
hi SignifyLineAdd guifg=#a9d1a9
hi SignifyLineDelete guifg=#e09b9b
hi SignifyLineChange guifg=#b6b6d9
hi SignifySignAdd guifg=#a9d1a9
hi SignifySignDelete guifg=#e09b9b
hi SignifySignChange guifg=#b6b6d9

" Remove floating background color
hi ErrorFloat   guibg=None
hi WarningFloat guibg=None
hi InfoFloat    guibg=None
hi NormalFloat  guibg=None
hi FloatBorder  guifg=None guibg=None

if &background ==# "light"
    hi DiffText     guibg=#f0e5ec    guifg=none
    hi Search       guifg=#FF8700    guibg=none         gui=bold
    hi CurSearch    guibg=#FF8700    guifg=#f5edca      gui=bold
    hi IncSearch    guibg=#FF8700    guifg=#f5edca      gui=bold
    hi Substitute   guibg=#FF8700    gui=reverse,bold
    hi FoldColumn   guifg=#c8ad81
else
    hi Search       guifg=#d8ff00    guibg=             gui=bold
    hi CurSearch    guibg=#d8ff00    guifg=#202e52      gui=bold
    hi IncSearch    guibg=#d8ff00    guifg=#202e52      gui=bold
    hi Substitute   guibg=#d8ff00    gui=reverse,bold
    hi FoldColumn   guifg=#897e6c
endif
