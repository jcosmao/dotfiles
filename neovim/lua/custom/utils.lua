function DebugToggle()
    if not vim.o.verbose then
        vim.o.verbosefile = '/tmp/nvim_debug.log'
        vim.o.verbose = 10
        print("Logging in /tmp/nvim_debug.log")
    else
        vim.o.verbose = 0
        vim.o.verbosefile = ''
    end
end

function HieraEncrypt()
    local git_root = vim.fn.trim(vim.fn.system(
        'git -C ' .. vim.fn.expand('%:h') .. ' rev-parse --show-toplevel 2> /dev/null'
    ))

    if vim.loop.fs_stat(git_root .. '/ovh-hiera-encrypt') then
        local encrypt_cmd = string.format("%s/ovh-hiera-encrypt -f %s", git_root,
            vim.fn.shellescape(vim.fn.expand("%:p")))
        local message = vim.fn.system(encrypt_cmd)

        vim.cmd(':silent edit!')
        vim.cmd('echohl WarningMsg')
        print(encrypt_cmd)
        print(message)
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

function SetGitRepo()
    if G.current_git_repo == nil then
        G.current_git_repo = ""
    end

    local current_file_path = vim.fn.resolve(vim.fn.expand('%:p:h'))
    local cmd = string.format([[
        basename -s .git $(git -C %s remote get-url origin 2> /dev/null) 2> /dev/null
    ]], current_file_path)
    local git_repo = vim.fn.system(cmd)
    local repo = git_repo:gsub('\n+$', '')
    if repo ~= '' then
        G.current_git_repo = repo
    end
end

function GetFileFullPath()
    if not IsSpecialFiletype() then
        return vim.fn.expand('%:p')
    end
end

function LineInfosToggle()
    if G.line_infos_status == nil then
        G.line_infos_status = 1
    end

    if G.line_infos_status == 0 then
        vim.o.number = true
        vim.cmd('silent! execute ":IBLEnable"')
        vim.cmd('silent! execute ":SignifyEnable"')
        vim.cmd('silent! execute ":Gitsigns attach"')
        vim.cmd('silent! execute ":RenderMarkdown enable"')
        vim.o.signcolumn = 'auto'
        vim.o.foldcolumn = '1'
        vim.o.conceallevel = 2
        require('statuscol').setup()

        G.line_infos_status = 1
    else
        vim.o.number = false
        vim.cmd('silent! execute ":IBLDisable"')
        vim.cmd('silent! execute ":SignifyDisable"')
        vim.cmd('silent! execute ":Gitsigns detach"')
        vim.cmd('silent! execute ":RenderMarkdown disable"')
        vim.o.statuscolumn = ""
        vim.o.signcolumn = 'no'
        vim.o.foldcolumn = '0'
        vim.o.conceallevel = 0

        G.line_infos_status = 0
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

function IsOpenstackProject()
    local is_openstack = tonumber(vim.fn.system("find . -maxdepth 2 -name .gitreview | wc -l"))
    if is_openstack > 0 then
        return true
    else
        return false
    end
end

function PythonBlack()
    local opts = ""

    if IsOpenstackProject() then
        opts = "-l 79"
    end

    vim.fn.system("black " .. opts .. " " .. vim.fn.expand("%:p"))
    -- reload current file
    vim.cmd('edit!')
    print("[Black] done")
end

function AutoColorColumn()
    if vim.bo.filetype == "python" then
        if G.project_root == "" and G.git_root == "" then
            return
        end

        local cmd = string.format([[
            grep max-line-length $(find %s %s -maxdepth 1 -name pyproject.toml -o -name tox.ini -o -name .flake8) |
            awk -F= '{print $2}' | tail -1
        ]], G.project_root, G.git_root)

        local maxlinelen = vim.fn.trim(vim.fn.system(cmd))

        if maxlinelen ~= "" then
            vim.o.colorcolumn = maxlinelen
            return
        end

        -- Force 79 char max for openstack projects
        if FileExists(G.git_root .. '/.gitreview') then
            vim.o.colorcolumn = "79"
            return
        end
    end

    if vim.bo.filetype == "gitcommit" then
        vim.o.colorcolumn = "72"
        return
    end

    -- reset colorcolumn
    vim.o.colorcolumn = ""
end

function BackgroundToggle()
    if vim.o.background == "light" then
        vim.o.background = "dark"
    else
        vim.o.background = "light"
    end

    require("plugins.colorscheme").setColorscheme()
end

function Startify()
    vim.cmd("Startify")
    vim.cmd("only")
end
