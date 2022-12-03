#! /bin/bash

declare -A _path_funcs__VARS

_path_funcs__VARS+=( [CODE_DIR]=$(cd $(dirname "${BASH_SOURCE[0]}") > /dev/null && pwd) )

source "${_path_funcs__VARS[CODE_DIR]}/isFunction.sh" -q

declare -i _path_funcs__force=0 _path_funcs__quiet=0
while (( $# )); do
  case "$1" in
    -f) _path_funcs__VARS+=( [force]='t' ); shift;;
    -q) _path_funcs__VARS+=( [quiet]='t' ); shift;;
    *) shift;;
  esac
done

if [[ -n ${_path_funcs__VARS[quiet]} ]]; then
  _path_funcs__success=()
  _path_funcs__fail=()
fi

# Trim whitespace from the ends of the string.
#
#   trim <strvar> [-b]
#
# By default, the function removes all whitespace; if the '-b' option is 
# given, then only tabs and spaces are removed.
if [[ -n ${_path_funcs__VARS[force]} ]] || ! isFunction trim; then
  trim() {
    local -n str=$1
    local white
    if [[ "$2" == '-b' ]]; then
      white='[:blank:]'
    else
      white='[:space:]'
    fi
    str=${str##*([$white])}
    str=${str%%*([$white])}
  }
  [[ -n ${_path_funcs__VARS[quiet]} ]] || _path_funcs__VARS[success]+='trim '
else
  [[ -n ${_path_funcs__VARS[quiet]} ]] || _path_funcs__VARS[fail]+='trim '
fi

# Get the parent and leaf from the given path
#
#   split_path <outvar> <path> [-j]
#
# The <outvar> is assigned an array containing:
#  
#   (parent leaf [path])
#
# The 'path' value is included when the '-j' option is given and is 
# created by rejoining the 'parent' and 'leaf' parts of the provided
# path.
if [[ -n ${_path_funcs__VARS[force]} ]] || ! isFunction split_path; then
  split_path() {
    local -n _r_out=$1
    local path=$2
    local -i rejoin=0
    if [[ "$3" == '-j' ]]; then rejoin=1; fi
    trim path
    path=${path%/}
    if [[ -z "$path" ]]; then
      # Path is the root of the filesystem
      _r_out=('' '')
    elif [[ -z "${path//[^/]}" ]]; then
      # No path separators in the path
      _r_out=('.' "$path")
    else
      local parent="${path%/*}"
      local leaf="${path##*/}"
      if [[ "${parent:0:3}" =~ ^\.{0,2}/ ]]; then
        # Path is absolute or specified as relative already
        _r_out=("$parent" "$leaf")
      else
        # Path is relative
        _r_out=("./$parent" "$leaf")
      fi
    fi
    if (( $rejoin )); then printf -v _r_out[2] '%s/%s' "${_r_out[@]}"; fi
    return 0
  }
  [[ -n ${_path_funcs__VARS[quiet]} ]] || _path_funcs__VARS[success]+='split_path '
else
  [[ -n ${_path_funcs__VARS[quiet]} ]] || _path_funcs__VARS[fail]+='split_path '
fi


if [[ -z ${_path_funcs__VARS[quiet]} ]]; then
  if [[ -n ${_path_funcs__VARS[success]} ]]; then
    printf "$(
      # Output succeses
      printf '\\n'
      printf 'Successfully created the following functions:\\n\\n'
      IFS=' ' read -ra successes <<< ${_path_funcs__VARS[success]}
      printf '    %s\\n' "${successes[@]}"
    )"
  fi
  if [[ -n ${_path_funcs__VARS[fail]} ]]; then
    printf "$(
      # Output failures
      printf '\\n'
      printf 'Functions with the following names already existed:\\n\\n'
      IFS=' ' read -ra failures <<< ${_path_funcs__VARS[fail]}
      printf '    %s\\n' "${failures[@]}"
    )" >&2
  fi
  echo
fi

unset _path_funcs__VARS
