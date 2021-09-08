" vim-go
let g:go_debug = ['shell-commands']
let g:go_fmt_command = "goimports"  "Auto :GoImports
let g:go_autodetect_gopath = 1
let g:go_list_type = "quickfix"
let g:go_def_mapping_enabled = 0

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_methods = 1
let g:go_highlight_generate_tags = 1

" guru, godef, gopls
let g:go_def_mode = 'gopls'
