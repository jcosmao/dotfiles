require("globals")
require("utils")
require("project_root")

-- nvim options
require("settings")

-- lazy install
require("plugins")
-- setup plugins
require("plugins_config")
-- apply custom patches on modules
plugins_patch()

-- nvim mapping
require("keybindings")
-- load autocommand
require('autocommand')
