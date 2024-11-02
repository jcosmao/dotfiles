V = vim
C = V.cmd
A = V.api
F = V.fn    -- Vim function
G = V.g     -- Vim globals
O = V.opt   -- Vim optionals

Border = "rounded"

SpecialFiltetypes = {
    'NvimTree', 'NvimTree_*',
    'aerial',
    'startify',
    'fzf',
    'Trouble', 'trouble',
    'Mason',
    'DiffviewFiles',
    'toggleterm', 'toggleterm*'
}

TermGrp = V.api.nvim_create_augroup("TermGrp", { clear = true })

function PrintTable(t)
    for k, v in pairs(t) do
        print("[" .. k .. "]", v)
    end
end

function IsSpecialFiletype()
    local current_filetype = V.bo.filetype
    for _, pattern in ipairs(SpecialFiltetypes) do
        if V.fn.match(current_filetype, pattern) ~= -1 then
            return true
        end
    end
    return false
end

function FoldedTextInfo()
    local fs = string.find(A.nvim_buf_get_lines(0, V.v.foldstart - 1, V.v.foldend, false)[1], '"label":')
    if fs == nil then
        return V.fn.foldtext()
    end
    local label = string.match(A.nvim_buf_get_lines(0, V.v.foldstart, V.v.foldstart + 1, false)[1],
        '"label":\\s+"([^"]+)"')
    local ft = string.gsub(V.fn.foldtext(), ': .+', label)
    return ft
end

function DebugToggle()
    if not V.o.verbose then
        V.o.verbosefile = '/tmp/nvim_debug.log'
        V.o.verbose = 10
    else
        V.o.verbose = 0
        V.o.verbosefile = ''
    end
end

function LoadVimscript(file)
    local neovim_root = V.fn.stdpath("config")
    local file_path = neovim_root .. "/vim/" .. file

    if V.fn.filereadable(file_path) then
        V.cmd("source " .. file_path)
    end
end
