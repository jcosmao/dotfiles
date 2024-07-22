local vim = vim

function PythonBlack()
    local opts = ""

    local is_openstack = tonumber(vim.fn.system("find . -maxdepth 2 -name .gitreview | wc -l"))
    if is_openstack > 0 then
        opts = "-l 79"
    end

    vim.fn.system("black " .. opts .. " " .. vim.fn.expand("%:p"))
    print("[Black] done")
end

function AutoColorColumn()
    if vim.bo.filetype == "python" then
        local project_root = vim.fn.FindRootDirectory()
        local git_root = vim.fn.trim(vim.fn.system('git -C ' ..
            vim.fn.expand('%:h') .. ' rev-parse --show-toplevel 2> /dev/null'))

        if project_root == "" and git_root == "" then
            return
        end

        local maxlinelen = vim.fn.trim(vim.fn.system('grep max-line-length $(find ' ..
            project_root ..
            ' ' ..
            git_root ..
            ' -maxdepth 1 -name pyproject.toml -o -name tox.ini -o -name .flake8) | awk -F= "{print $2}" | tail -1'))

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

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "python",
    callback = function()
        vim.cmd("command! -nargs=0 Black lua PythonBlack()")
    end
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = "*",
    callback = function()
        AutoColorColumn()
    end
})
