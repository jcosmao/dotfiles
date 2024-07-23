require("globals")
require("utils")
require("project_root")

-- nvim options
require("settings")
-- nvim mapping
require("keybindings")

-- load vimscripts from vim dir
load_vimscript_files("vim")
-- lazy install
require("plugins")
-- setup plugins
require("plugins_config")
-- apply custom patches on modules
plugins_patch()

-- load autocommand
require('autocommand')
