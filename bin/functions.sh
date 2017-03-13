#@
#@ ENVIRONMENT VARIABLES ----------------------------------------------------------------------------------------------
#@

## scriptname
scrn=${0##*/}
scrn=${scrn%.sh}

## temporary filename
id=$( date "+%Y%m%d_%H%M%S" )
rnd=$RANDOM
tmp=$scrn.$$.$rnd.$id
tmp_dir=/tmp/$tmp && mkdir -p -m 700 $tmp_dir
tmp=$tmp_dir/${tmp%%.*}

## log
log=/tmp/$scrn-$$-$rnd-$id.log

## messages
errm="${0##*/}: error:"
wrnm="${0##*/}: warning:"
infm="${0##*/}: info:"

## operating system info
op_sys=$(uname -s)
op_typ=$(lsb_release -a 2>/dev/null | grep "ID" | cut -d":" -f2)
op_ver=$(lsb_release -a 2>/dev/null | grep "Release" | cut -d":" -f2)
op_tst=Ubuntu14.04

#@
#@ FUNCTIONS DEFINITIONS ----------------------------------------------------------------------------------------------
#@

## print color text
format_msg()
{
  #@ USAGE  : format_msg <format> <color> <[pos:cnt]text>
  #@
  #@ TASK   : Print formatted and colored text.
  #@
  #@ EXAMPLE:
  #@
  #@          txt1='First text'
  #@          cnt1=${#txt1}
  #@
  #@          txt2='Second text'
  #@          cnt2=$(( ${cnt1} + ${#txt2} + 1 ))
  #@
  #@          txt3='Third text'
  #@          cnt3=$(( ${cnt2} + ${#txt3} + 1 ))
  #@
  #@          txt4='Fourth text'
  #@          cnt4=$(( ${cnt3} + ${#txt4} + 1 ))
  #@
  #@          format_msg bold red $txt1
  #@          format_msg normal green pos:${cnt1}$txt2
  #@          format_msg underline blue pos:${cnt2}$txt3
  #@          ...
  #@
  local fmt fg
  local format=$1
  local color=$2
  local msg col

  ## format
  case $format in
       bold) fmt=1 ;; underline) fmt=4 ;; reverse) fmt=7 ;; normal) fmt=0;;
          *) fmt=1 ;;
  esac

  ## foreground
  case $color in
    black) fg=0 ;;     red) fg=1 ;; green) fg=2 ;;  yellow) fg=3 ;;
     blue) fg=4 ;; magenta) fg=5 ;;  cyan) fg=6 ;;   white) fg=7 ;;
        *) fg=0 ;;
  esac

  shift 2

  msg="$@"
  case $msg in
    pos:*) msg=${msg#pos:}; col=${msg%%[!0-9]*}; msg=${msg#$col};;
        *) col=0;;
  esac

  if [ $col -gt 0 ]; then
    printf "\e[1A\e[${col}C\e[%d;" $fmt; printf "3%dm" $fg; printf " %s" "$msg"; printf "\e[m\n"
  else
    printf "\e[%d;" $fmt; printf "3%dm" $fg; printf "%s " "$msg"; printf "\e[m\n"
  fi

}

## usage
usage(){ grep "#@" $0 | sed 's/^..//' | head --lines=-1; exit 2; }

## cleaning
clean(){ /bin/rm -rf $tmp_dir; trap EXIT; exit; }

## is root
is_root(){ case $(id -u) in 0) ;; *) format_msg bold red "$errm root access needed"; usage; exit 2 ;; esac; }