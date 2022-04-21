require("nvim-treesitter.install").prefer_git = false
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {"cuda", "dart", "eex", "fennel", "foam", "fusion", "heex", "hocon", "julia", "ledger", "llvm", "pascal", "pioasm", "prisma", "pug", "rasl", "supercollider", "surface", "svelte", "teal", "tlaplus", "turtle", "vala", "verilog", "zig", "astro", "beancount", "bibtex", "cooklang", "elm", "elvish", "fortran", "gdscript", "gleam", "glimmer", "glsl", "hack", "haskell", "lalrpop", "ninja", "pioasm", "rego", "solidity", "swift", "wgsl", "yang"}, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  incremental_selection = { enable = true },
}
