#!/bin/bash

#@
#@ USAGE  : sudo install-gmt.sh -i
#@
#@ OPTIONS:
#@          -i - install
#@          -u - update
#@          -h - help
#@
#@ TASK   : Install different programs that are required for GMT installation.
#@          All programs will be tested and eventually installed.
#@          You can run this scrip multiple times without any problem.
#@
#@ NOTE   : This script demands for a <sudo> password at the beginning
#@          of the installation since it invokes the <apt-get install> program.
#@          This script provides a <path.txt> file that contains path
#@          and functions that need to be added to the <.bashrc> file.
#@          the <.bashrc> file have to be verified and eventually corrected
#@          manually after run to be the following:
#@
#@                export PATH=$PATH:<path_1>:<path_2>:<path_n>
#@
#@          -the 64bit version of the programs are installed when it is possible
#@          -installation works fine on Ubuntu 14.04 LTS & Ubuntu 16.04 LTS, 64bit
#@
#@          build and install GMT through version control
#@
#* by     : marcell.ferenc.uni@gmail.com

## root_dir
root_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ ! -s $root_dir/functions.sh ]; then exit 2; fi

source $root_dir/functions.sh

##------------------------------------------------------------------------------
## programs to test and install
##------------------------------------------------------------------------------
progs=( ncftp svn g++ gmtmath )
updates=( gmtmath )
##------------------------------------------------------------------------------

## default variable
inst=no
updt=no

## gmt5
gmt5_loc=/opt
gmt5_bin=gmt5
gmt5_dev=gmt5-dev
gmt5_dat=gmt5-data

## set trap for signals
trap clean EXIT HUP INT QUIT TERM

## help
case "$#" in
  0) usage ;;
esac

# test root user
is_root

## list of options the program will accept
optstring=iuh

## interpret options
while getopts $optstring opt; do
 case $opt in
  i) inst=yes ;;
  u) updt=yes ;;
  h) usage ; exit ;;
 esac
done

shift "$(( $OPTIND - 1 ))"

case "$inst" in no) format_msg bold red "$errm missing option: -t"; exit 2 ;; esac

## create log directory
mkdir -p $HOME/log

echo
##------------------------------------------------------------------------------
## install programs if they are NOT installed
##------------------------------------------------------------------------------
for prog in ${progs[@]}; do
 if [ $( type $prog &> /dev/null; echo $? ) -ne 0 ]; then
  txt=$( printf "%-15.15s - installing\n" $prog | tee -a $log )
  case $prog in
    gmtmath) is_gmt=no ;;
        svn) echo $txt; apt-get install -y subversion &>> $log ;;
          *) echo $txt; apt-get install -y $prog &>> $log ;;
  esac
 else printf "%-15.15s - exist\n" $prog | tee -a $log; fi
done

