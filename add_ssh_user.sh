#!/bin/zsh

# Exit codes
exit_success=0
exit_unk_opt=2   # Unkown option
exit_miss_arg=3  # Missing argument
exit_miss_usr=4  # No user name specified
exit_miss_cmd=5  # Missing the command option
exit_mult_cmd=6  # Multiple command options specified

# Documentation

read -r -d '' usage_syntax <<-'EOF'
	Usage: %s -e|--endow  [-u|--user] username [-k|--key] pub_key_file [-g|--group ssh_user_group]
	       %s -a|--add    [-u|--user] username [-k|--key] pub_key_file
	       %s -r|--remove [-u|--user] username [-k|--key] pub_key_file
         %s -l|--list   [-u|--user] username
	       %s -d|--deny   [-u|--user] username [-g|--group ssh_user_group]
	       %s -h|--help
	EOF

commands='-e, -a, -d, and -h'

read -r -d '' usage_detailed <<-'EOF'
	Commands:

	-e|--endow  : Endow the user with SSH privileges
	-a|--add    : Add the key to the user's authorized keys file
  -r|--remove : Remove the key from the user's authorized keys file
	-d|--deny   : Deny the user SSH privileges
  -h|--help   : Print detailed help

  Command Arguments:

	-u : Specifies the user to act upon
	-k : The SSH public key for the user
	-g : Specifies the user group that grants SSH privileges (default: ssh-users)'

	Common Options:

	-v|--verbose : Verbose output
	--force      : Do not request permission before executing the given command
	-h|--help    : Print detailed help
	EOF

read -r -d '' usage_full <<-'EOF'
	The endow command (-e) adds the user to the specified users group (which defaults to 'ssh-users'),
	creates the authorized keys file for the user, and adds the given public key to the file. The
	authorized key file is created in `/etc/ssh/authorized_keys` with the name `<user>.keys`. If the
	specified user group does not exist, it will be created; the system admin should then add the
	group to the system's `sshd_config` file to grant the members the right to use SSH. If the user 
	already has an authorized keys file, it will be deleted and re-created so that the given public 
	key is the only key in the file.
	EOF

usage_add="The add command (-a) adds the given public key to the user's authorized keys file."

read -r -d '' usage_deny <<-'EOF'
	The deny command (-d) removes the user from the specified users group and deletes the user's 
	authorized keys file.
	EOF

read -r -d '' usage_keyfile <<-'EOF'
	The authorized keys file for a user is created in or assumed to be in the directory:

	/etc/ssh/authorized_keys

	with the name `<username>.keys`.
	EOF

# Argument processing

cmd_endow=0
cmd_add=0
cmd_deny=0
cmd_help=0
ssh_user_group="ssh-users"
verbose=false
force=false

while getopts ":eadu:k:g:fvh" opt; do
  case "${opt}" in
    e) declare -i cmd_endow=1;;
    a) declare -i cmd_add=2;;
    d) declare -i cmd_deny=4;;
    u) user="$OPTARG";;
    k) pub_key="$OPTARG";;
    g) $ssh_user_group="$OPTARG";;
    f) force=true;;
    v) verbose=true;;
    h) cmd_help=6;;
    :) printf "\nError: Missing argument for option '-%s'\n\n${usage_syntax}\n\n" \
       $OPTARG $0 $0 $0 $0
       exit $exit_miss_arg
       ;;
    ?) printf "\nError: Unknown argument '-%s'\n\n${usage_syntax}\n\n" \
       $OPTARG $0 $0 $0 $0
       exit $exit_unk_opt
       ;;
  esac
done

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -e|--extension)
      EXTENSION="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--searchpath)
      SEARCHPATH="$2"
      shift # past argument
      shift # past value
      ;;
    -l|--lib)
      LIBPATH="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    *)    # unknown option
      if [ ${1} = '-' ]
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

key_op=$(($cmd_endow|$cmd_add|$cmd_deny))
case "$key_op" in
    1)
      if [ $help_req = true ]; then
        printf "%s\n%s\n" $usage_syntax $usage_detailed
        exit $exit_success
      fi
      echo "key_ops_sum is zero"
      printf "Error: %s\n\n${usage_syntax}\n\n" \
        "Missing a command. One of the commands $commands must be specified." \
        $0 $0 $0 $0
      exit 4
      ;;
    2) ;;
    4) ;;
    0)

      ;;
    *) ;;
esac

# if [ $key_ops_sum = 0 ] && [ ! $req_help ]; then
#   echo "\n"
# elif [ $key_ops_sum -gt 1 ]; then
#   echo "key_ops_sum is greater than 1"
#   printf "Error: %s\n\n${usage_syntax}\n\n" \
#     "Multiple commands. Only one of the commands $commands can be specified."
#     $0 $0 $0 $0
#   exit 5
# fi


