local virtual_text_default = {
    format = function(diagnostic)
        local lines = vim.split(diagnostic.message, '\n')
        return lines[1]
    end,
    virt_text_pos = 'right_align',
    suffix = ' ',
    prefix = "■",
    spacing = 10,
}

vim.diagnostic.config({
    underline = false,
    update_in_insert = true,
    float = {
        focusable = true,
        style = "minimal",
        border = G.Border,
        source = "always",
        header = "",
        prefix = "",
    },
    -- virtual_text = virtual_text_default,
    -- disable by default
    virtual_text = false,
})

-- display config
-- :lua vim.diagnostic.config()
function DiagnosticVirtualTextToggle()
    if not vim.diagnostic.config().virtual_text then
        vim.diagnostic.config({ virtual_text = virtual_text_default })
        vim.notify("diagnostic.virtual_text enabled")
    else
        vim.diagnostic.config({ virtual_text = false })
        vim.notify("diagnostic.virtual_text disabled")
    end
end

function DiagnosticToggle()
    if vim.diagnostic.is_disabled() then
        vim.diagnostic.enable()
        vim.notify("diagnostic enabled")
    else
        vim.diagnostic.disable()
        vim.notify("diagnostic disabled")
    end
end

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
