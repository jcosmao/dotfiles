local vim = vim

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 25
vim.opt.foldnestmax = 20
vim.opt.foldcolumn = "1"
vim.opt.foldtext = "v:lua.fold_text()"

function fold_text()
    local fs = string.find(vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldend, false)[1], '"label":')
    if fs == nil then
        return vim.fn.foldtext()
    end
    local label = string.match(vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldstart + 1, false)[1],
        '"label":\\s+"([^"]+)"')
    local ft = string.gsub(vim.fn.foldtext(), ': .+', label)
    return ft
end
