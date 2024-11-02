local vim = V

return {
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add          = { text = '▐' },
                change       = { text = '▐' },
                delete       = { text = '▐' },
                topdelete    = { text = '▐' },
                changedelete = { text = '▐' },
                untracked    = { text = '▐' },
            },
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "right_align",
                virt_text_priority = 1,
                delay = 2000,
                ignore_whitespace = false,
            },
            signcolumn = true,
            watch_gitdir = {
                follow_files = true
            },
            attach_to_untracked = true,

            on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', '<leader>>', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']c', bang = true })
                    else
                        gitsigns.nav_hunk('next')
                    end
                end)

                map('n', '<leader><', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end)

                -- Actions
                map('n', '<leader>G', function() gitsigns.blame_line { full = true } end)
                map('n', 'gv', gitsigns.preview_hunk)
                map('n', 'gs', gitsigns.stage_hunk)
                map('n', 'gr', gitsigns.reset_hunk)
                map('n', 'gu', gitsigns.undo_stage_hunk)
                map('n', 'gS', gitsigns.stage_buffer)
                map('n', 'gR', gitsigns.reset_buffer)
                map('n', 'gd', gitsigns.diffthis)
            end
        }
    },
    {
        'FabijanZulj/blame.nvim',
        opts = {
            date_format = "%d.%m.%Y",
            virtual_style = "right",
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
        }
    },
    {
        'sindrets/diffview.nvim',
        config = function()
            local actions = require("diffview.actions")
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
    },
}
