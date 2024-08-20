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
    formatCommand = 'terraform fmt -',
    formatStdin = true
}

local openstack_isort = {
    formatCommand = 'isort --quiet --profile open_stack -',
    formatStdin = true,
    rootMarkers = { '.gitreview' },
}

-- local python_isort = {
--     formatCommand = 'isort --quiet -',
--     formatStdin = true,
--     rootMarkers = { 'pyproject.toml' },
-- }

local markdown_lint = {
    lintCommand = 'mdl ${INPUT}',
    lintStdin = true,
    lintFormats = { '%f:%l: %m' },
    lintSource = 'mdl',
    rootMarkers = { '.mdlrc' },
}

local efm_languages = {
    python = { openstack_isort },
    hcl = { terraform_fmt },
    terraform = { terraform_fmt },
    sh = { sh_fmt, sh_lint },
    markdown = { prettier_fmt, markdown_lint },
    json = { prettier_fmt },
    yaml = { prettier_fmt },
}

M.settings = {
    languages = efm_languages
}

return M
