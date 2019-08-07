#!/bin/sh
# This script MUST be in the root of team-props dir.

PROG_NAME=$(basename $0)
#PROG_BASEDIR=$(dirname $0)
PROG_BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_TEMPLATE_DIR="$PROG_BASEDIR/project-template"
WORKING_DIR=`pwd`
PROJECT_PREFIX="nexgen-"

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

validate_args()
{
if [[ $# -lt 2 ]];then
error_exit "\nUsage: $PROG_NAME -g|--group <group_name> -l|--lib <lib_name>"
fi
}

parse_args()
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
echo "GROUP NAME = <${GROUP_NAME}>"
echo "LIB NAME = <${LIB_NAME}>"
echo "GROUP_PATH = <${GROUP_PATH}>"
echo "LIB_PROJ_NAME = <${LIB_PROJ_NAME}>"

#if [[ ! -n "${LIB_NAME}" ]];then
#error_exit "$LINENO: Invalid Library name passed (${LIB_NAME})"
#fi
if [[ -z "${GROUP_NAME}" ]] || [[ -z "${LIB_NAME}" ]] || [[ -z "${GROUP_PATH}" ]] || [[ -z "${LIB_PROJ_NAME}" ]];then
error_exit "$LINENO: Invalid Arguments passed"
fi
#TODO: Validate Group Name
}

setup_gradle()
{
#Change working directory to Project Root
if [[ ${WORKING_DIR} == ${PROG_BASEDIR} ]];then
cd $(dirname ${PROG_BASEDIR})
WORKING_DIR=`pwd`
echo "Changed working directory to: $WORKING_DIR"
fi

if [[ `command -v gradle 2>/dev/null` ]];then
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
cp "$PROJECT_TEMPLATE_DIR/root/JenkinsFile" "$WORKING_DIR"
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
#$1 = com.quickplay.template.app
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
cp -R "$PROJECT_TEMPLATE_DIR/app/res/" "$WORKING_DIR/sample/src/main/res"
#APP_BUILD_GRADLE_SCRIPT=$(<"$PROJECT_TEMPLATE_DIR/app/build.gradle")
# cp "$PROJECT_TEMPLATE_DIR/app/build.gradle" "$WORKING_DIR/sample"
touch "$WORKING_DIR/sample/build.gradle"
#cat "" > "$WORKING_DIR/sample/build.gradle"
#replace `applicationId "com.quickplay.template.app"` with groupid.sample
generate_file_from_template_with_multi_patterns \
"s/com.quickplay.template.app/${GROUP_NAME}.sample/g;s/templatelib/${LIB_PROJ_NAME}/g" \
"$PROJECT_TEMPLATE_DIR/app/build.gradle" "$WORKING_DIR/sample/build.gradle"
#sed -e "s/com.quickplay.template.app/${GROUP_NAME}.sample/g" "$PROJECT_TEMPLATE_DIR/app/build.gradle" >\
#"$WORKING_DIR/sample/build.gradle"
generate_file_from_template "com.quickplay.template.app" "${GROUP_NAME}.sample" \
"$PROJECT_TEMPLATE_DIR/app/AndroidManifest.xml" "$WORKING_DIR/sample/src/main/AndroidManifest.xml"
}

setup_library_project()
{
create_folder_tree_if_not_exists "$WORKING_DIR/lib"
create_android_folder_tree_with_base "$WORKING_DIR/lib"
generate_file_from_template "com.quickplay.template.lib" "${GROUP_NAME}.${LIB_NAME}" \
"$PROJECT_TEMPLATE_DIR/lib/AndroidManifest.xml" "$WORKING_DIR/lib/src/main/AndroidManifest.xml"
cp "$PROJECT_TEMPLATE_DIR/lib/build.gradle" "$WORKING_DIR/lib/build.gradle"
generate_file_from_template_with_multi_patterns \
 "s/com.quickplay.nexgen/${GROUP_NAME}/g;s/templatelib/${LIB_NAME}/g" \
 "$PROJECT_TEMPLATE_DIR/lib/library.properties" "$WORKING_DIR/lib/library.properties"
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
git init
echo ""
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
validate_args $@
parse_args $@
setup_project
#}

