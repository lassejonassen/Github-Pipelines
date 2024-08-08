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

    echo "Getting Azure App Configuration"
    echo "Azure App Configuration ConnectionString: $connectionString"
    configuration=$(az appconfig kv list --all --connection-string "$connectionString")

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