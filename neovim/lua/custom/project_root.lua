-- First get priority, other are fallback if first not found
local root_patterns = { '.project', '.git' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
    -- Get directory path to start search from
    local path = vim.api.nvim_buf_get_name(0)
    if not path then
        path = vim.loop.cwd()
    else
        path = vim.fs.dirname(path)
    end

    if path == '.' then
        path = vim.trim(vim.fn.system("pwd"))
    end

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

local root_augroup = vim.api.nvim_create_augroup('ProjectRoot', {})

vim.api.nvim_create_autocmd('VimEnter', {
    group = root_augroup,
    callback = function()
        G.project_root = set_root()
    end
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
    group = root_augroup,
    callback = function()
        if vim.bo.filetype == '' then return end
        if IsSpecialFiletype() then return end

        G.project_root = set_root()
        vim.cmd("silent! execute ':doautocmd User NvimTreeReload'")
    end
})
