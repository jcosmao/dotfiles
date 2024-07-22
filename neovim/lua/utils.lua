local vim = vim

function plug_loaded(name)
    return vim.g.plugs[name] and vim.fn.isdirectory(vim.g.plugs[name].dir)
end

function hiera_encrypt()
    local git_root = vim.fn.system('git -C ' ..
        vim.fn.shellescape(vim.fn.expand("%:p:h")) .. ' rev-parse --show-toplevel'):match('(.*)\n')
    if vim.loop.fs_stat(git_root .. '/ovh-hiera-encrypt') then
        local message = vim.fn.system(':silent !' ..
            git_root .. '/ovh-hiera-encrypt -f ' .. vim.fn.shellescape(vim.fn.expand("%:p")))
        vim.cmd(':silent edit!')
        vim.cmd('echohl WarningMsg')
        vim.cmd('echo "hiera_encrypt: ' .. message .. '"')
        vim.cmd('echohl None')
    end
end

function mouse_toggle()
    if vim.o.mouse == 'a' then
        vim.o.mouse = ''
    else
        vim.o.mouse = 'a'
    end
end

vim.g.current_git_repo = ''
function set_git_repo()
    local current_file_path = vim.fn.resolve(vim.fn.expand('%:p:h'))
    local git_repo = vim.fn.system("cd " ..
        current_file_path .. "; basename -s .git $(git remote get-url origin 2> /dev/null) 2> /dev/null")
    local repo = git_repo:gsub('\n+$', '')
    if repo ~= '' then
        vim.g.current_git_repo = repo
    end
end

function is_special_filetype()
    local current_filetype = vim.bo.filetype
    for _, pattern in ipairs(special_filtetypes) do
        if vim.fn.match(current_filetype, pattern) ~= -1 then
            return true
        end
    end
    return false
end


vim.g.last_display_file_path = ""

function display_file_path()
    if not is_special_filetype() then
        if vim.g.last_display_file_path ~= vim.fn.expand('%:p') then
            print(string.format("File: %s", vim.fn.expand('%:p')))
            vim.g.last_display_file_path = vim.fn.expand('%:p')
        end
    end
end

function line_infos_toggle()
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

function diff_toggle()
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

function setup_diff_mapping()
    vim.cmd(':IBLDisable')
    if vim.fn.winnr() ~= vim.fn.winnr('h') then
        vim.api.nvim_set_keymap('n', '<leader><', ':diffput<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>>', ':diffget<cr>', { noremap = true, silent = true })
    else
        vim.api.nvim_set_keymap('n', '<leader>>', ':diffput<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><', ':diffget<cr>', { noremap = true, silent = true })
    end
end

function debug_toggle()
    if not vim.o.verbose then
        vim.o.verbosefile = '/tmp/nvim_debug.log'
        vim.o.verbose = 10
    else
        vim.o.verbose = 0
        vim.o.verbosefile = ''
    end
end

function load_vimscript_files(directory)
    local neovim_root = vim.fn.stdpath("config")
    local files = vim.fn.readdir(neovim_root .. "/" .. directory)
    for _, file in ipairs(files) do
        if file:match("%.vim$") then
            vim.cmd("source " .. neovim_root .. "/" .. directory .. "/" .. file)
        end
    end
end
