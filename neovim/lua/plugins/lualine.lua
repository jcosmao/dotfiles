return {
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {
                statusline = G.SpecialFiltetypes,
                winbar = {},
            },
            ignore_focus = G.SpecialFiltetypes,
            always_divide_middle = true,
            globalstatus = true,
            always_show_tabline = true,
            refresh = {
                statusline = 100,
                tabline = 100,
                winbar = 100,
            }
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                function()
                    return G.current_git_repo
                end,
                'branch',
                'diff',
            },
            lualine_c = {
                {
                    'filename',
                    path = 2,
                }
            },
            lualine_x = {
                'diagnostics',
                'encoding',
                'fileformat',
                'filetype'
            },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {
            lualine_a = {
                {
                    'filetype',
                    icon_only = true,
                    color = { bg = 'NONE' },
                },
            },
            lualine_b = {
                {
                    'tabs',
                    mode = 2,
                    max_length = vim.o.columns,
                    tabs_color = {
                        -- Same values as the general color option can be used here.
                        active = 'lualine_a_terminal',     -- Color for active tab.
                        inactive = 'lualine_a_inactive', -- Color for inactive tab.
                    },
                },
                {
                    function()
                        vim.o.showtabline = 2
                        return ''
                        --HACK: lualine will set &showtabline to 2 if you have configured
                        --lualine for displaying tabline. We want to restore the default
                        --behavior here.
                    end,
                },
            },
            lualine_z = {
                {
                    function()
                        if G.project_root then
                            return vim.fs.basename(G.project_root)
                        end
                    end,
                }
            }
        },
        winbar = {},
        inactive_winbar = {},
        extensions = {}
    }
}
