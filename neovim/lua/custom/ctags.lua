local function gutentags_enabled()
    if vim.b.gutentags_files == nil then
        vim.cmd('echohl WarningMsg')
        vim.cmd('echo "Gutentags disabled"')
        vim.cmd('echohl None')
        return false
    end
    return true
end

local function ctags_cmd(search_str, tag_file)
    local line_number = vim.fn.line('.')
    local filename = vim.fn.expand('%:.')
    -- return ctags list in format:
    -- {tag}\t{filepath}\t{line}\t{function}\t{kind}
    local cmd = string.format(
        [[
            cat %s | grep -v '^!_TAG' | grep -P '^%s\t' | sed -e 's,\tline:,\t,g' |
            awk -vF=%s -vL=%s -F"\t" -vBLUE=$(tput setaf 4) -vRES=$(tput sgr0) '{
                if ($1 != F || $3 != L) print BLUE $1 RES "\t" $2 "\t" $5 "\t" $6 "\t" $4 "\t"
            }'
        ]],
        tag_file, search_str, filename, line_number
    )
    -- print(cmd)
    return cmd
end

local function cscope_cmd(search_str, mode, tag_file)
    -- {tag}\t{filepath}\t{line}\t{function}
    local line_number = vim.fn.line('.')
    local filename = vim.fn.expand('%:.')
    local cmd = string.format(
        [[
            cscope -d -f %s -L -%d '%s' | sed -e 's,^%s/,,' | grep -Pv '\d+\s\s*(#|:|")' |
            awk -vF=%s -vL=%s -vBLUE=$(tput setaf 4) -vRES=$(tput sgr0) '{
                if ($1 != F || $3 != L) print substr($0,index($0,$4)) "\t" BLUE $1 RES "\t" $3 "\t" $2 "\t"
            }'
        ]],
        -- grep -Pv '(class|def|func|function|sub) %s' |
        tag_file, mode, search_str, vim.fn.getcwd(), filename, line_number
    )
    -- print(cmd)
    return cmd
end

function FZFLuaCtags(search_str, tag_file)
    search_str = search_str or ".*"
    local fzf_opts = {
        '--prompt', string.format("Ctags [%s] ❭ ", search_str),
        '-1', '-0', '+i',
        '--exact',
        -- display kind tag and filepath
        '--with-nth', '5,1,2',
        -- filter only on second element
        '--nth', '2',
        '--delimiter', '\t',
        '--ansi',
        '--preview-window', 'nohidden:+{3}-10',
        '--preview', 'bat  --color always --italic-text always --style header,grid,numbers --highlight-line {3} {2}'
    }
    Fzf(search_str, ctags_cmd(search_str, tag_file), fzf_opts)
end

function FZFLuaCscope(search_str, mode, tag_file)
    -- 0 Find this symbol:
    -- 1 Find this function definition:
    -- 2 Find functions called by this function:
    -- 3 Find functions calling this function:
    -- 4 Find this text string:
    -- 5 Change this text string:
    -- 6 Find this egrep pattern:
    -- 7 Find this file:
    -- 8 Find files #including this file:
    if not mode then mode = 0 end
    if not search_str then
        search_str = ".*"
        mode = 6
    end
    search_str = search_str or ".*"
    local fzf_opts = {
        '--prompt', string.format("Cscope [%s] ❭ ", search_str),
        '--query', FZFQueryFilterTests(),
        '-1', '-0', '+i',
        '--exact',
        '--with-nth', '2,4',
        -- filter only on first element of nth
        '--nth', '1',
        '--delimiter', '\t',
        '--ansi',
        '--preview-window', 'nohidden:+{3}-10',
        '--preview', 'bat  --color always --italic-text always --style header,grid,numbers --highlight-line {3} {2}'
    }

    Fzf(search_str, cscope_cmd(search_str, mode, tag_file), fzf_opts)
end

function GotoCtags(tag, ctx_line)
    if not gutentags_enabled() then
        return
    end

    if vim.bo.filetype == 'puppet' then
        tag = string.gsub(tag, '^::', '')
    end

    if vim.bo.filetype == 'perl' then
        local ftag = string.match(tag, '.*::(.*)$')
        if ftag then tag = ftag end
    end

    FZFLuaCtags(tag, vim.b.gutentags_files['ctags'])
end

function GotoCscope(tag, ctx_line)
    if gutentags_enabled() then
        FZFLuaCscope(tag, 0, vim.b.gutentags_files['cscope'])
    end
end

vim.api.nvim_create_user_command("FZFCtags",
    function(opts)
        if gutentags_enabled() then
            FZFLuaCtags(nil, vim.b.gutentags_files['ctags'])
        end
    end,
    { nargs = '*', bang = true }
)

vim.api.nvim_create_user_command("FZFCscope",
    function(opts)
        local args = vim.split(opts.args, " ")
        local search_str = args[1]
        local mode = args[2]
        if gutentags_enabled() then
            FZFLuaCscope(search_str, mode, vim.b.gutentags_files['cscope'])
        end
    end,
    { nargs = '*', bang = true }
)
