let g:gruvbox_material_disable_italic_comment = 0
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_visual = 'grey background'
let g:gruvbox_material_menu_selection_background = 'orange'
let g:gruvbox_material_statusline_style = 'mix'
let g:gruvbox_material_better_performance = 1
" available: material / mix / original
let g:gruvbox_material_palette = 'material'
" available: soft / medium / hard
let g:gruvbox_material_background = 'medium'

colorscheme gruvbox-material

" override colorscheme config
hi CursorLine       guibg=#2a373a   gui=bold
hi DiffAdd          guibg=#262626   guifg=#87AF87   gui=reverse
hi DiffChange       guibg=#262626   guifg=#8787AF   gui=reverse
hi DiffDelete       guibg=#262626   guifg=#AF5F5F   gui=reverse
hi DiffText         guibg=#262626   guifg=#FF8700   gui=reverse
hi Directory        guifg=#83A598

hi MatchParen guibg=#3e6478

" Search, signature current, ...
hi Search  guibg=#d69a22

" Remove floating background color
hi ErrorFloat   guibg=None
hi WarningFloat guibg=None
hi InfoFloat    guibg=None
hi NormalFloat  guibg=None
hi FloatBorder  guifg=None guibg=None

hi WinBarActive gui=reverse guifg=#a9b665 guibg=#141617

" override semshi colorscheme
hi semshiParameter  guifg=#83a598
hi semshiImported   guifg=#ff9741
hi semshiGlobal     guifg=#ffc649

hi NvimTreeNormal       guibg=#262626
hi NvimTreeVertSplit    guibg=#262626 guifg=#262626
hi NvimTreeStatuslineNc guibg=#262626 guifg=#262626
hi NvimTreeEndOfBuffer  guibg=#262626 guifg=#262626

" Fix missing tree-sitter binding on colorscheme (gruvbox_material)
autocmd FileType sh :highlight! link TSVariable Blue
autocmd FileType sh :highlight! link TSConstant Blue

let s:palette = g:lightline#colorscheme#gruvbox_material#palette
let s:palette.tabline.tabsel = [ [ '#282828', '#98971a', 238, 10, 'bold' ] ]
unlet s:palette
