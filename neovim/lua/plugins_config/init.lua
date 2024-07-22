-- load all .lua
-- require('config.a')

-- Get the base directory
local base_dir = vim.fn.stdpath("config") .. "/lua/plugins_config/"

-- Iterate through all files in the base directory
for _, file in ipairs(vim.fn.readdir(base_dir)) do
    -- Check if the file is a Lua file (ends with .lua) and is not init.lua
    if file:sub(-4) == ".lua" and file ~= "init.lua" then
        -- Construct the module name from the file name
        local module_name = file:sub(1, -5):gsub("/", ".")
        -- Require the module
        require("plugins_config." .. module_name)
    end
end
