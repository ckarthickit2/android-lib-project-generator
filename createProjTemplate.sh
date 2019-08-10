#!/bin/sh
# This script MUST be in the root of team-props dir.

PROG_NAME=$(basename $0)
#PROG_BASEDIR=$(dirname $0)
PROG_BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_TEMPLATE_DIR="$PROG_BASEDIR/project-template"
WORKING_DIR=`pwd`
PROJECT_PREFIX="nexgen-"
TEAM_PROPS_REMOTE_URL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && git config --get remote.origin.url )"

# use $LINENO at call-site while passing the error-msg
error_exit()
{
	echo "${PROG_NAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

validate_last_command_result()
{
retVal=$?
if [[ ${retVal} -eq 1 ]]; then
    echo "${PROG_NAME}: ${1:-"Unknown Error"}" 1>&2
    exit ${retVal}
fi

}

validate_num_args()
{
if [[ $# -lt 2 ]];then
error_exit "\nUsage: $PROG_NAME -g|--group <valid_package_name> -l|--lib <lib_name>"
fi
}

validate_group_name()
{
  # Regex inspired from https://github.com/checkstyle/checkstyle/blob/master/src/main/java/com/puppycrawl/tools/checkstyle/checks/naming/PackageNameCheck.java
  if [[ ! "$GROUP_NAME" =~ ^[a-z]+(\.[a-z][a-z0-9]*)+$ ]]; then
  error_exit "\nUsage: $PROG_NAME -g|--group <valid_package_name> -l|--lib <lib_name>\
  \nPlease pass a valid java package name"
  fi
}

validate_library_name()
{
  if [[ ! "$LIB_NAME" =~ ^[a-z]+(-[a-z][a-z0-9]*)*$ ]]; then
  error_exit "\nUsage: $PROG_NAME -g|--group <valid_package_name> -l|--lib <lib_name>\
  \nPlease pass a valid library name (they should be valid alphanumeric, optionally hyphenated strings)"
  fi
}

# $1 = hyphenated  string; $2 = result variable
hyphenated_string_to_camel_case() {
	local __LEN=${#1}
	local __TEMP=""
	local  __RESULT=$2
	#echo $((${#1} -1 ))
	for i in $(echo $1 | tr "-" "\n")
	do
      __TEMP+="$(echo ${i:0:1} | awk '{ print toupper($0); }')"
      __TEMP+="${i:1:$((__LEN - 1))}"
	done
	eval $__RESULT="'$__TEMP'"
}

parse_and_validate_args()
{
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -g|--group)
    GROUP_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--lib)
    LIB_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

GROUP_PATH=`echo ${GROUP_NAME} | sed "s/\\./\\//g"`
LIB_PROJ_NAME="${LIB_NAME}-lib"
LIB_PACKAGE_NAME="$( echo ${LIB_NAME} | sed s/-/_/g )"

#Substitute pattern:
# (^|_) at the start of the string or after an underscore - first group
# ([a-z]) single lower case letter - second group
#by
# \U\2 uppercasing second group
# g globally.
#LIB_CLASS_NAME="$( echo ${LIB_NAME} | sed -r 's/(^|-)([a-z])/\U\2/g')"
hyphenated_string_to_camel_case ${LIB_NAME} LIB_CLASS_NAME
echo "GROUP NAME = <${GROUP_NAME}>"
echo "LIB NAME = <${LIB_NAME}>"
echo "GROUP_PATH = <${GROUP_PATH}>"
echo "LIB_PROJ_NAME = <${LIB_PROJ_NAME}>"
echo "LIB_PACKAGE_NAME = <${LIB_PACKAGE_NAME}>"
echo "LIB_CLASS_NAME = <${LIB_CLASS_NAME}>"

#if [[ ! -n "${LIB_NAME}" ]];then
#error_exit "$LINENO: Invalid Library name passed (${LIB_NAME})"
#fi
if [[ -z "${GROUP_NAME}" ]] || [[ -z "${LIB_NAME}" ]] || [[ -z "${GROUP_PATH}" ]] || [[ -z "${LIB_PROJ_NAME}" ]];then
error_exit "$LINENO: Invalid Arguments passed"
fi
validate_group_name
validate_library_name
}

setup_gradle()
{
#Change working directory to Project Root
if [[ ${WORKING_DIR} == ${PROG_BASEDIR} ]];then
cd $(dirname ${PROG_BASEDIR})
WORKING_DIR=`pwd`
echo "Changed working directory to: $WORKING_DIR"
fi

if [[ `command -v gradlea 2>/dev/null` ]];then
echo "gradle found"
gradle init --type basic --dsl groovy --project-name "$PROJECT_PREFIX$LIB_NAME"
validate_last_command_result "$LINENO Gradle init failure"
else
echo "falling back to local gradle wrapper"
cp -R "$PROJECT_TEMPLATE_DIR/gradlew/" "$WORKING_DIR"
./gradlew init --type basic --dsl groovy --project-name "$PROJECT_PREFIX$LIB_NAME"
validate_last_command_result "$LINENO Gradle init failure"
fi
}

setup_root_project()
{
#copy .gitignore
cp "$PROJECT_TEMPLATE_DIR/root/.gitignore" "$WORKING_DIR"
#copy root build.gradle
cp "$PROJECT_TEMPLATE_DIR/root/build.gradle" "$WORKING_DIR"
setup_settings_gradle_script
cat "$PROJECT_TEMPLATE_DIR/root/gradle.properties" >> "$WORKING_DIR/gradle.properties"
cp "$PROJECT_TEMPLATE_DIR/root/Jenkinsfile.groovy" "$WORKING_DIR"
}

setup_settings_gradle_script()
{
TEMP_SETTINGS_FILE="$WORKING_DIR/.settings.tmp.gradle"
touch "$TEMP_SETTINGS_FILE"
echo "" > ${TEMP_SETTINGS_FILE}
echo "\ninclude ':sample'">> ${TEMP_SETTINGS_FILE}
echo "\ninclude ':${LIB_PROJ_NAME}'">> ${TEMP_SETTINGS_FILE}
echo "\nproject(':${LIB_PROJ_NAME}').projectDir = file('./lib')">> ${TEMP_SETTINGS_FILE}
echo "\nproject(':${LIB_PROJ_NAME}').name = '${LIB_PROJ_NAME}'">> ${TEMP_SETTINGS_FILE}
cat "$TEMP_SETTINGS_FILE" >> "$WORKING_DIR/settings.gradle"
rm "$TEMP_SETTINGS_FILE"
}

# $1 = base folder name
create_android_folder_tree_with_base()
{
  if [[ -z "$1" ]];then
    error_exit "$LINENO: Invalid base folder passed ($1)"
  fi
  create_folder_tree_if_not_exists "$1/src/androidTest/java/${GROUP_PATH}"
  create_folder_tree_if_not_exists "$1/src/main/java/${GROUP_PATH}"
  create_folder_tree_if_not_exists "$1/src/main/res"
  create_folder_tree_if_not_exists "$1/src/test/java/${GROUP_PATH}"
}

# $1 directorypath
create_folder_tree_if_not_exists()
{
if [[ ! -f "$1" ]]; then
mkdir -p "$1"
fi
}

# Replaces the templatePattern with replacePattern by taking templateSourceFile as base and commits the result onto
# destinationFile
# $1 = templatePattern; $2 = replacePattern; $3 = templateSourceFile; $4 = destinationFile
generate_file_from_template()
{
#$1 = templatepackage
#$2 = ${GROUP_NAME}.sample
#$3 = $PROJECT_TEMPLATE_DIR/app/build.gradle
#$4 = $WORKING_DIR/sample/build.gradle
sed -e "s/${1}/${2}/g" "${3}" > "${4}"
validate_last_command_result "$LINENO: failed to create file from template: $3"
}

# Replaces text as per patternExpressions(separated by semi-colon(;)), of the form "s/<old_value>/<new_value>/g",  by taking templateSourceFile as base and commits the result onto
# destinationFile
# $1 = patternExpressions; $2 = templateSourceFile; $3 = destinationFile
generate_file_from_template_with_multi_patterns()
{
#sed 's/com.quickplay.nexgen/com.quickplay.somegen/g;s/templatelib/somelib/g' library.properties > library.properties2
sed "${1}" "${2}" > "${3}"
}

setup_sample_app_project()
{
create_folder_tree_if_not_exists "$WORKING_DIR/sample"
create_android_folder_tree_with_base "$WORKING_DIR/sample"

#Handle app/res folder
cp -R "$PROJECT_TEMPLATE_DIR/app/res/" "$WORKING_DIR/sample/src/main/res"
generate_file_from_template "templateapp" "${LIB_PROJ_NAME}-demo" \
"$PROJECT_TEMPLATE_DIR/app/res/values/strings.xml" "$WORKING_DIR/sample/src/main/res/values/strings.xml"

#Handle app/Launcher Activity 
generate_file_from_template_with_multi_patterns \
"\
s/templatepackage/${GROUP_NAME}/g;\
s/templateapp/${LIB_PACKAGE_NAME}.sample/g;\
s/TemplateLibraryInfo/${LIB_CLASS_NAME}LibraryInfo/g\
" \
"$PROJECT_TEMPLATE_DIR/app/src/Launcher.kt" "$WORKING_DIR/sample/src/main/java/${GROUP_PATH}/Launcher.kt"

#Handle app/AndroidManifest.xml
generate_file_from_template_with_multi_patterns \
"s/templatepackage/${GROUP_NAME}/g;s/templateapp/${LIB_PACKAGE_NAME}.sample/g" \
"$PROJECT_TEMPLATE_DIR/app/AndroidManifest.xml" "$WORKING_DIR/sample/src/main/AndroidManifest.xml"

#Handle app/build.gradle
#copy app/build.gradle into APP_BUILD_GRADLE_SCRIPT
#APP_BUILD_GRADLE_SCRIPT=$(<"$PROJECT_TEMPLATE_DIR/app/build.gradle")
touch "$WORKING_DIR/sample/build.gradle"
generate_file_from_template_with_multi_patterns \
"\
s/templatepackage/${GROUP_NAME}/g;\
s/templateapp/${LIB_PACKAGE_NAME}.sample/g;\
s/templatelib/${LIB_PROJ_NAME}/g\
" \
"$PROJECT_TEMPLATE_DIR/app/build.gradle" "$WORKING_DIR/sample/build.gradle"
#sed -e "s/templatepackage/${GROUP_NAME}.sample/g" "$PROJECT_TEMPLATE_DIR/app/build.gradle" >\
#"$WORKING_DIR/sample/build.gradle"
}

setup_library_project()
{
create_folder_tree_if_not_exists "$WORKING_DIR/lib"
create_android_folder_tree_with_base "$WORKING_DIR/lib"

#Handle lib/TemplateLibraryInfo.kt
generate_file_from_template "Template" "${LIB_CLASS_NAME}" \
"$PROJECT_TEMPLATE_DIR/lib/src/TemplateLibraryInfo.kt" \
"$WORKING_DIR/lib/src/main/java/${GROUP_PATH}/${LIB_CLASS_NAME}LibraryInfo.kt"

#Handle lib/AndroidManifest.xml
generate_file_from_template_with_multi_patterns \
"s/templatepackage/${GROUP_NAME}/g;s/templatelib/${LIB_PACKAGE_NAME}/g" \
"$PROJECT_TEMPLATE_DIR/lib/AndroidManifest.xml" "$WORKING_DIR/lib/src/main/AndroidManifest.xml"

#Handle lib/build.gradle
cp "$PROJECT_TEMPLATE_DIR/lib/build.gradle" "$WORKING_DIR/lib/build.gradle"

#Handle lib/library.properties
generate_file_from_template_with_multi_patterns \
"s/templatepackage/${GROUP_NAME}/g;s/templatelib/${LIB_NAME}/g" \
"$PROJECT_TEMPLATE_DIR/lib/library.properties" "$WORKING_DIR/lib/library.properties"

#Handle lib/publish.properties
cp "$PROJECT_TEMPLATE_DIR/lib/publish.properties" "$WORKING_DIR/lib/publish.properties"
}

setup_git_scm()
{
#Copy remote url of team-props repository
#Remove .git
#Initialize a brand new git repo
#Copy .gitignore from team-props/project-template ?
#Add team-props repo as submodule of the newly created repo
#Stage all the changes ??
TEAM_PROPS_DIR_NAME=$(basename $PROG_BASEDIR)
if [[ $TEAM_PROPS_DIR_NAME != "team-props" ]]; then
echo "moving $TEAM_PROPS_DIR_NAME to team-props"
mv $TEAM_PROPS_DIR_NAME "$WORKING_DIR/team-props"
TEAM_PROPS_DIR_NAME="team-props"
fi
git init
git submodule add $TEAM_PROPS_REMOTE_URL "team-props"
git add --all
#echo "TEAM_PROPS_REMOTE_URL = $TEAM_PROPS_REMOTE_URL, prog_dir= $(basename $PROG_BASEDIR)"
}

setup_project()
{
#setup gradle wrapper for project
setup_gradle
setup_root_project
setup_sample_app_project
setup_library_project
setup_git_scm
}


#main() {
validate_num_args $@
parse_and_validate_args $@
setup_project
#}

