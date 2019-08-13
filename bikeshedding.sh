#!/bin/sh
# This script MUST be in the root of toolset dir.

PROGNAME=$(basename $0)
BASEDIR=$(dirname $0)
# use $LINENO at call-site while passing the error-msg
error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

# $1 = source_file $2 destination_file $3 prefix_name
copy_hook_if_modified(){
  copy_hook_destn_dir=$(dirname $2)
  echo "copy_hook_destn_dir = $copy_hook_destn_dir"
  if [[ ! -e copy_hook_destn_dir ]];then
    echo "creating $copy_hook_destn_dir"
    mkdir -p "${copy_hook_destn_dir}"
  fi
  if [[ ! -f "$1" ]] && [[ ! -f "$2" ]];then
   echo "$3: no hook found"
   error_exit "$3: $LINENO: cannot process without a hook"
  fi

  if [[ -f "$1" && ! -f "$2" ]] || [[ `diff $1 $2` ]]; then
  echo "$3: hook getting configured..."
  cp "$1" "$2"
  chmod -R +x "$2"
  elif [[ -f "$2" ]]; then
  echo "$3: hook already configured"
  fi
}

#main(){

if [[ ! $# -gt 0 ]]; then
error_exit "$LINENO : please pass the base dir of project"
fi

if [[ ! -d "$1" ]]; then
error_exit "$LINENO : must pass a valid directory"
fi

if [[ ! -d "$1/.git" ]]; then
error_exit "$LINENO : $1 is not a valid git repository"
fi

copy_hook_if_modified "$BASEDIR/tools/git-hooks/pre-commit.sh" "$1/.git/hooks/pre-commit" "pre-commit"

copy_hook_if_modified "$BASEDIR/tools/git-hooks/pre-push.sh" "$1/.git/hooks/pre-push" "pre-push"

copy_hook_if_modified "$BASEDIR/tools/lint/lint.xml" "$1/lint.xml" "lint.xml"

copy_hook_if_modified "$BASEDIR/tools/.editorconfig" "$1/.editorconfig" ".editorconfig"

copy_hook_if_modified "$BASEDIR/project-template/root/.gitignore" "$1/.gitignore" ".gitignore"

copy_hook_if_modified "$BASEDIR/tools/codeStyles/codeStyleConfig.xml" "$1/.idea/codeStyles/codeStyleConfig.xml" "codeStyleConfig.xml"

copy_hook_if_modified "$BASEDIR/tools/codeStyles/Project.xml" "$1/.idea/codeStyles/Project.xml" "Project.xml"
#}
