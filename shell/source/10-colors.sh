# eval $(dircolors -b ~/.dir_colors)
LS_COLORS='no=00:rs=0:fi=00:di=01;34:ln=00;36:mh=04;36:pi=04;01;36:so=04;33:do=04;01;35:bd=01;33:cd=00;33:or=00;31:mi=00;30;41:ex=01;31:su=01;04;37:sg=01;04;37:ca=01;37:tw=00;30;42:ow=04;32:st=00;30;44:*.7z=01;32:*.ace=01;32:*.alz=01;32:*.arc=01;32:*.arj=01;32:*.bz=01;32:*.bz2=01;32:*.cab=01;32:*.cpio=01;32:*.deb=01;32:*.dz=01;32:*.ear=01;32:*.gz=01;32:*.jar=01;32:*.lha=01;32:*.lrz=01;32:*.lz=01;32:*.lz4=01;32:*.lzh=01;32:*.lzma=01;32:*.lzo=01;32:*.rar=01;32:*.rpm=01;32:*.rz=01;32:*.sar=01;32:*.t7z=01;32:*.tar=01;32:*.taz=01;32:*.tbz=01;32:*.tbz2=01;32:*.tgz=01;32:*.tlz=01;32:*.txz=01;32:*.tz=01;32:*.tzo=01;32:*.tzst=01;32:*.war=01;32:*.xz=01;32:*.z=01;32:*.Z=01;32:*.zip=01;32:*.zoo=01;32:*.zst=01;32:*.aac=00;36:*.au=00;36:*.axa=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.oga=00;36:*.ogg=00;36:*.ra=00;36:*.spx=00;36:*.xspf=00;36:*.wav=00;36:*.doc=00;32:*.docx=00;32:*.dot=00;32:*.odg=00;32:*.odp=00;32:*.ods=00;32:*.odt=00;32:*.otg=00;32:*.otp=00;32:*.ots=00;32:*.ott=00;32:*.pdf=00;32:*.ppt=00;32:*.pptx=00;32:*.xls=00;32:*.xlsx=00;32:*.app=01;31:*.bat=01;31:*.btm=01;31:*.cmd=01;31:*.com=01;31:*.exe=01;31:*.reg=01;31:*~=01;30:*.bak=01;30:*.BAK=01;30:*.diff=01;30:*.log=01;30:*.LOG=01;30:*.old=01;30:*.OLD=01;30:*.orig=01;30:*.ORIG=01;30:*.swo=01;30:*.swp=01;30:*.ai=01;35:*.bmp=01;35:*.cgm=01;35:*.dl=01;35:*.dvi=01;35:*.emf=01;35:*.eps=01;35:*.gif=01;35:*.jpeg=01;35:*.jpg=01;35:*.JPG=01;35:*.mng=01;35:*.pbm=01;35:*.pcx=01;35:*.pgm=01;35:*.png=01;35:*.PNG=01;35:*.ppm=01;35:*.pps=01;35:*.ppsx=01;35:*.ps=01;35:*.psd=01;35:*.svg=01;35:*.svgz=01;35:*.tga=01;35:*.tif=01;35:*.tiff=01;35:*.xbm=01;35:*.xcf=01;35:*.xpm=01;35:*.xwd=01;35:*.yuv=01;35:*.0=00;32:*.1=00;32:*.2=00;32:*.3=00;32:*.4=00;32:*.5=00;32:*.6=00;32:*.7=00;32:*.8=00;32:*.9=00;32:*.c=00;32:*.C=00;32:*.cc=00;32:*.csh=00;32:*.css=00;32:*.cxx=00;32:*.el=00;32:*.h=00;32:*.hs=00;32:*.htm=00;32:*.html=00;32:*.java=00;32:*.js=00;32:*.json=00;32:*.l=00;32:*.man=00;32:*.md=00;32:*.mkd=00;32:*.n=00;32:*.objc=00;32:*.org=00;32:*.p=00;32:*.php=00;32:*.pl=00;32:*.pm=00;32:*.pod=00;32:*.py=00;32:*.rb=00;32:*.rdf=00;32:*.rtf=00;32:*.sh=00;32:*.shtml=00;32:*.tex=00;32:*.txt=00;32:*.vim=00;32:*.xml=00;32:*.yml=00;32:*.zsh=00;32:*.anx=01;33:*.asf=01;33:*.avi=01;33:*.axv=01;33:*.flc=01;33:*.fli=01;33:*.flv=01;33:*.gl=01;33:*.m2v=01;33:*.m4v=01;33:*.mkv=01;33:*.mov=01;33:*.MOV=01;33:*.mp4=01;33:*.mp4v=01;33:*.mpeg=01;33:*.mpg=01;33:*.nuv=01;33:*.ogm=01;33:*.ogv=01;33:*.ogx=01;33:*.qt=01;33:*.rm=01;33:*.rmvb=01;33:*.swf=01;33:*.vob=01;33:*.webm=01;33:*.wmv=01;33:';
export LS_COLORS

# Normal colors
export BLACK="\e[0;30m"
export RED="\e[0;31m"
export GREEN="\e[0;32m"
export YELLOW="\e[0;33m"
export BLUE="\e[0;34m"
export MAGENTA="\e[0;35m"
export CYAN="\e[0;36m"
export GREY="\e[0;37m"
export WHITE="\e[0;37m"

# Bright colors
export B_BLACK="\e[0;90m"
export B_RED="\e[0;91m"
export B_GREEN="\e[0;92m"
export B_YELLOW="\e[0;93m"
export B_BLUE="\e[0;94m"
export B_MAGENTA="\e[0;95m"
export B_CYAN="\e[0;96m"

export NORMAL="\e[0m"          # text reset
export BOLD="\e[1m"            # make bold
export UNDERLINE="\e[4m"       # underline
export BLINK="\e[5m"           # make blink
export REVERSE="\e[7m"         # reverse


function colors.display_256_colors ()
{
    for i in `seq 1 256`
    do
        tput setaf $i
        echo -n "$i "
    done
}

alias dcolors="colors.display_256_colors"

function colors.prompt_print {
    # colors.print 42 plop
    code=$1; shift;
    color_code=$(tput setaf $code)
    color_reset=$(tput sgr0)
    # https://unix.stackexchange.com/questions/158412/are-the-terminal-color-escape-sequences-defined-anywhere-for-bash
    prompt_escaped_color="\[$color_code\]"
    prompt_escaped_reset="\[$color_reset\]"
    echo -e ${prompt_escaped_color}$*${prompt_escaped_reset}
}

function colors.print {
    # colors.print 42 plop
    code=$1; shift;
    color_code=$(tput setaf $code)
    color_reset=$(tput sgr0)
    echo -e ${color_code}$*${color_reset}
}
