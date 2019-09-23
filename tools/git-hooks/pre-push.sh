#!/bin/sh

PROGNAME=$(basename $0)
# use $LINENO as call-site while passing the error-msg
error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

# $1 = prefix
check_task_result() {
if [[ "$?" -ne 0 ]] ; then
    error_exit "$LINENO : (line:$1) issues found. please fix before pushing"
fi
}

update_staged_files() {
staged_kotlin_files=`git --no-pager diff --name-status --no-color --cached | awk '$1 != "D" && $2 ~ /\.kts|\.kt/ { print $2}'`
staged_files=`git --no-pager diff --name-status --no-color --cached | awk '$1 != "D" { print $2}'`
staged_test_files=`git --no-pager diff --name-status --no-color --cached | awk '$1 != "D" && $2 ~  /\/test\// && $2 ~ /\.kt|\.java/ { print $2}'`
staged_source_files=`git --no-pager diff --name-status --no-color --cached | awk '$1 != "D" && $2 ~ /\.kts|\.kt|\.java|\.xml/ { print $2}'`
}

#main() {

#update_staged_files

# if [[ -z "$staged_source_files" ]];then
# echo "no source files.. skipping pre-push hooks"
# exit 0
# fi

# Validate Kotlin code with detekt
echo "running detekt..."
./gradlew detekt --daemon
check_task_result $LINENO

# Do linting
echo "running debug lint"
./gradlew lintDebug
check_task_result $LINENO

# Run unit tests
echo "running unit tests"
./gradlew jacocoTestReportDebug generateJacocoBadge --daemon
check_task_result $LINENO

#Update README.md
git add README.md
git commit --amend --no-edit

#done
echo "pre-push checks passed!"

#}
