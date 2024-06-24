-- Blame

require('blame').setup({
	virtual_style = "float",
})

-- Cscope maps

require("cscope_maps").setup()

-- NeoGen

require("neogen").setup({
    -- Enables Neogen capabilities
    enabled = true,
    -- Configuration for default languages
    languages = {},
    -- Use a snippet engine to generate annotations.
    snippet_engine = "luasnip",
    -- Enables placeholders when inserting annotation
    enable_placeholders = false,
})


-- Indent BlankLine

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

-- AutoPairs

require("nvim-autopairs").setup {}

-- DiffView

local actions = require("diffview.actions")

require("diffview").setup({
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      { {"n", "i"}, "<F1>", actions.toggle_files,                   { desc = "Toggle the file panel." } },
    },
  },
})
