local vim = vim

vim.g.startify_change_to_dir = 0
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_dir = '~/.cache/vim/session'
vim.g.startify_session_persistence = 1
vim.g.startify_session_before_save = {
    'echo "Cleaning up before saving.."',
    'silent! NERDTreeTabsClose',
    'silent! NERDTreeClose',
    'silent! Vista!',
}
vim.g.startify_bookmarks = {}
vim.g.startify_lists = {
    { type = 'files',     header = { '   Files' } },
    { type = 'sessions',  header = { '   Sessions' } },
    { type = 'bookmarks', header = { '   Bookmarks' } },
}
