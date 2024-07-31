local vim = vim

function HieraEncrypt()
    local git_root = vim.fn.system('git -C ' ..
        vim.fn.shellescape(vim.fn.expand("%:p:h")) .. ' rev-parse --show-toplevel'):match('(.*)\n')
    if vim.loop.fs_stat(git_root .. '/ovh-hiera-encrypt') then
        local message = vim.fn.system(':silent !' ..
            git_root .. '/ovh-hiera-encrypt -f ' .. vim.fn.shellescape(vim.fn.expand("%:p")))
        vim.cmd(':silent edit!')
        vim.cmd('echohl WarningMsg')
        vim.cmd('echo "HieraEncrypt: ' .. message .. '"')
        vim.cmd('echohl None')
    end
end

function MouseToggle()
    if vim.o.mouse == 'a' then
        vim.o.mouse = ''
    else
        vim.o.mouse = 'a'
    end
end

vim.g.current_git_repo = ''
function SetGitRepo()
    local current_file_path = vim.fn.resolve(vim.fn.expand('%:p:h'))
    local git_repo = vim.fn.system("cd " ..
        current_file_path .. "; basename -s .git $(git remote get-url origin 2> /dev/null) 2> /dev/null")
    local repo = git_repo:gsub('\n+$', '')
    if repo ~= '' then
        vim.g.current_git_repo = repo
    end
end

function IsSpecialFiletype()
    local current_filetype = vim.bo.filetype
    for _, pattern in ipairs(special_filtetypes) do
        if vim.fn.match(current_filetype, pattern) ~= -1 then
            return true
        end
    end
    return false
end


vim.g.last_display_file_path = ""

function DisplayFilePath()
    if not IsSpecialFiletype() then
        if vim.g.last_display_file_path ~= vim.fn.expand('%:p') then
            print(string.format("File: %s", vim.fn.expand('%:p')))
            vim.g.last_display_file_path = vim.fn.expand('%:p')
        end
    end
end

function LineInfosToggle()
    if vim.g.line_infos_status == nil then
        vim.g.line_infos_status = 1
    end

    if vim.g.line_infos_status == 0 then
        vim.o.number = true
        vim.cmd('silent! execute :IBLEnable')
        vim.cmd('silent! execute :SignifyEnable')
        vim.cmd('silent! execute :Gitsigns attach')
        vim.o.signcolumn = 'auto'
        vim.o.foldcolumn = '1'
        vim.g.line_infos_status = 1
        vim.o.conceallevel = 2
    else
        vim.o.number = false
        vim.cmd('silent! execute :IBLDisable')
        vim.cmd('silent! execute :SignifyDisable')
        vim.cmd('silent! execute :Gitsigns detach')
        vim.cmd('silent! execute :NvimTreeClose')
        vim.o.signcolumn = 'no'
        vim.o.foldcolumn = '0'
        vim.g.line_infos_status = 0
        vim.o.conceallevel = 0
    end
end

function DiffToggle()
    if vim.g.custom_diff_toggle == nil then
        vim.g.custom_diff_toggle = 0
    end

    if vim.g.custom_diff_toggle == 0 then
        vim.cmd(':NvimTreeClose')
        vim.cmd('windo diffthis')
        vim.g.custom_diff_toggle = 1
    else
        vim.cmd('windo diffoff')
        vim.g.custom_diff_toggle = 0
    end
end

function SetupDiffMapping()
    vim.cmd(':IBLDisable')
    if vim.fn.winnr() ~= vim.fn.winnr('h') then
        vim.api.nvim_set_keymap('n', '<leader><', ':diffput<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>>', ':diffget<cr>', { noremap = true, silent = true })
    else
        vim.api.nvim_set_keymap('n', '<leader>>', ':diffput<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><', ':diffget<cr>', { noremap = true, silent = true })
    end
end

function DebugToggle()
    if not vim.o.verbose then
        vim.o.verbosefile = '/tmp/nvim_debug.log'
        vim.o.verbose = 10
    else
        vim.o.verbose = 0
        vim.o.verbosefile = ''
    end
end

function LoadVimscript(file)
    local neovim_root = vim.fn.stdpath("config")
    local file_path = neovim_root .. "/vim/" .. file

    if vim.fn.filereadable(file_path)  then
        vim.cmd("source " .. file_path)
    end
end

function PatchPlugin(patch)
    local script = vim.fn.stdpath("config") .. "/plugin_patch/patch.sh"
    vim.fn.system({script, patch})
end

function PythonBlack()
    local opts = ""

    local is_openstack = tonumber(vim.fn.system("find . -maxdepth 2 -name .gitreview | wc -l"))
    if is_openstack > 0 then
        opts = "-l 79"
    end

    vim.fn.system("black " .. opts .. " " .. vim.fn.expand("%:p"))
    print("[Black] done")
end

require("project_root")

function AutoColorColumn()
    if vim.bo.filetype == "python" then
        local project_root = FindRootDirectory()
        local git_root = vim.fn.trim(vim.fn.system('git -C ' .. vim.fn.expand('%:h') .. ' rev-parse --show-toplevel 2> /dev/null'))

        if project_root == "" and git_root == "" then
            return
        end

        local cmd = "grep max-line-length $(find " .. project_root .. " " .. git_root .. " -maxdepth 1 -name pyproject.toml -o -name tox.ini -o -name .flake8) | awk -F= '{print $2}' | tail -1"
        local maxlinelen = vim.fn.trim(vim.fn.system(cmd))

        if maxlinelen ~= "" then
            vim.cmd('set colorcolumn=' .. maxlinelen)
            return
        end

        -- Force 79 char max for openstack projects
        if vim.loop.fs_stat(git_root .. '/.gitreview') then
            vim.cmd('set colorcolumn=79')
            return
        end
    end

    if vim.bo.filetype == "gitcommit" then
        vim.cmd('set colorcolumn=72')
        return
    end

    -- reset colorcolumn
    vim.cmd('set colorcolumn=')
end
