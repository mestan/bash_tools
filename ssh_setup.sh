#! /bin/bash

command=$0
command="${command#./}"
command="${command%.sh}"

# Defaults
backup=1
bdir=''

# Parse arguments
POSITIONAL=""

while (( "$#" )); do
  case "$1" in
    -a|--my-boolean-flag)
      MY_FLAG=0
      shift
      ;;
    -b|--backup)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        backup=1
        bdir=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    +b|--no-backup)
      backup=0
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      POSITIONAL="$POSITIONAL $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$POSITIONAL"

echo "$#"
exit 0

function print_usage() {
  cat <<-USAGE

	  Usage: unlock_bitlocker {-k <rkey> | -f <key_file>} [-d <device>]

	  Unlock a BitLocker encrypted disk using the 'dislocker' program and the 
	  BitLocker Recovery Key. Must be run as 'root'.

	  Options:
	    -k <rkey>      The bitlocker recovery key including dashes. Takes
	                   precedence over '-f' option.
	    -f <key_file>  A file containing the BitLocker Recovery Key. The first
	                   string in the file that matches the pattern of a BitLocker
	                   key will be used.
	    -d <device>    The device you want to unlock.
	    -h             Print this usage information.

USAGE
}

cdir="/etc/ssh"
mv -v -t old_ssh_host_keys ssh_host_*
ssh-keygen -t ed25519 -a 200 -f ssh_host_ed25519_key
ssh-keygen -t rsa -b 4096 -a 200 -f ssh_host_rsa_key
groupadd ssh-users

authdir="$cdir/authorized_keys"

if [[ ! -d "$authdir" ]]; then
  if [[ -e "$authdir" ]]; then
    echo "ERROR: Cannot create directory '$authdir' because of a name collision."
    exit 1
  fi
  mkdir "$authdir"
  chgrp ssh-users "$authdir"
  chmod 750 "$authdir"
fi
