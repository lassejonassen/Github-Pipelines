#!/bin/bash


# Function: Get-JsonFromKeyValue
#
# Description: Retrieves a JSON value based on a key-value pair.
#
# Parameters:
#   -j, --json: The JSON string to search in.
#   -k, --key: The key to search for in the JSON.
#   -v, --value: The value to match with the key in the JSON.
#
# Returns:
#   The JSON value that matches the given key-value pair.
function Get-JsonFromKeyValue() {
    json=""
    key=""
    value=""
        
    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              -k|--key) key="$2"; shift;;
              -v|--value) value="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    value=$(echo "$json" | jq -r '[.[] | select(."'"$key"'"=="'"$value"'")]')

    echo "$value"
}


# Function: Get-JsonFromKeyValueLike
#
# Description: Retrieves JSON elements that contain a specific key-value pair.
#
# Parameters:
#   -j, --json: The JSON string to search in.
#   -k, --key: The key to search for in the JSON elements.
#   -v, --value: The value to search for in the JSON elements.
#
# Returns:
#   The JSON elements that contain the specified key-value pair.
function Get-JsonFromKeyValueLike() {
    json=""
    key=""
    value=""
    
    
    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              -k|--key) key="$2"; shift;;
              -v|--value) value="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    value=$(echo "$json" | jq '[.[] | select(."'"$key"'" | contains("'"$value"'"))]')

    echo "$value"
}


# Function: Get-JsonPropertryFromKey
#
# Description: Retrieves the value of a specific property from a JSON object based on a given key-value pair.
#
# Parameters:
#   -j, --json: The JSON object to search within.
#   -k, --key: The key to match against the provided value.
#   -v, --value: The value to match against the provided key.
#   -p, --property: The property to retrieve the value from.
#
# Returns:
#   The value of the specified property, if found. Otherwise, an empty string is returned.
function Get-JsonPropertryFromKey() {
    json=""
    key=""
    value=""
    property=""

    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              -k|--key) key="$2"; shift;;
              -v|--value) value="$2"; shift;;
              -p|--property) property="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    value=$(echo "$json" | jq -r --arg prop "$property" '.[] | select(."'"$key"'"=="'"$value"'") |.[$prop]')

    echo "$value"
}


# Function: Get-JsonProperty
#
# Description: Retrieves the value of a specified property from a JSON object.
#
# Parameters:
#   -j, --json: The JSON object.
#   -p, --property: The property to retrieve the value from.
#
# Usage: 
#   Get-JsonProperty -j <json> -p <property>
#
# Returns:
#   The value of the specified property from the JSON object.
function Get-JsonProperty() {
    json=""
    property=""
    
    while [ $# -gt 0 ]
    do
         case "$1" in
              -j|--json) json="$2"; shift;;
              -p|--property) property="$2"; shift;;
              --) shift;;
         esac
         shift;
    done

    value=$(echo "$json" | jq ".[0].$property")    

    echo "$value"
}