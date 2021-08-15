" Python - jedi-vim  (autocompletion disabled)
let g:jedi#auto_initialization = 1
let g:jedi#show_call_signatures = 0
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#popup_on_dot = 1
let g:jedi#completions_command = ""
let g:jedi#goto_command = ""
let g:jedi#goto_stubs_command = ""
let g:jedi#goto_assignments_command = ""
let g:jedi#usages_command = "]"
let g:jedi#documentation_command = ""
let g:jedi#rename_command = "<leader>r"


"----- show documentation in floaterm window from https://github.com/neovim/neovim/issues/1004
if has('nvim')
	autocmd FileType python nnoremap <buffer> ? :call PyDocVim()<CR>

	let s:pyscript = resolve(expand('<sfile>:p:h')) . '/jedi_doc.py'

    function! PyDocVim()
        execute 'py3file '. s:pyscript

	   	let $FZF_DEFAULT_OPTS .= ' --border --margin=0,2'
	   	let width = float2nr(&columns * 0.9)
	   	let height = float2nr(&lines * 0.6)
	   	let opts = { 'relative': 'editor',
				   \ 'row': (&lines - height) / 2,
				   \ 'col': (&columns - width) / 2,
				   \ 'width': width,
  				   \ 'height': height,
  				   \ 'border': 'rounded',
				   \ 'style': 'minimal' }

	   	let buf = nvim_create_buf(v:false, v:true)
	   	let lines = py3eval('text')
	   	call nvim_buf_set_lines(buf, 0, -1, v:true, split(lines, '\n'))
	   	let winid = nvim_open_win(buf, v:true, opts)
		call setbufvar(winbufnr(winid), '&syntax','rst')
	    call setwinvar(winid, '&winhighlight', 'NormalFloat:Normal')
		call nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>',
			\ {'silent': v:true, 'nowait': v:true, 'noremap': v:true})

   endfunction
endif
