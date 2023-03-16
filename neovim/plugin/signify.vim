" Signify
let g:signify_priority = 5
let g:signify_update_on_bufenter    = 1
let g:signify_update_on_focusgained = 0

autocmd User SignifyHunk call s:show_current_hunk()

function! s:show_current_hunk() abort
  let h = sy#util#get_hunk_stats()
  if !empty(h)
    echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
  endif
endfunction
