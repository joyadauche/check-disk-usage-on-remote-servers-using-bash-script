#!/bin/bash

# This script displays disk usage information about servers.

SERVER_LIST='./servers' # A list of servers - one server per line.
EXIT_STATUS='0' # to capture exit status of commands run or 0 by default.

usage() {
  # Display the script usage and exit.
  echo "Usage: ${0} [-v] [-f FILE]" >&2
  echo "  -f FILE  Use FILE for the path to a list of servers. The default path is ${SERVER_LIST}." >&2
  echo '  -v       Verbose mode.' >&2
  exit 1
}

log() {
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
}

# Superuser privileges is not needed to execute this script.
if [[ "${UID}" -eq 0 ]]
then
  echo 'Do not execute this script as root.' >&2
  usage
fi

# Parse the specified options.
while getopts f:v OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    v) 
       VERBOSE='true'
       log 'Verbose mode on.' 
       ;;
    ?) usage ;;
  esac
done

# Ensure that SERVER_LIST file exists.
if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  exit 1
fi

# Check disk usage on each server
for SERVER in $(cat ${SERVER_LIST})
do
    log "SSHing into ${SERVER}"
    SSH_COMMAND="ssh root@${SERVER} df -h"

    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"

    # Capture any non-zero exit status from the SSH_COMMAND run and display to the user.
    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS=${SSH_EXIT_STATUS}
      echo "Execution on ${SERVER} failed." >&2
    fi
done

exit ${EXIT_STATUS}