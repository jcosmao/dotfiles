local vim = vim

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.compatible = false
vim.opt.filetype = "off"
vim.opt.filetype = "plugin"
vim.opt.syntax = "off"
vim.opt.mouse = "a"
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.magic = true
vim.opt.ruler = true
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cmdheight = 2
vim.opt.signcolumn = "auto"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.backspace = "indent,eol,start"
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 0
vim.opt.expandtab = true
vim.opt.directory = "/tmp"
vim.opt.wildmode = "full"
vim.opt.wildmenu = true
vim.opt.autoread = true
vim.opt.undodir = vim.fn.expand("~/.cache/vim/undodir")
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.undoreload = 100000
vim.opt.history = 1000
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 100
vim.opt.hidden = true
vim.opt.autowriteall = true
vim.opt.autochdir = false
vim.opt.keymodel = "startsel"
vim.opt.diffopt = vim.opt.diffopt + "vertical"
vim.opt.conceallevel = 0
vim.opt.numberwidth = 6
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.pumheight = 20
vim.opt.termguicolors = true
vim.opt.conceallevel = 2

if vim.fn.empty(vim.env.THEME) == 0 then
    vim.opt.background = vim.env.THEME
else
    vim.opt.background = "light"
end

-- Set python path if pyenv is installed
if vim.fn.filereadable(vim.fn.expand('~') .. '/.pyenv/versions/nvim/bin/python') then
    vim.g.nvim_python_path = vim.fn.expand('~') .. '/.pyenv/versions/nvim/bin'
    vim.g.python3_host_prog = vim.g.nvim_python_path .. '/python'
    vim.env.PATH = vim.g.nvim_python_path .. ':' .. vim.env.PATH
end

vim.g.node_host_prog = vim.fn.expand('~') .. '/.local/bin/npm'

if vim.fn.has('python3') == 0 then
    vim.cmd('echohl WarningMsg')
    print('Missing python3 support - need to pip install pynvim')
    vim.cmd('echohl None')
end

vim.filetype.add({
  -- Detect and assign filetype based on the extension of the filename
  extension = {
    lib = "sh",
    source = "sh",
    pp = "puppet",
    inc = "perl",
    conf = "ini",
    tf = "terraform",
  },
})
