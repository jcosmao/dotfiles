#
# bash compatibility plugin
#
# (C) Copyright 2012, Christian Ludwig
#

# TODO The following bash builtins are not available to zsh:
#      caller, help?, mapfile/readarray

caller() {
	echo "'caller' is not supported."
}

# rewrite 'source' to be more bash friendly
source() {
  alias shopt=':'
  alias _expand=_bash_expand
  alias _complete=_bash_comp
  emulate -L sh
  setopt kshglob noshglob braceexpand

  builtin source "$@"
}

alias .='source'

# allow regex
setopt NO_NOMATCH

autoload -Uz bashcompinit
bashcompinit -i
