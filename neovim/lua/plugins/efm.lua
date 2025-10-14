-- efm lsp configuration

local M = {}

local sh_fmt = {
    formatCommand = 'shfmt -i 4 -sr -ci -fn --filename ${INPUT}',
    formatStdin = true
}

local sh_lint = {
    lintSource = 'efm/shellcheck',
    lintCommand = 'shellcheck -f gcc -x -',
    lintStdin = true,
    lintFormats = { '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' },
}

local prettier_fmt = {
    formatCommand = 'prettier --stdin-filepath ${INPUT}',
    formatStdin = true
}

local terraform_fmt = {
    formatCommand = 'terraform fmt ${INPUT}',
    formatStdin = false
}

local python_isort = {
    formatCommand = [[
        test -f $(git -C $(dirname ${INPUT}) rev-parse --show-toplevel 2> /dev/null)/.gitreview &&
        isort --quiet --lines-after-imports 2 -l 79 --profile open_stack ${INPUT} ||
        isort --quiet ${INPUT}
    ]],
    formatStdin = true,
}

local markdown_lint = {
    lintSource = 'efm/mdl',
    lintCommand = 'mdl ${INPUT}',
    lintStdin = true,
    lintFormats = { '%f:%l: %m' },
    rootMarkers = { '.mdlrc' },
}

local flake8 = {
    lintSource = 'efm/flake8',
    lintCommand = 'flake8 -',
    lintIgnoreExitCode = true,
    lintStdin = true,
    lintFormats = { 'stdin:%l:%c: %t%n %m' },
    rootMarkers = { '.flake8' },
}

local pylint = {
    lintSource = 'efm/pylint',
    lintCommand = 'pylint --score=no "${INPUT}"',
    lintIgnoreExitCode = true,
    lintStdin = false,
    lintFormats = { '%.%#:%l:%c: %t%.%#: %m' },
    rootMarkers = {},
}

-- https://github.com/acrn/puppet-fmt
local puppet_fmt = {
    formatCommand = 'puppet-fmt --strict --verbose -i ${INPUT}',
    formatStdin = true
}

M.settings = {
    version = 2,
    languages = {
        python = { python_isort, flake8, pylint },
        hcl = { terraform_fmt },
        terraform = { terraform_fmt },
        sh = { sh_fmt, sh_lint },
        markdown = { prettier_fmt, markdown_lint },
        json = { prettier_fmt },
        yaml = { prettier_fmt },
        puppet = { puppet_fmt },
    },
    rootMarkers = { '.git/' },
}

return M
