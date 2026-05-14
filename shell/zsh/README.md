# zenv

A Zsh module for loading `.zenv` files in directory hierarchies. Similar to `direnv` but simpler and built for Zsh.

## Features

- Automatically loads `.zenv` files when entering directories
- **Stacks environment variables**: parent `.zenv` variables are preserved when entering child directories
- Loads all `.zenv` files in the path from root to current directory
- Restores previous environment when leaving directories

## Installation

Source this file in your `.zshrc`:

```zsh
source "$HOME/.dotfiles/shell/zsh/zenv.zsh"
```

## Usage

1. Create a `.zenv` file in any directory:

   ```zsh
   # ~/.zenv or /path/to/project/.zenv
   export MY_VAR="value"
   export PATH="$PATH:/custom/path"
   ```

2. The `.zenv` file is automatically loaded when you `cd` into that directory
3. When entering a subdirectory with its own `.zenv`, **both** the parent and child `.zenv` files are loaded, with child variables taking precedence

## How it works

- On shell startup and every `cd`, `zenv` scans from the current directory up to root
- All `.zenv` files found are sourced in order (root first, then children)
- Environment is saved before loading and restored when leaving
- Variables from parent `.zenv` files are preserved

## Example

```
/
└── home/
    └── user/
        ├── .zenv          # exports FOO=bar
        │
        └── projects/
            ├── .zenv     # exports BAZ=qux
            │
            └── myapp/
                └── .zenv # exports MY_VAR=123
```

When you `cd ~/projects/myapp`:
- `FOO=bar` (from ~/)
- `BAZ=qux` (from ~/projects/)
- `MY_VAR=123` (from ~/projects/myapp/)

All three are available simultaneously.

## Functions

- `_direnv_find_all_zenv()`: Finds all `.zenv` files from root to current directory
- `_direnv_save_env()`: Saves current environment state
- `_direnv_restore_env()`: Restores previously saved environment
- `_direnv_load_zenv()`: Main function that loads appropriate `.zenv` files
- `_direnv_chpwd()`: Hook that triggers on directory change

## Notes

- Only works in interactive Zsh shells
- Variables set in `.zenv` files persist in the shell session
- To reload manually, run `_direnv_load_zenv`
