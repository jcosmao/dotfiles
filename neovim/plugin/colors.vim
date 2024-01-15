lua require'colorizer'.setup({'css'; 'javascript'; 'vim';})

let g:gruvbox_material_disable_italic_comment = 0
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_visual = 'grey background'
let g:gruvbox_material_menu_selection_background = 'orange'
let g:gruvbox_material_statusline_style = 'mix'
let g:gruvbox_material_better_performance = 1

if &background ==# "light"
    " available: material / mix / original
    let g:gruvbox_material_palette = 'original'
    " available: soft / medium / hard
    let g:gruvbox_material_background = 'medium'
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
    " available: material / mix / original
    let g:gruvbox_material_palette = 'material'
    " available: soft / medium / hard
    let g:gruvbox_material_background = 'medium'
    let $BAT_THEME = 'gruvbox-dark'
    let g:gruvbox_material_colors_override = {}
    let s:match_paren = ['#3e6478',   '232']
endif

" for i in [0, 1, 2, 3, 4, 5, 6, 7 ,8 ,9 , 10, 11, 12, 13, 14, 15] | exec 'let g:terminal_color_' . i | endfor
let g:color_palette = gruvbox_material#get_palette(g:gruvbox_material_background, g:gruvbox_material_palette, g:gruvbox_material_colors_override)

let g:terminal_color_0 = g:color_palette.bg5[0]
let g:terminal_color_7 = g:color_palette.fg0[0]
let g:terminal_color_8 = g:color_palette.bg5[0]
let g:terminal_color_15 = g:color_palette.fg0[0]

colorscheme gruvbox-material

call gruvbox_material#highlight('MatchParen', g:color_palette.none, s:match_paren)

" override colorscheme config
" vimdiff
hi DiffAdd          guibg=#262626   guifg=#a9d1a9   gui=reverse
hi DiffDelete       guibg=#262626   guifg=#e09b9b   gui=reverse
hi DiffChange       guibg=#262626   guifg=#b6b6d9   gui=reverse
hi DiffText         guibg=#262626   guifg=#dec5d5   gui=reverse

" Search, signature current, ...
hi Search       guibg=#FF8700    gui=reverse,bold
hi CurSearch    guibg=#FF8700    guifg=#f5edca      gui=bold
hi IncSearch    guibg=#FF8700    guifg=#f5edca      gui=bold
hi Substitute   guibg=#FF8700    gui=reverse,bold

" Remove floating background color
hi ErrorFloat   guibg=None
hi WarningFloat guibg=None
hi InfoFloat    guibg=None
hi NormalFloat  guibg=None
hi FloatBorder  guifg=None guibg=None

hi WinBarActive gui=reverse guifg=#a9b665 guibg=#141617
hi Directory        guifg=#83A598

" Fix missing tree-sitter binding on colorscheme (gruvbox_material)
autocmd FileType sh :highlight! link TSVariable Blue
autocmd FileType sh :highlight! link TSConstant Blue

let s:palette = g:lightline#colorscheme#gruvbox_material#palette
let s:palette.tabline.tabsel = [ [ g:color_palette.bg0[0], g:color_palette.green[0] , 238, 10, 'bold' ] ]
unlet s:palette
