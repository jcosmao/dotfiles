return {
    "declancm/cinnamon.nvim",
    version = "*", -- use latest release
    opts = {
        disable = false,
        keymaps = {
            basic = true,
            extra = true,
        },

        ---@class ScrollOptions
        options = {
            -- The scrolling mode
            -- `cursor`: animate cursor and window scrolling for any movement
            -- `window`: animate window scrolling ONLY when the cursor moves out of view
            mode = "window",

            -- Only animate scrolling if a count is provided
            count_only = false,

            -- Delay between each movement step (in ms)
            delay = 5,

            max_delta = {
                -- Maximum distance for line movements before scroll
                -- animation is skipped. Set to `false` to disable
                line = false,
                -- Maximum distance for column movements before scroll
                -- animation is skipped. Set to `false` to disable
                column = false,
                -- Maximum duration for a movement (in ms). Automatically scales the
                -- delay and step size
                time = 1000,
            },

            step_size = {
                -- Number of cursor/window lines moved per step
                vertical = 100,
                -- Number of cursor/window columns moved per step
                horizontal = 2,
            },
        },
    },
    config = function(opts)
        require("cinnamon").setup(opts)
        SetupScrollKeybinding()
    end,
}
