local scope = "focus"
local hooks = require("ibl.hooks")

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    local bg = vim.o.background
    if bg == "dark" then
        vim.api.nvim_set_hl(0, "focus", { fg = "#7486bd" })
    else
        vim.api.nvim_set_hl(0, "focus", { fg = "#c8a66d" })
    end
end)

require("ibl").setup({
    indent = {
        char = "▏",
        tab_char = "▏",
    },
    scope = {
        show_start = false,
        show_end = false,
        highlight = scope,
    },
})

