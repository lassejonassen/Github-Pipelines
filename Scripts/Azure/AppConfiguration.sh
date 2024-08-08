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
    servicePrincipal=""
    servicePrincipalPassword=""
    tenantId=""

    while [ $# -gt 0 ]
    do
        case "$1" in
            -t|--tenantId) tenant="$2"; shift;;
            -sp|--servicePrincipal) servicePrincipal="$2"; shift;;
            -spp|--servicePrincipalPassword) servicePrincipalPassword="$2"; shift;;
            -cs|--connectionString) connectionString="$2"; shift;;        
            --) shift;;
         esac
         shift;
    done

    # az login --service-principal -u "$servicePrincipal" -p "$servicePrincipalPassword" --tenant "$tenantId"

    echo "Getting Azure App Configuration" >&2
    configuration=$(az appconfig kv list --all --connection-string "$connectionString")

    echo "$configuration"
}

function Get-Shared() {
    echo "Getting all Shared Key-Value pairs" >&2

    json=""
    
    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    allShared=$(Get-JsonFromKeyValue --json "$json" --key "label" --value "Pipeline-Shared")
    echo "All Shared Key-Value pairs was retrieved" >&2
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

    dockerRegistry=$(Get-JsonPropertyFromKey --json "$json" --key "key" --value "Docker-Registry"  --property "value")
    echo "dockerRegistry=$dockerRegistry" >&2

    dockerRegistryUsername=$(Get-JsonPropertyFromKey --json "$json" --key "key" --value "Docker-Username"  --property "value")
    echo "dockerRegistryUsername=$dockerRegistryUsername" >&2

    dockerRegistryPassword=$(Get-JsonPropertyFromKey --json "$json" --key "key" --value "Docker-Password"  --property "value")
    echo "dockerRegistryPassword=$dockerRegistryPassword" >&2
}