#!/bin/bash

#Man page
MANUAL="\
$(basename "$0") - custom linux command for operations

USAGE:
  $(basename "$0") [--version] [--help] <command> [<args>]

COMMANDS:
  cpu		Get cpu information
  memory	Get memory information of the server

OPTIONS:
  -h, --help	Print the help message
  -v, --version Print the version information and exit
"

# if [[ "$1" == "--help" ]]; then
#   echo "Usage: internsctl [OPTIONS] COMMAND [ARGS]..."
#   echo ""
#   echo "Options:"
#   echo "  --version  Show the version and exit"
#   echo "  --help     Show this message and exit"
#   echo ""
#   echo "Commands:"
#   echo "  cpu         Get CPU information"
#   echo "  memory      Get memory information"
#   echo "  user        Manage users"
#   echo "  file        Get information about a file"
#   exit 0
# fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "$MANUAL"
  exit 0
fi

if [[ "$1" == "--version" || "$1" == "-v" ]]; then
  echo "$(basename "$0") v0.1.0"
  exit 0
fi

#CPU Command
if [[ "$1" == "cpu" ]]; then
  lscpu
  exit 0
fi

#Memory Command
if [[ "$1" == "memory" ]]; then
  free
  exit 0
fi

# User command
if [[ "$1" == "user" ]]; then
  if [[ "$2" == "create" ]]; then
    if [[ "$#" -ne 3 ]]; then
      echo "Error: Incorrect number of arguments. Usage: internsctl user create <username>"
      exit 1
    fi
    useradd -m "$3"
    echo "User $3 created successfully"
    exit 0
  elif [[ "$2" == "list" ]]; then
    if [[ "$#" -gt 3 ]]; then
      echo "Error: Incorrect number of arguments. Usage: internsctl user list [--sudo-only]"
      exit 1
    fi
    if [[ "$3" == "--sudo-only" ]]; then
      grep '^sudo:' /etc/group | cut -d: -f4
    else
      getent passwd | cut -d: -f1
    fi
    exit 0
  else
    echo "Error: Invalid argument. Usage: internsctl user [create|list]"
    exit 1
  fi
fi

if [[ "$1" == "file" && "$2" == "getinfo" ]]; then
  if [[ -z "$3" ]]; then
    echo "Error: missing file name"
    exit 1
  fi

  if [[ "$4" == "--size" || "$4" == "-s" ]]; then
    stat -c%s "$3"
  elif [[ "$4" == "--permissions" || "$4" == "-p" ]]; then
    stat -c%a "$3"
  elif [[ "$4" == "--owner" || "$4" == "-o" ]]; then
    stat -c%U "$3"
  elif [[ "$4" == "--last-modified" || "$4" == "-m" ]]; then
    stat -c%y "$3"
  else
    stat "$3" | sed "s|^File:.*$|File: $3|;s|^Access:.*$|Access: &|;s|^Owner:.*$|Owner: &|;s|^Modify:.*$|Modify: &|"
  fi

  exit 0
fi

echo "Error: invalid command or option"
exit 1
