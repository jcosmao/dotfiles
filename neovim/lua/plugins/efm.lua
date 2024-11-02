-- efm lsp configuration

local M = {}

local sh_fmt = {
    formatCommand = 'shfmt -i 4 -sr -ci -fn --filename ${INPUT}',
    formatStdin = true
}

local sh_lint = {
    lintCommand = 'shellcheck -f gcc -x -',
    lintStdin = true,
    lintFormats = { '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' },
    lintSource = 'shellcheck',
}

local prettier_fmt = {
    formatCommand = 'prettier --stdin-filepath ${INPUT}',
    formatStdin = true
}

local terraform_fmt = {
    formatCommand = 'tofu fmt -',
    formatStdin = true
}

local python_isort = {
    formatCommand = [[
        test -f $(git -C $(dirname ${INPUT}) rev-parse --show-toplevel 2> /dev/null)/.gitreview &&
        isort --quiet --lines-after-imports 2 -l 79 --profile open_stack - ||
        isort --quiet -
    ]],
    formatStdin = true,
}

local markdown_lint = {
    lintCommand = 'mdl ${INPUT}',
    lintStdin = true,
    lintFormats = { '%f:%l: %m' },
    lintSource = 'mdl',
    rootMarkers = { '.mdlrc' },
}

M.settings = {
    languages = {
        python = { python_isort },
        hcl = { terraform_fmt },
        terraform = { terraform_fmt },
        sh = { sh_fmt, sh_lint },
        markdown = { prettier_fmt, markdown_lint },
        json = { prettier_fmt },
        yaml = { prettier_fmt },
    },
    rootMarkers = { '.git/' },
}

return M
