return {
    'danymat/neogen',
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
        -- Enables Neogen capabilities
        enabled = true,
        -- Configuration for default languages
        languages = {},
        -- Use a snippet engine to generate annotations.
        snippet_engine = "luasnip",
        -- Enables placeholders when inserting annotation
        enable_placeholders = false,
    }
}
