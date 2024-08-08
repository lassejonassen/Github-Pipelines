#!/bin/bash

# Define a serie of functions of your framework...
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
    echo "After getting values"
    echo "$value"
}

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