local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
})

-- vscode format
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load { paths = vim.g.vscode_snippets_path or "" }

-- snipmate format
require("luasnip.loaders.from_snipmate").load()
require("luasnip.loaders.from_snipmate").lazy_load { paths = vim.g.snipmate_snippets_path or "" }

-- lua format
require("luasnip.loaders.from_lua").load()
require("luasnip.loaders.from_lua").lazy_load { paths = vim.g.lua_snippets_path or "" }

ls.add_snippets('python', {
    ls.snippet(
		"osdebug",
		fmt(
			[[
        import logging
        for app in ["neutron", "neutron_lib", "networking_ovh",
                    "nova", "nova_ovh", "glance", "cinder",
                    "stevedore", "alembic", "oslo_db",
                    "oslo_policy", "oslo_messaging", "oslo_concurrency",
                    "ovsdbapp"]:
            logging.getLogger(app).setLevel(logging.DEBUG)
		]],
			{}
		)
	),
})

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        if
            require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
            and not require("luasnip").session.jump_active
        then
            require("luasnip").unlink_current()
        end
    end,
})

luasnip_list_available_snips = function()
    local ft_list = require("luasnip").available()
    local ft_snips = {}
    for _, item in pairs(ft_list[vim.o.filetype]) do
        table.insert(ft_snips, string.format("%-50s\t[%s]\t\t%s", item.trigger, vim.o.filetype, item.name))
    end
    for _, item in pairs(ft_list["all"]) do
        table.insert(ft_snips, string.format("%-50s\t[default]\t\t%s", item.trigger, item.name))
    end
    return ft_snips
end

vim.api.nvim_exec([[
    command! -bang -nargs=* Snippets
        \ call fzf#run(fzf#wrap({
            \ 'source': luaeval('luasnip_list_available_snips()'),
            \ 'sink': funcref('Luasnip_expand'),
            \ 'options': '--ansi --prompt "LuaSnip > "'
            \ }))

    function! Luasnip_expand(line) abort
        let snip = split(a:line, "\t")[0]
        execute 'normal! a'.trim(snip)."\<plug>luasnip-expand-or-jump"
    endfunction
]], false)
