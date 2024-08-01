local vim = vim
local fzf_run = vim.fn["fzf#run"]
local fzf_wrap = vim.fn["fzf#wrap"]

vim.g.fzf_layout = { down = '60%' }
vim.g.fzf_preview_window = { 'right:hidden', '?' }

local function get_openstack_query_filter()
    local current_file = vim.fn.expand('%:p')
    if current_file:match('/tests/') then
        return '/tests/ '
    else
        return '!/tests/ '
    end
end

vim.env.FZF_DEFAULT_OPTS =
"--ansi --layout reverse --preview-window right:60% --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down --height=60% --margin 1,1"

vim.api.nvim_create_user_command(
    "Rg",
    function(opts)
        local args = opts.args
        local bang = opts.bang
        vim.fn['fzf#vim#grep'](
            'rg --no-ignore --column --no-heading --line-number --color=always ' .. vim.fn.shellescape(args), 1,
            vim.fn['fzf#vim#with_preview']({ options = '--delimiter ":" --exact --nth 4..' }), bang
        )
    end,
    { nargs = '*', bang = true }
)

vim.api.nvim_create_user_command(
    "RgWithFilePath",
    function(opts)
        local args = opts.args
        local bang = opts.bang
        vim.fn['fzf#vim#grep'](
            'rg --no-ignore --column --no-heading --line-number --color=always ' .. vim.fn.shellescape(args), 1,
            vim.fn['fzf#vim#with_preview']({ options = '--exact' }), bang
        )
    end,
    { nargs = '*', bang = true }
)


-- Get ctags

local function ctags_cmd(search_str, tag_file)
    -- [1] ref
    -- [2] file
    -- [3]
    -- [4] kind
    -- [5] line
    local grep_pattern = 'grep -v "^!_TAG"'
    if search_str then
        grep_pattern = string.format('grep -P "^%s\\t"', search_str)
    end
    return string.format(
        'cat %s | %s | sed -e "s,\tline:,\t,g"', tag_file, grep_pattern
    )
end

local function ctags_fzf_opts(search_str)
    search_str = search_str or '.*'
    local fzf_opts = {
        '--prompt', 'Ctags [' .. search_str .. '] > ',
        '-1', '-0', '+i',
        '--exact',
        '--with-nth', '1,4,2',
        '--nth', '1',
        '--delimiter', '\t',
        '--preview-window', '+{5}-15',
        '--preview', 'bat --color always --highlight-line {5} {2}'
    }
    return fzf_opts
end

local function ctags_callback(line)
    if line == nil or line == "" then
        return
    end
    local split = vim.split(line, "\t")
    local ref = split[1]
    local file = split[2]
    local line_num = split[5]
    vim.cmd('e +' .. line_num .. ' ' .. file)
    vim.cmd('call search("' .. ref .. '", "", line("."))')
    vim.cmd('normal zz')
end

function FZFLuaCtags(search_str, tag_file)
    fzf_run(fzf_wrap("ctags", {
        source = ctags_cmd(search_str, tag_file),
        options = ctags_fzf_opts(search_str),
        sinklist = function(lines)
            ctags_callback(lines[1])
        end
    }))
end

-- Cscope

local function cscope_cmd(search_str, tag_file)
    -- [1] file
    -- [2] function
    -- [3] line
    -- [5]+ target
    return string.format(
        'cscope -d -L -f %s -0 %s | sed -e "s,^%s/,," | grep -Pv "\\d+\\s\\s*(\\#|:|\\")" | grep -Pv "(class|def|func|function|sub) %s"',
        tag_file,
        search_str,
        vim.fn.getcwd(),
        search_str
    )
end

local function cscope_fzf_opts(search_str)
    local fzf_opts = {
        '--query', get_openstack_query_filter(),
        '--prompt', 'Cscope [' .. search_str .. '] > ',
        '-1', '-0', '+i',
        '--exact',
        '--with-nth', '1',
        '--nth', '1',
        '--delimiter', ' ',
        '--preview-window', '+{3}-15',
        '--preview', 'bat --color always --highlight-line {3} {1}'
    }
    return fzf_opts
end

local function cscope_callback(line)
    if line == nil or line == "" then
        return
    end
    local split = vim.split(line, " ")
    local file = split[1]
    local line_num = split[3]
    vim.cmd('e +' .. line_num .. ' ' .. file)
    vim.cmd('call search("' .. vim.fn.expand('<cword>') .. '", "", line("."))')
    vim.cmd('normal zz')
end

function FZFLuaCscope(search_str, tag_file)
    fzf_run(fzf_wrap("cscope", {
        source = cscope_cmd(search_str, tag_file),
        options = cscope_fzf_opts(search_str),
        sinklist = function(lines)
            cscope_callback(lines[1])
        end
    }))
end

function GotoCtags(tag, ctx_line)
    if not GutentagsEnabled() then
        return
    end

    if vim.bo.filetype == 'puppet' then
        tag = tag:gsub('^::', '')
    end

    if vim.bo.filetype == 'perl' then
        tag = tag:match('.*::(.*)$')
    end

    FZFLuaCtags(tag, vim.b.gutentags_files['ctags'])
end

function GotoCscope(tag, ctx_line)
    if GutentagsEnabled() then
        FZFLuaCscope(tag, vim.b.gutentags_files['cscope'])
    end
end

vim.api.nvim_create_user_command(
    "FZFCtags",
    function()
        if GutentagsEnabled() then
            FZFLuaCtags(nil, vim.b.gutentags_files['ctags'])
        end
    end,
    { nargs = '*', bang = true }
)
