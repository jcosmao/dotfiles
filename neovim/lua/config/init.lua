-- load all .lua
-- require('config.a')

-- Get the base directory
local base_dir = vim.fn.stdpath("config") .. "/lua/config/"

-- first require utils, as it has common variables and functions
require("config.utils")

-- Iterate through all files in the base directory
for _, file in ipairs(vim.fn.readdir(base_dir)) do
    -- Check if the file is a Lua file (ends with .lua) and is not init.lua
    if file:sub(-4) == ".lua" and file ~= "init.lua" then
        -- Construct the module name from the file name
        local module_name = file:sub(1, -5):gsub("/", ".")
        -- Require the module
        require("config." .. module_name)
    end
end
