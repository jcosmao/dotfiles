vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        -- fix weird issue when vim is launched with file as parameter, ft is not detected
        -- force redetect
        vim.cmd("filetype detect")
    end,
})

-- remove trailing whitespaces
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
    pattern  = '*',
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos('.', vim.fn.getpos("'\""))
            vim.cmd('silent! foldopen')
        end
    end
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "BufWritePost" }, {
    pattern = "*",
    callback = function()
        if not IsSpecialFiletype() then
            SetGitRepo()
        end
    end
})

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufEnter", "InsertEnter" }, {
    pattern = "*",
    callback = function()
        AutoColorColumn()

        if vim.o.diff then
            SetupDiffMapping()
        end
    end
})

-- Close nvimtree and Trouble when diffview mode is opened
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "Diffview*",
    callback = function()
        vim.cmd(":NvimTreeClose")
        vim.cmd(":Trouble close")
        vim.diagnostic.disable()
        vim.keymap.set({ 'n', 'i' }, '<F1>', ':DiffviewToggleFiles <cr>', { buffer = true })
    end
})

--
-- Terminal
--

G.TermFiletypes = { 'fzf', 'toggleterm', 'term://*' }

vim.api.nvim_create_autocmd("Filetype", {
    pattern = G.TermFiletypes,
    callback = function()
        vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            buffer = 0, -- Le buffer actuel
            callback = function()
                vim.cmd("startinsert")
            end,
        })
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter", "TermLeave", "TermOpen" }, {
    pattern = '*',
    callback = function()
        if Contains(G.TermFiletypes, vim.bo.filetype) then
            vim.opt.timeoutlen = G.terminal_timeoutlen
        else
            vim.opt.timeoutlen = G.timeoutlen
        end
    end
})


--
-- NvimTree
--

-- Always quit nvimtree window when leaving tab by switching to previous file.
vim.api.nvim_create_autocmd('TabLeave', {
    pattern = 'NvimTree*',
    command = 'wincmd p'
})

vim.api.nvim_create_autocmd({ 'BufReadCmd' }, {
    pattern = { 'NvimTree*', 'aerial' },
    command = 'bufdelete'
})

-- doautocmd User NvimTreeReload
vim.api.nvim_create_autocmd("User", {
    group    = vim.api.nvim_create_augroup('NvimTreeReload', { clear = true }),
    pattern  = "NvimTreeReload",
    callback = function()
        local api = require("nvim-tree.api")
        if api.tree.winid() then
            api.tree.find_file({ update_root = true, open = false, focus = false, })
            -- api.tree.reload()
        end
    end
})

-- quit if nvimtree is last opened buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "NvimTree*",
    callback = function()
        local layout = vim.api.nvim_call_function("winlayout", {})
        if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
            vim.cmd("confirm quit")
        end
    end
})

--
-- Filetypes
--

-- start git messages in insert mode
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'git*',
    command = 'startinsert | 1'
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "puppet" },
    callback = function()
        vim.opt_local.iskeyword = vim.opt_local.iskeyword + ":"
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "yaml" },
    callback = function()
        vim.opt_local.indentkeys = vim.opt_local.indentkeys - "<:>"
        vim.opt_local.indentkeys = vim.opt_local.indentkeys - ":"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "javascript", "terraform" },
    callback = function()
        vim.opt_local.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "sh",
    callback = function()
        vim.opt_local.iskeyword = vim.opt_local.iskeyword + "$"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.api.nvim_set_keymap("n", "<leader><BS>", ":GoCodeLenAct<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<leader>=", ":GoIfErr<cr>", { noremap = true, silent = true })

        -- Auto import on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = 0, -- Le buffer actuel
            callback = function()
                vim.lsp.buf.code_action({
                    context = { only = { 'source.organizeImports' } },
                    apply = true
                })
            end,
        })
    end,
})

vim.api.nvim_create_autocmd("Filetype", {
    pattern = { "json", "markdown" },
    callback = function()
        vim.api.nvim_create_autocmd("InsertEnter", {
            buffer = 0, -- Le buffer actuel
            callback = function()
                vim.opt_local.conceallevel = 0
            end,
        })

        vim.api.nvim_create_autocmd("InsertLeave", {
            buffer = 0, -- Le buffer actuel
            callback = function()
                vim.opt_local.conceallevel = 2
            end,
        })
    end,
})

--fix terraform and hcl comment string
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FixTerraformCommentString", { clear = true }),
  callback = function(ev)
    vim.bo[ev.buf].commentstring = "# %s"
  end,
  pattern = { "terraform", "hcl" },
})

vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = '*',
  callback = function()
    if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
        and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require('luasnip').session.jump_active
    then
      require('luasnip').unlink_current()
    end
  end
})

vim.api.nvim_create_autocmd('VimLeave', {
    callback = function()
        TruncateLspLog()
    end,
})


