#! /bin/bash

# Includes
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") > /dev/null && pwd)
source "$SCRIPT_DIR/cl_args_funcs/cl_args_funcs.sh" "$SCRIPT_DIR/cl_args_funcs"

# Options
declare -A short_opts=([-b]=back [+b]=no-back [-c]=cfgdir)
declare -A long_opts=([backup]=back [no-backup]=no-back [cfgdir]=cfgdir)

command=$0
command="${command#./}"
command="${command%.sh}"

# Defaults
backup=1
bkdir=''
cfgdir="/etc/ssh"

# Parse arguments
POSITIONAL=""

while (( "$#" )); do
  opt=$(match_opt "$1" short_opts long_opts -v)
  if [[ $? -ne 0 ]]; then err=$?; echo "\n$command: $opt\n" >&2; exit $err; fi
  if [[ -z "$opt" ]]; then
    # preserve positional arguments
    POSITIONAL="$POSITIONAL $1"
    shift
    continue
  fi
  case "$opt" in
    back)
      backup=1
      if [[ -n "$2" && ! $(match_opt "$2" -t) ]]; then
        bkdir=$2
        shift 2
      else
        shift 1
      fi
      ;;
    no-back)
      backup=0
      ;;
    cfgdir)
      cfgdir="$opt"
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$POSITIONAL"

# Get the directory in which to put the key backups
valid() {
  bkdir=$1
  if [[ -d $bkdir ]]; then
    return 0
  elif [[ -e $bkdir ]]; then
    return 1
  else
    mkdir $bkdir
    return 0
  fi
}

if [[ -z $bkdir ]]; then
  bkbase=$cfdir/ssh_host_keys.bk
  bkdir=bkbase
else
  bkbase=$bkdir
fi

i=0

while ! valid $bkdir; do
  bkdir="${bkbase}$i"
  i=$(( $i + 1 ))
done

datetime=$(date +"%Y-%m-%d-%H%M%S")
time_ms=$(( "10#$(date +'%N')" / 10**6 ))
printf -v datetime "%s-%03i" $datetime $time_ms

for keyfile in $cfdir/ssh_host_*; do
  mv $keyfile $bkdir/$keyfile_$datetime
done

ssh-keygen -t ed25519 -a 200 -f "$cfdir/ssh_host_ed25519_key"
ssh-keygen -t rsa -b 4096 -a 200 -f "$cfdir/ssh_host_rsa_key"
