G = vim.g -- Vim globals

G.Border = "rounded"

-- Utils functions

function PrintTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            PrintTable(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end

function Contains(pattern_table, val)
    for _, value in ipairs(pattern_table) do
        local pattern = string.format('^%s$', value)
        if string.match(val, pattern) then
            return true
        end
    end
    return false
end

function FileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

--- Check if a file or directory exists in this path
function Exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function ReadFile(file)
    if not FileExists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

function LoadVimscript(file)
    local neovim_root = vim.fn.stdpath("config")
    local file_path = neovim_root .. "/vim/" .. file

    if vim.fn.filereadable(file_path) then
        vim.cmd("source " .. file_path)
    end
end

--

local function gen_special_filetypes()
    local special_ft = {}
    local special_ft_pattern = {
        'NvimTree', 'NvimTree_*',
        'aerial',
        'startify',
        'fzf',
        'Trouble', 'trouble',
        'Mason',
        'DiffviewFiles',
        'toggleterm', 'toggleterm*'
    }

    for _, f in pairs(special_ft_pattern) do
        if string.match(f, '*') then
            for i = 1, 10 do
                local sub, _ = string.gsub(f, '*', i)
                table.insert(special_ft, sub)
            end
        else
            table.insert(special_ft, f)
        end
    end

    return special_ft
end

G.SpecialFiletypes = gen_special_filetypes()

function IsSpecialFiletype()
    local current_filetype = vim.bo.filetype
    for _, pattern in ipairs(G.SpecialFiletypes) do
        if vim.fn.match(current_filetype, pattern) ~= -1 then
            return true
        end
    end
    return false
end

function FoldedTextInfo()
    local fs = string.find(vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldend, false)[1], '"label":')
    if fs == nil then
        return vim.fn.foldtext()
    end
    local label = string.match(
        vim.api.nvim_buf_get_lines(0, vim.v.foldstart, vim.v.foldstart + 1, false)[1], '"label":\\s+"([^"]+)"'
    )
    local ft = string.gsub(vim.fn.foldtext(), ': .+', label)
    return ft
end

function GetCurrentDir()
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

    return path
end
