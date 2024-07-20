local vim = vim

-- The XTermPasteBegin function sets the pastetoggle and paste options to enable pasting without the need to manually set paste.
-- Finally, the script sets up an insert mode keymap that calls the XTermPasteBegin function when the <Esc>[200~ sequence is received.

function XTermPasteBegin()
    vim.o.pastetoggle = "\27[201~"
    vim.o.paste = true
    return ""
end

vim.api.nvim_set_keymap("i", "\27[200~", "<C-R>=luaeval('XTermPasteBegin()')<CR>", { noremap = true, expr = true })
