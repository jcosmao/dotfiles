local vim = V

-- First get priority, other are fallback if first not found
local root_names = { '.project', '.git' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
    -- Get directory path to start search from
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then return end
    path = vim.fs.dirname(path)

    -- Try cache and resort to searching upward for root directory
    -- PrintTable(root_cache)

    local root = root_cache[path]
    if root == nil then
        local root_file = nil
        for _, root_name in ipairs(root_names) do
            root_file = vim.fs.find(root_name, { path = path, upward = true })[1]
            if root_file then break end
        end
        if root_file == nil then return end
        root = vim.fs.dirname(root_file)
        root_cache[path] = root
    end

    -- Set current directory
    vim.fn.chdir(root)
end

function FindRootDirectory()
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then return end
    path = vim.fs.dirname(path)

    set_root()

    if root_cache[path] then
        return root_cache[path]
    else
        return path
    end
end

local root_augroup = vim.api.nvim_create_augroup('ProjectRoot', {})

vim.api.nvim_create_autocmd(
    'BufEnter', {
        group = root_augroup,
        callback = set_root
    }
)

vim.api.nvim_create_autocmd(
    'VimEnter', {
        group = root_augroup,
        callback = set_root
    }
)
