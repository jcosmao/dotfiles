# theme

# enable color support
autoload -Uz colors && colors
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    eval "`dircolors -b`"
fi

function __get_host_color
{
  HOST_COLOR_ARRAY=(5 11 12 13 14 39 45 69 99 123 135 159 202)
  fixed_nb=$(awk '{print $1}' <(md5sum <(hostname)) | sed -re 's/[^0-9]//g' | cut -c 1-10)
  array_size=${#HOST_COLOR_ARRAY[@]}
  color_index=$(((fixed_nb%array_size) + 1))  # Index start at 1 in zsh
  echo ${HOST_COLOR_ARRAY[$color_index]}
}

# Layout
BLOX_SEG__UPPER_LEFT=(docker openstack host cwd git exec_time)
BLOX_SEG__UPPER_RIGHT=(nodejs virtualenv git_repo_name)
BLOX_SEG__LOWER_LEFT=(bgjobs symbol)
BLOX_SEG__LOWER_RIGHT=()

BLOX_CONF__ONELINE=false
BLOX_CONF__NEWLINE=false
BLOX_BLOCK__HOST_USER_SHOW_ALWAYS=true
BLOX_BLOCK__HOST_MACHINE_SHOW_ALWAYS=false
BLOX_BLOCK__HOST_MACHINE_SHOW_FQDN=true
BLOX_BLOCK__HOST_USER_COLOR='magenta'
BLOX_BLOCK__HOST_MACHINE_COLOR="$(__get_host_color)"
BLOX_BLOCK__HOST_USER_ROOT_COLOR='9'
BLOX_BLOCK__CWD_COLOR='242'
BLOX_BLOCK__CWD_TRUNC='4'
BLOX_BLOCK__GIT_BRANCH_COLOR='245'
BLOX_BLOCK__GIT_CLEAN_SYMBOL=""
BLOX_BLOCK__GIT_DIRTY_SYMBOL=""
BLOX_BLOCK__GIT_UNPULLED_SYMBOL=""
BLOX_BLOCK__GIT_UNPUSHED_SYMBOL=""
BLOX_BLOCK__GIT_STASHED_SYMBOL=""
BLOX_BLOCK__VIRTUALENV_COLOR='yellow'
BLOX_BLOCK__BGJOBS_COLOR='110'
BLOX_BLOCK__BGJOBS_SYMBOL=' '