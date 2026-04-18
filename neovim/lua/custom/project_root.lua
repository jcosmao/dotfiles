-- First get priority, other are fallback if first not found
local root_patterns = { '.project', '.git' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
    local path = GetCurrentDir()

    -- Try cache and resort to searching upward for root directory
    -- PrintTable(root_cache)

    local root = root_cache[path]
    if root == nil then
        local root_file = nil
        for _, root_pattern in ipairs(root_patterns) do
            root_file = vim.fs.find(root_pattern, { path = path, upward = true })[1]
            if root_file then break end
        end
        if root_file == nil then return end
        root = vim.fs.dirname(root_file)
        root_cache[path] = root
    end

    -- Set current directory
    vim.fn.chdir(root)

    return root
end

local function get_git_root()
    local root = vim.fn.trim(vim.fn.system(
        string.format('git -C %s rev-parse --show-toplevel 2> /dev/null', vim.fn.expand('%:h'))
    ))
    return vim.trim(root)
end


local root_augroup = vim.api.nvim_create_augroup('ProjectRoot', {})

vim.api.nvim_create_autocmd('VimEnter', {
    group = root_augroup,
    callback = function()
        G.project_root = set_root()
        G.git_root = get_git_root()
    end
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
    group = root_augroup,
    callback = function()
        if vim.bo.filetype == '' then return end
        if IsSpecialFiletype() then return end

        G.project_root = set_root()
        G.git_root = get_git_root()
        vim.cmd("silent! execute ':doautocmd User NvimTreeReload'")
    end
})
