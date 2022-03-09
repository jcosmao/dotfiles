" Ale
let g:ale_lint_on_enter = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_echo_msg_error_str = 'Error'
let g:ale_echo_msg_warning_str = 'Warning'
let g:ale_echo_msg_format = '[%linter%] [%code%] %s [%severity%]'
let g:ale_linters = {
\   'python': ['pflake8'],
\   'yaml': ['yamllint'],
\   'go': ['gometalinter', 'gofmt'],
\   'markdown': ['mdl'],
\}
" Ale autofix
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}
