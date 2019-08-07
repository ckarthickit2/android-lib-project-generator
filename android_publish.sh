#!/bin/sh
# This script MUST be in the root of team-props dir.

PROGNAME=$(basename $0)
BASEDIR=$(dirname $0)
WORKINGDIR=`pwd`
# use $LINENO at call-site while passing the error-msg
error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

#main() {

if [[ ! $# -gt 1 ]]; then
error_exit "$LINENO : please pass valid arguments (project name, remote name)"
fi

PUBLISH_TAG=$1
REMOTE_NAME=$2

git tag ${PUBLISH_TAG}
git push ${REMOTE_NAME} ${PUBLISH_TAG}

#}
