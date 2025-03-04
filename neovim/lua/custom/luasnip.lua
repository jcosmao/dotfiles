vim.api.nvim_create_user_command("Snippets",
    function(opts)
        local fzf_opts = {
            '-1', '-0', '+i',
            '--exact',
            '--with-nth', '1,2,3',
            '--nth', '1,2',
            '--delimiter', '\t',
            '--ansi',
            '--preview-window', 'nowrap,hidden'
        }

        local function luasnip_list()
            local ft_list = require("luasnip").available()
            local ft_snips = {}
            for _, item in pairs(ft_list[vim.o.filetype]) do
                table.insert(ft_snips, string.format("%-50s\t[%s]\t%s", item.trigger, vim.o.filetype, item.name))
            end
            for _, item in pairs(ft_list["all"]) do
                table.insert(ft_snips, string.format("%-50s\t[default]\t%s", item.trigger, item.name))
            end
            return ft_snips
        end

        local function expand_callback(lines)
            local line = lines[2]
            local split = vim.split(line, "\t")
            local snip = vim.trim(split[1])
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { snip })
            require("luasnip").expand()
        end

        Fzf(".*", luasnip_list(), fzf_opts, expand_callback)
    end,
    { nargs = '*', bang = true }
)
