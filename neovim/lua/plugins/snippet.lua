local custom_osdebug = [[
import logging
for app in ["neutron", "neutron_lib", "networking_ovh",
            "nova", "nova_ovh", "glance", "cinder",
            "stevedore", "alembic", "oslo_db",
            "oslo_policy", "oslo_messaging", "oslo_concurrency",
            "ovsdbapp"]:
    logging.getLogger(app).setLevel(logging.DEBUG)
]]

local custom_logtrace = [[
__import__('logging').getLogger().error(
    '\n'.join(__import__('traceback').format_stack())
)
]]


return {
    {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        version = "v2.*",
        dependencies = {
            "rafamadriz/friendly-snippets"
        },
        config = function()
            local ls = require("luasnip")
            local fmt = require("luasnip.extras.fmt").fmt

            ls.setup({
                update_events = {"TextChanged", "TextChangedI"},
                region_check_events = {"CursorMoved", "InsertEnter"},
                delete_check_events = {"TextChanged", "InsertLeave"},
            })

            -- vscode format
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load {
                paths = vim.g.vscode_snippets_path or ""
            }

            -- snipmate format
            require("luasnip.loaders.from_snipmate").load()
            require("luasnip.loaders.from_snipmate").lazy_load {
                paths = vim.g.snipmate_snippets_path or ""
            }

            -- lua format
            require("luasnip.loaders.from_lua").load()
            require("luasnip.loaders.from_lua").lazy_load {
                paths = vim.g.lua_snippets_path or ""
            }

            ls.add_snippets('python', {
                ls.snippet(
                    "osdebug",
                    fmt(custom_osdebug, {})
                ),
                ls.snippet(
                    "logtrace",
                    fmt(custom_logtrace, {})
                ),
                ls.snippet(
                    "logerr",
                    fmt(
                        [[__import__('logging').getLogger().error(f"{}")]], { ls.insert_node(1) }
                    )
                ),
            })
        end
    },
}
