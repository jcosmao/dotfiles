local vim = vim
local M = {}

function M.setup(args)
    -- create .project dir in project root dir to build tags automatically
    -- by default, tags will be generated for all files in this root dir
    -- To override files list for tags generate, add executable in .project/file_list
    -- that should return files list
    --
    vim.g.gutentags_project_root = { '.project' }
    vim.g.gutentags_exclude_project_root = {}
    vim.g.gutentags_exclude_filetypes = {
        'no', 'systemd',
        'gitcommit', 'git', 'gitconfig', 'gitrebase', 'gitsendemail',
        'cfg', 'conf', 'rst', 'dosini',
        'sh', 'yaml', 'json', 'text', 'markdown'
    }
    vim.g.gutentags_add_default_project_roots = 0
    vim.g.gutentags_generate_on_empty_buffer = 0
    vim.g.gutentags_resolve_symlinks = 1
    vim.g.gutentags_modules = { 'ctags', 'cscope' }
    vim.g.gutentags_ctags_executable = '~/.local/bin/ctags'
    vim.g.gutentags_ctags_extra_args = { '--fields=+niaSszt', '--python-kinds=-vi', '--tag-relative=yes' }
    vim.g.gutentags_file_list_command =
    '/bin/true ; .project/file_list || rg --files -tsh -tperl -tpy -tgo -tcpp -tpuppet -tjson -tyaml'
    vim.g.gutentags_scopefile = '.cscope.gutentags'
    vim.g.gutentags_scopefile_maps = '.cscope.gutentags'
    vim.g.gutentags_ctags_tagfile = '.ctags.gutentags'
    vim.g.gutentags_ctags_exclude = {
        '*.git', '*.svn', '*.hg',
        'cache', 'build', 'dist', 'bin', 'node_modules', 'bower_components',
        '*-lock.json', '*.lock',
        '*.min.*',
        '*.bak',
        '*.zip',
        '*.pyc',
        '*.class',
        '*.sln',
        '*.csproj', '*.csproj.user',
        '*.tmp',
        '*.cache',
        '*.vscode',
        '*.pdb',
        '*.exe', '*.dll', '*.bin',
        '*.mp3', '*.ogg', '*.flac',
        '*.swp', '*.swo',
        '.DS_Store', '*.plist',
        '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png', '*.svg',
        '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
        '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx', '*.xls',
    }
end

function GutentagsEnabled()
    if vim.b.gutentags_files == nil then
        vim.cmd('echohl WarningMsg')
        vim.cmd('echo "Gutentags disabled"')
        vim.cmd('echohl None')
        return false
    end
    return true
end

return M
