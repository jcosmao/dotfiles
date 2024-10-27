local M = {}
local actions = require("diffview.actions")

function M.setup(args)
    require("diffview").setup({
        keymaps = {
            disable_defaults = false, -- Disable the default keymaps
            view = {
                -- The `view` bindings are active in the diff buffers, only when the current
                -- tabpage is a Diffview.
                { { "n", "i" }, "<F1>", actions.toggle_files, { desc = "Toggle the file panel." } },
            },
        },
    })
end

return M
