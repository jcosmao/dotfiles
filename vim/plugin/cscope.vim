" Function to pipe cscope result to fzf
" and open selected file at right line

function! Cscope_fzf_sink_open_file(lines)
  let data = split(a:lines)
  let file = split(data[0], ":")
  execute 'e ' . '+' . file[1] . ' ' . file[0]
endfunction

function! Cscope_find(option, query)
  let color = '{ x = $1; $1 = ""; z = $3; $3 = ""; printf "\033[34m%s\033[0m:\033[31m%s\033[0m\011\033[37m%s\033[0m\n", x,z,$0; }'
  let opts = {
  \ 'source':  "cscope -d -L -f " . b:gutentags_files['cscope'] . " -" . a:option . " " . a:query . " | awk '" . color . "'",
  \ 'sink':  function('Cscope_fzf_sink_open_file'),
  \ 'options': ['--ansi',
  \             '--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
  \             '--color', 'fg:188,fg+:222,bg+:#3a3a3a,hl+:104'],
  \ 'down': '40%'
  \ }
  call fzf#run(opts)
endfunction