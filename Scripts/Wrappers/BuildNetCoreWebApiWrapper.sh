# Script: BuildNetCoreWebApiWrapper.sh
# Description: Wrapper before building images.

#!/bin/bash

echo "Arguments:"
echo "$@"

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# echo "path $SCRIPT_PATH"

parent=$(dirname "$SCRIPT_PATH")
baseDir=$(realpath "$parent")

# echo "path $SCRIPT_PATH"
# echo "scriptBase $baseDir"

source "$baseDir/Azure/AppConfiguration.sh"

codeSource=""
runCount=""
version=""
containerName=""
azAppConfiguration=""

# Read the Argument values
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--source) codeSource="$2"; shift ;;
        -rc|--runCount) runCount="$2"; shift ;;
        -v|--version) version="$2"; shift ;;
        -c|--containerName) containerName="$2"; shift ;;
        -az|--azAppConfiguration) azAppConfiguration="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

configuration=$(Get-AppConfiguration --connectionString "$azAppConfiguration")
if [ $? -ne 0 ]; then
    echo "Failed to get configuration" >&2
    exit $?
fi

allShared=$(Get-Shared --json "$configuration")

# echo "All shared $allShared" >&2

dockerValues=$(Get-DockerRegistryValues --json "$allShared")

# echo "Docker values: $dockerValues" >&2

dockerRegistry=$(echo "$dockerValues" | grep "dockerRegistry" | awk -F '=' '{print $2}') > /dev/null 2>&1
dockerRegistryUsername=$(echo "$dockerValues" | grep "dockerRegistryUsername" | awk -F '=' '{print $2}') > /dev/null 2>&1
dockerRegistryPassword=$(echo "$dockerValues" | grep "dockerRegistryPassword" | awk -F '=' '{print $2}') > /dev/null 2>&1

containerInfo=$("$baseDir/Build/BuildNetCoreWebApi.sh" -s "$codeSource" -v "$version" -r "$dockerRegistry" -c "$containerName" -u "$dockerRegistryUsername" -p "$dockerRegistryPassword" -rc "$runCount")
if [ $? -ne 0 ]; then
    echo "Failed to build the containers"
    exit $?
fi

containerversion=$(echo "$containerInfo" | grep "containerversion=" | awk -F '=' '{print $2}')
echo "Saving version info to files. Container: $containerversion" >&2
echo "$containerversion" > "version.txt"