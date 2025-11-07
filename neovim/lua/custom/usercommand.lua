vim.api.nvim_create_user_command("Plug", function()
    plugin_dir = vim.fn.stdpath("data") .. "/lazy"
    vim.fn.system(string.format('mkdir -p %s/.project', plugin_dir))
    vim.cmd('cd ' .. plugin_dir)
    vim.cmd('enew')
    local api = require("nvim-tree.api")
    api.tree.open()
end, { nargs = 0 })

vim.api.nvim_create_user_command("F", function()
    print(string.format("File: " .. GetFileFullPath()))
end, { nargs = 0 })

vim.api.nvim_create_user_command("Memo", function()
    vim.api.nvim_command('tabnew ' .. vim.fn.stdpath("config") .. '/help.md')
end, { nargs = 0 })

vim.api.nvim_create_user_command("HieraEncrypt", function()
    HieraEncrypt()
end, { nargs = 0 })

vim.api.nvim_create_user_command("MouseToggle", function()
    MouseToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DebugToggle", function()
    DebugToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("LineInfosToggle", function()
    LineInfosToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Black", function(opts)
    -- opts.args contains the arguments passed to the command
    PythonBlack(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command("BackgroundToggle", function()
    BackgroundToggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DiffToggle", function()
    DiffToggle()
end, { nargs = 0 })


vim.api.nvim_create_user_command("Markdown", function()
    vim.api.nvim_command("RenderMarkdown")
end, { nargs = 0 })

vim.api.nvim_create_user_command('DiffOpendev20231', function ()
    vim.cmd('DiffviewOpen opendev/stable/2023.1')
end, { nargs = 0 })
