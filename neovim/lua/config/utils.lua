local vim = vim

vim.api.nvim_create_augroup('bufcheck', { clear = true })

-- Always quit nvimtree window when leaving tab by switching to previous file.
vim.api.nvim_create_autocmd('TabLeave', {
    group   = 'bufcheck',
    pattern = 'NvimTree*',
    command = 'wincmd p'
})

-- start git messages in insert mode
vim.api.nvim_create_autocmd('FileType', {
    group   = 'bufcheck',
    pattern = { 'gitcommit', 'gitrebase', },
    command = 'startinsert | 1'
})

-- pager mappings for Manual
vim.api.nvim_create_autocmd('FileType', {
    group    = 'bufcheck',
    pattern  = 'man',
    callback = function()
        vim.keymap.set('n', '<enter>', 'K', { buffer = true })
        vim.keymap.set('n', '<backspace>', '<c-o>', { buffer = true })
    end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
    group    = 'bufcheck',
    pattern  = '*',
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos('.', vim.fn.getpos("'\""))
            vim.cmd('silent! foldopen')
        end
    end
})

-- startup in diff mode ?
if vim.o.diff then
    setup_diff_mapping()
end

vim.api.nvim_create_user_command("DiffToggle", function()
    diff_toggle()
end, { nargs = 0 })

vim.api.nvim_create_autocmd({ "OptionSet" }, {
    pattern = "diff",
    callback = function()
        setup_diff_mapping()
    end
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "BufWritePost" }, {
    pattern = "*",
    callback = function()
        display_file_path()
        set_git_repo()
    end
})

vim.g.special_filtetypes = {
    'NvimTree', 'NvimTree_*',
    'aerial',
    'startify',
    'fzf',
    'Trouble', 'trouble',
    'Mason',
    'DiffviewFiles',
    'toggleterm', 'toggleterm*'
}

vim.api.nvim_create_user_command("HieraEncrypt", function()
    hiera_encrypt()
end, { nargs = 0 })

vim.api.nvim_create_user_command("MouseToggle", function()
    mouse_toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DebugToggle", function()
    debug_toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("LineInfosToggle", function()
    line_infos_toggle()
end, { nargs = 0 })



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
    local regexp = table.concat(vim.g.special_filtetypes, '|')
    if vim.fn.match(vim.bo.filetype, '^(' .. regexp .. ')$') == 0 or vim.bo.filetype == '' then
        return true
    else
        return false
    end
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
