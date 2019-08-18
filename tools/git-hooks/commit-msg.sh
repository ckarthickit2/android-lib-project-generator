#!/bin/sh
#
# Hook script to check the commit log message.
# Called by \"git commit\" with one argument, the name of the file
# that has the commit message.  The hook should exit with non-zero
COMMIT_MSG=`cat $1`
COMMIT_REGEX=^[[A-Z]{1,10}-[0-9]{1,5}]
ERROR_MSG="Aborting commit. Your commit message is invalid! \nShould Match Regex :^[[A-Z]{1,10}-[0-9]{1,5}] "

if [[ ! "$COMMIT_MSG" =~ $COMMIT_REGEX ]]; then
  echo "$ERROR_MSG" >&2
  exit 1
fi
exit
