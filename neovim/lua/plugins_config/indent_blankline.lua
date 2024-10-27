local hooks = require("ibl.hooks")
local hilight = { "focus" }

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    -- color defined in colorscheme.lua
    vim.api.nvim_set_hl(0, "focus", {})
end)

require("ibl").setup({
    indent = {
        char = "▏",
        tab_char = "▏",
    },
    scope = {
        show_start = false,
        show_end = false,
        highlight = highlight,
    },
})
