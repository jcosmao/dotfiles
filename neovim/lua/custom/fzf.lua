local vim = V

G.fzf_layout = { down = '60%' }
G.fzf_preview_window = { 'right:+{2}-/2', '?' }
G.fzf_action = {
    ['ctrl-t'] = 'tab split',
    ['ctrl-s'] = 'split',
    ['ctrl-v'] = 'vsplit',
}
vim.env.FZF_DEFAULT_OPTS = [[
    --ansi
    --layout reverse
    --preview-window right:60%,border-left
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --bind ?:toggle-preview,page-up:preview-up,page-down:preview-down,alt-up:page-up,alt-down:page-down,home:preview-top,end:preview-bottom
    --height=70%
    --margin 1,0
]]

local function get_rg_file_list_prefix()
    local project_root = FindRootDirectory()
    local file_list = '.*'

    if project_root then
        local project_file_list = string.format("%s/.project/file_list", project_root)
        local content = ReadFile(project_file_list)
        if content then file_list = content[1] end
    end

    -- ex file_list content to search only on python files:
    --      rg --files -tpy
    return string.format([[ %s | tr -s '\n' '\0' | xargs -0 ]], file_list)
end


vim.api.nvim_create_user_command("Rg",
    function(opts)
        local args = opts.args
        local rg_file_list_prefix = get_rg_file_list_prefix()
        vim.fn['fzf#vim#grep'](
            string.format(
                '%s rg --column --no-heading --line-number --color=always %s',
                rg_file_list_prefix, vim.fn.shellescape(args)
            ), 1,
            vim.fn['fzf#vim#with_preview']({
                options = '--delimiter ":" --exact --nth 4.. --prompt "Rg ❭ "'
            })
        )
    end,
    { nargs = '*', bang = false }
)

                -- options = string.format('--prompt "Rg [%s] ❭ " --delimiter ":" --exact --nth 4..', args)
vim.api.nvim_create_user_command("RgWithFilePath",
    function(opts)
        local args = opts.args
        local rg_file_list_prefix = get_rg_file_list_prefix()
        vim.fn['fzf#vim#grep'](
            string.format(
                '%s rg --column --no-heading --line-number --color=always %s',
                rg_file_list_prefix, vim.fn.shellescape(args)
            ), 1,
            vim.fn['fzf#vim#with_preview']({
                options = '--exact --prompt "RgWithFilePath ❭ "'
            })
        )
    end,
    { nargs = '*', bang = false }
)

function Fzf(search_str, source, options, callback)
    local fzf_run = vim.fn["fzf#run"]
    local fzf_wrap = vim.fn["fzf#wrap"]
    local default_opts = {
        '-1', '-0', '+i',
        '--exact',
        '--with-nth', '1',
        '--nth', '1',
        '--delimiter', '\t',
        '--ansi',
        '--preview-window', '+{3}-10'
    }

    local opts = options or default_opts

    local action_keys = {}
    for k in pairs(vim.g.fzf_action) do action_keys[#action_keys + 1] = k end
    table.insert(opts, "--expect=" .. table.concat(action_keys, ","))

    local function default_callback(lines, search)
        -- action key
        local key = lines[1]
        -- first selected line
        local line = lines[2]

        if line == nil or line == "" then
            return
        end

        -- default parsing expect format:
        -- {tag to search}\t{file path}\t{file line}
        local split = vim.split(line, "\t")
        -- local match = split[1]
        local file = split[2]
        local line_nb = split[3]

        -- action if any (e.g. split)
        local action = vim.g.fzf_action[key]
        if action then vim.cmd(action) end

        vim.cmd('e +' .. line_nb .. ' ' .. file)
        vim.cmd('call search("' .. search .. '", "", line("."))')
        vim.cmd('normal zz')
    end

    fzf_run(fzf_wrap({
        source = source,
        options = opts,
        sinklist = function(lines)
            if not callback then
                default_callback(lines, search_str)
            else
                callback(lines, search_str)
            end
        end,
    }))
end
