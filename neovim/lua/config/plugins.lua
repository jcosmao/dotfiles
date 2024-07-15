-- Blame

require('blame').setup({
    date_format = "%d.%m.%Y",
    virtual_style = "right",
    views = {
        window = window_view,
        virtual = virtual_view,
        default = window_view,
    },
    merge_consecutive = false,
    max_summary_width = 30,
    colors = nil,
    commit_detail_view = "vsplit",
    mappings = {
        commit_info = "i",
        stack_push = "<TAB>",
        stack_pop = "<BS>",
        show_commit = "<CR>",
        close = { "<esc>", "q" },
    }
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

-- Close nvimtree and Trouble when diffview mode is opened
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DiffviewOpen", {clear = true}),
    pattern = "Diffview*",
    callback = function()
        vim.cmd(":NvimTreeClose")
        vim.cmd(":Trouble close")
        vim.diagnostic.disable()
        vim.keymap.set({'n', 'i'}, '<F1>', ':DiffviewToggleFiles <cr>', {buffer=true})
    end
})

vim.api.nvim_create_user_command('Opendev20231', 'DiffviewOpen opendev/stable/2023.1', {})



-- Git Messenger

vim.g.git_messenger_floating_win_opts = {
    border = "rounded"
}


-- Vim rooter

vim.g.rooter_patterns = { '.project/', '.project', '.git' }
vim.g.rooter_resolve_links = 1
vim.g.rooter_silent_chdir = 1