##------------------------------------------------------------------------------
## install the latest Generic Mapping Tools (GMT) if it is NOT installed
##------------------------------------------------------------------------------
if [ "$is_gmt" == "no" ]; then

 format_msg normal green "GMT5            - install" | tee -a $log

 ## install necessary programs and libraries
 if [ $( type cmake &> /dev/null; echo $? ) -ne 0 ]; then
  format_msg normal green "   -> install additional programs (ghostscript, cmake, etc.)" | tee -a $log
  # --force-yes
  apt-get install -y ghostscript build-essential cmake libnetcdf-dev libgdal1-dev libfftw3-dev libpcre3-dev &>> $log; fi

 ## create directory for gshhg and dcw files
 mkdir -p /opt/$gmt5_dat; cd $_

 ## gshhg files
 case $(ls -1 "gshhg-gmt*.tar.gz" &>> /dev/null; echo $?) in
   0) format_msg normal blue "   -> existing GSHHG database" | tee -a $log ;;
   *) format_msg normal green "   -> download GSHHG database" | tee -a $log
      ncftpget ftp://ftp.soest.hawaii.edu/gshhg/$( ncftpls -1 ftp://ftp.soest.hawaii.edu/gshhg/gshhg-gmt*.tar.gz | tail -1 ) &>> $log ;;
 esac

 ## dcw files
 case $(ls -1 "dcw-gmt*.tar.gz" &>> /dev/null; echo $?) in
   0) format_msg normal blue "   -> existing DCW database" | tee -a $log ;;
   *) format_msg normal green "   -> download DCW database" | tee -a $log
      ncftpget ftp://ftp.soest.hawaii.edu/dcw/$( ncftpls -1 ftp://ftp.soest.hawaii.edu/dcw/dcw-gmt*.tar.gz | tail -1 ) &>> $log ;;
 esac

 ## uncompress gshhg and dcw files and remove archive
 format_msg normal green "   -> uncompress GSHHG and DCW databases" | tee -a $log
 for item in gshhg*.tar.gz dcw-*.tar.gz; do
  tar -xvf $item; /bin/rm -f $item
  dirs+=( "${item%.tar.gz}" ); done &>> $log

 ## checkout the latest GMT5 version
 format_msg normal green "   -> checkout GMT5" | tee -a $log
 cd $gmt5_loc
 svn checkout svn://gmtserver.soest.hawaii.edu/gmt5/trunk $gmt5_dev &>> $log

 ## cp cmake template
 format_msg normal green "   -> create ConfigUser.cmake" | tee -a $log
 /bin/cp -f $gmt5_loc/$gmt5_dev/cmake/ConfigUserTemplate.cmake $gmt5_loc/$gmt5_dev/cmake/ConfigUser.cmake

 ## change 3 items in ConfigUser.cmake
 format_msg normal green "   -> modify ConfigUser.cmake" | tee -a $log
 ## 1 - installation directory
 sed -i -e "s/.*CMAKE_INSTALL_PREFIX.*prefix_path.*/set (CMAKE_INSTALL_PREFIX \"${gmt5_loc////\\/}\/$gmt5_bin\")/g" $gmt5_loc/$gmt5_dev/cmake/ConfigUser.cmake
 ## 2 - path to gshhg files
 sed -i -e "s/.*GSHHG_ROOT.*/set (GSHHG_ROOT \"${gmt5_loc////\\/}\/$gmt5_dat\/${dirs[0]}\")/g" $gmt5_loc/$gmt5_dev/cmake/ConfigUser.cmake
 ## 3 - path to dcw files
 sed -i -e "s/.*DCW_ROOT.*/set (DCW_ROOT \"${gmt5_loc////\\/}\/$gmt5_dat\/${dirs[1]}\")/g" $gmt5_loc/$gmt5_dev/cmake/ConfigUser.cmake

 ## build and install GMT5
 format_msg normal green "   -> build GMT5" | tee -a $log
 cd $gmt5_loc/$gmt5_dev
 mkdir build
 cd build
 { cmake ..; make; } &>> $log
 format_msg normal green "   -> install GMT5" | tee -a $log
 make install &>> $log

 ## add GMT5/bin to .bashrc PATH
 if [ $( grep $gmt5_bin $HOME/.bashrc &> /dev/null; echo $? ) -ne 0 ]; then
  paths+=( $gmt5_loc/$gmt5_bin/bin ); fi
fi

##------------------------------------------------------------------------------
## update GMT5
##------------------------------------------------------------------------------
if [ "$updt" == "yes" ]; then

 format_msg normal green "GMT5            - updating" | tee -a $log
 cd $gmt5_loc/$gmt5_dev

 ## update GMT5 source
 svn up &>> $log

 ## svn upgrade command was successful
 if [ $? -eq 0 ]; then

  ## exit_code: 0 - repository was up-to-date; other - repository was updated
  ec=$( tail -n 1 $log | grep "At revision" &> /dev/null; echo $? )

  ## repository was updated, so build and install
  if [ $ec -ne 0 ]; then
   format_msg normal green "   -> GMT5 repository was updated" | tee -a $log

   ## build and install GMT5
   format_msg normal green "   -> build GMT5" | tee -a $log
   cd $gmt5_loc/$gmt5_dev/build
   { cmake ..; make; } &>> $log
   format_msg normal green "   -> install GMT5" | tee -a $log
   make install &>> $log

  else format_msg normal blue "   -> GMT5 repository was up-to-date" | tee -a $log; fi
 else format_msg bold red "   -> svn error (maybe network error)"; fi

fi

##------------------------------------------------------------------------------
## add path of installed programs to .bashrc's PATH variable
##------------------------------------------------------------------------------
out=$HOME/path.txt

if [ ${#paths[@]} -ne 0 ]; then

 echo; echo "Add the content of <$HOME/path.txt> into <$HOME/.bashrc>" | tee -a $log

 ## extend PATH if necessary
 printf "%s:\ \n" "export PATH=\$PATH" "${paths[@]}" | sed '$s/...$//' > $out; fi