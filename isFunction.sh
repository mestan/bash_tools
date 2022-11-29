#! /bin/bash

if [[ "$1" != '-q' ]] && declare -F 'isFunction' >/dev/null; then
  echo -e "\nERROR: A function named 'isFunction' is already defined.\n" >&2
else
  isFunction() { declare -F -- "$@" >/dev/null; }
fi
