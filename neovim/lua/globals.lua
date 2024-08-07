cmd = vim.cmd; -- Command function
api = vim.api; -- Neovim API
lsp = vim.lsp; -- LSP API
fn = vim.fn;   -- Vim function
g = vim.g;     -- Vim globals
opt = vim.opt; -- Vim optionals

special_filtetypes = {
    'NvimTree', 'NvimTree_*',
    'aerial',
    'startify',
    'fzf',
    'Trouble', 'trouble',
    'Mason',
    'DiffviewFiles',
    'toggleterm', 'toggleterm*'
}
