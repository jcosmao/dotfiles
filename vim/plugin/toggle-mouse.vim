if exists("b:loaded_toggle_mouse_plugin")
    finish
endif
let b:loaded_toggle_mouse_plugin = 1

fun! ToggleMouse()
    if !exists("s:old_mouse")
        let s:old_mouse = "a"
    endif

    if &mouse == ""
        let &mouse = s:old_mouse
        echo "Mouse is for Vim (" . &mouse . ")"
    else
        let s:old_mouse = &mouse
        let &mouse=""
        echo "Mouse is for terminal"
    endif
endfunction
