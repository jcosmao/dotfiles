let g:gruvbox_material_disable_italic_comment = 0
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_visual = 'grey background'
let g:gruvbox_material_menu_selection_background = 'green'
" available: material / mix / original
let g:gruvbox_material_palette = 'mix'
" available: soft / medium / hard
let g:gruvbox_material_background = 'medium'

colorscheme gruvbox-material

" override colorscheme config
hi WildMenu         ctermbg=208 ctermfg=16
" hi CursorLine       ctermbg=233 term=bold       cterm=bold              guibg=#121212   gui=bold
hi DiffAdd          ctermbg=235 ctermfg=108     cterm=reverse           guibg=#262626   guifg=#87AF87   gui=reverse
hi DiffChange       ctermbg=235 ctermfg=103     cterm=reverse           guibg=#262626   guifg=#8787AF   gui=reverse
hi DiffDelete       ctermbg=235 ctermfg=131     cterm=reverse           guibg=#262626   guifg=#AF5F5F   gui=reverse
hi DiffText         ctermbg=235 ctermfg=208     cterm=reverse           guibg=#262626   guifg=#FF8700   gui=reverse
hi Directory        ctermfg=12  guifg=#83A598
hi NERDTreeOpenable ctermfg=88  guifg=#870000
hi NERDTreeClosable ctermfg=9   guifg=#FB4934

" " override semshi colorscheme
hi semshiParameter  ctermfg=109 guifg=#83a598
hi semshiImported   ctermfg=210 guifg=#ff9741
hi semshiGlobal     ctermfg=214 guifg=#ffc649

" override tagbar colorscheme
hi default TagbarAccessPublic    guifg=Green     ctermfg=Green
hi default TagbarAccessProtected guifg=White     ctermfg=White
hi default TagbarAccessPrivate   guifg=Red       ctermfg=Red

hi NvimTreeNormal    guibg=#262626
hi NvimTreeVertSplit guibg=#262626 guifg=#262626
hi NvimTreeStatuslineNc guibg=#262626 guifg=#262626
hi NvimTreeEndOfBuffer guibg=#262626 guifg=#262626
hi TagbarHighlight guibg=#262626 guifg=#262626

" Fix missing tree-sitter binding on colorscheme (gruvbox_material)
autocmd FileType sh :highlight! link TSVariable Blue
autocmd FileType sh :highlight! link TSConstant Blue

let s:palette = g:lightline#colorscheme#gruvbox_material#palette
let s:palette.tabline.tabsel = [ [ '#282828', '#98971a', 238, 10, 'bold' ] ]
unlet s:palette
