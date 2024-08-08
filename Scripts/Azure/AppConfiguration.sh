# Script: AppConfiguration.sh
# Description: Communication with Azure App Configuration

#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "path $SCRIPT_PATH"

parent=$(dirname "$SCRIPT_PATH")
baseDir=$(realpath "$parent")

source "$baseDir/Json/JsonHelper.sh"

function Get-AppConfiguration() {
    connectionString=""

    while [ $# -gt 0 ]
    do
        case "$1" in
              -cs|--connectionString) connectionString="$2"; shift;;        
              --) shift;;
         esac
         shift;
    done

    echo "Getting Azure App Configuration"
    configuration=$(az appconfig kv list --connection-string "$connectionString" --all)

    echo "$configuration"
}

function Get-Shared() {
    json=""

    while [ $# -gt 0 ]
    do
        case "$1" in
              -j|--json) json="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    allShared=$(Get-JsonFromKeyValue --json "$json" --key "label" --value "Shared")
    echo "$allShared"
}

function Get-DockerRegistryValues() {
    json=""

    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    dockerRegistry=$(Get-JsonPropertryFromKey --json "$json" --key "key" --value "Docker-Registry"  --property "value")
    echo "dockerRegistry=$dockerRegistry"    

    dockerRegistryUsername=$(Get-JsonPropertryFromKey --json "$json" --key "key" --value "Docker-Username"  --property "value")
    echo "dockerRegistryUsername=$dockerRegistryUsername"    

    dockerRegistryPassword=$(Get-JsonPropertryFromKey --json "$json" --key "key" --value "Docker-Password"  --property "value")
    echo "dockerRegistryPassword=$dockerRegistryPassword"   
}