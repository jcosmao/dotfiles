# theme

function __get_host_color
{
  HOST_COLOR_ARRAY=(4 5 6 11 12 14 40 46 200 204 215 226 191 119 74 129)
  fixed_nb=$(awk '{print $1}' <(md5sum <(hostname)) | sed -re 's/[^0-9]//g' | cut -c 1-10)
  array_size=${#HOST_COLOR_ARRAY[@]}
  color_index=$((fixed_nb%array_size - 1))
  echo ${HOST_COLOR_ARRAY[$color_index]}
}

# Layout
BLOX_SEG__UPPER_LEFT=(blox_block__openstack blox_block__host blox_block__cwd blox_block__git)
BLOX_SEG__UPPER_RIGHT=(blox_block__virtualenv blox_block__git_repo_name blox_block__nodejs)
BLOX_SEG__LOWER_LEFT=(blox_block__symbol)
BLOX_SEG__LOWER_RIGHT=(blox_block__bgjobs)


BLOX_CONF__ONELINE=false
BLOX_CONF__NEWLINE=false
BLOX_BLOCK__HOST_MACHINE_SHOW_ALWAYS=false
BLOX_BLOCK__HOST_USER_COLOR='magenta'
BLOX_BLOCK__HOST_MACHINE_COLOR="$(__get_host_color)"
BLOX_BLOCK__HOST_USER_ROOT_COLOR='9'
BLOX_BLOCK__CWD_COLOR='242'
BLOX_BLOCK__GIT_BRANCH_COLOR='245'
BLOX_BLOCK__CWD_TRUNC='4'
