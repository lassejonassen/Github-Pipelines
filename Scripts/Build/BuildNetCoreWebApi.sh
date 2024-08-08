# Script: BuildNetCoreWebApi.sh
# Created at: 2024-08-08
# Description: Builds and Pushes a Docker image for a .NET Core Web API project.

#!/bin/bash
echo "========================================"
echo "BuildNetCoreWebApi.sh - Start"

set -e

echo "Arguments:"
echo "$@"

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# echo "path $SCRIPT_PATH"

parent=$(dirname "$SCRIPT_PATH")
baseDir=$(realpath "$parent")

# echo "path $SCRIPT_PATH"
# echo "scriptBase $baseDir"

# Requires Arguments
source=""
version=""
registry=""
containerName=""
registryUsername=""
registryPassword=""
runCount=1

# Read the Argument values
while [ $# -gt 0 ]
do
    case $1 in
        -s|--source) source="$2"; shift ;;
        -v|--version) version="$2"; shift ;;
        -r|--registry) registry="$2"; shift ;;
        -c|--containerName) containerName="$2"; shift ;;
        -u|--registryUsername) registryUsername="$2"; shift ;;
        -p|--registryPassword) registryPassword="$2"; shift ;;
        -rc|--runCount) runCount="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "source: $source"
echo "version: $version"
echo "registry: $registry"
echo "containerName: $containerName"
echo "registryUsername: $registryUsername"
echo "registryPassword: $registryPassword"
echo "runCount: $runCount"


baseSourceDir=$source
if [ -d "$source/src" ]; then
    source="$source/src"
fi

pushToRegistry=true

echo "Checking if container registry is provided" >&2
echo "Registry: $registry" >&2
if [ "$registry" != "" ]
then
    echo "Pushing to Container Registry" >&2
    echo "Username: $registryUsername" >&2
    echo "Password: $registryPassword" >&2

    if [ "$registryUsername" = "" ]
     then
          echo "Username expected when using remote registry." >&2
          exit 1
     fi
     if [ "$registryPassword" = "" ]
     then
          echo "Passsword expected when using remote registry." >&2
          exit 1
     fi       
     registry="$registry/" 
else
    pushToRegistry=false
    echo "Container Registry not provided. Assuming local, so no push will be done." >&2
fi


allProjectFiles=$(find $source -name "*.csproj" 2>/dev/null)
buildVersion="${version}_${runCount}"

buildImageName="$registry/$containerName-build:$buildVersion"
testImageName="$registry/$containerName-test:$buildVersion"
migrationsImageName="$registry/$containerName-migrations:$buildVersion"
serviceImageName="$registry/$containerName:$buildVersion"


# Build the Docker images
echo "Building images" >&2

buildMigrations=true
migrationFiles=$(find $source -name "Migrations.csproj" 2>/dev/null)

if [ -n "$migrationFiles" ]
then
    echo "Found Migrations project." >&2
else
    echo "No Migrations project found. No container will be made" >&2
    buildMigrations=false
fi

# Building the Build Image
docker build -t "$buildImageName" --target build "$baseSourceDir" >&2
if [ "$?" -ne 0 ]
then
    echo "Failed build step" >&2
    exit 1
fi

# Building the Test Image
docker build -t "$testImageName" --target test "$baseSourceDir" >&2
if [ "$?" -ne 0 ]
then
    echo "Failed building test step" >&2
    exit 1
fi

# Building the Migrations Image
if [ $buildMigrations = true ]; then
    docker build -t "$migrationsImageName" --target migrations "$baseSourceDir" >&2
    if [ "$?" -ne 0 ]
    then
        echo "Failed building migrations step" >&2
        exit 1
    fi
else 
    echo "Migrations was not build as a container since it was not found" >&2
fi

# Building the Service Image
docker build -t "$serviceImageName" --target final "$baseSourceDir" >&2
if [ "$?" -ne 0 ]
then
    echo "Failed building final step" >&2
    exit 1
fi

echo "Building the images was successful" >&2
echo "Now checking if the images should the pushes to container registry" >&2

if $pushToRegistry
then
    echo "Pushing images to container registry: $registry" >&2
    docker login --username $registryUsername --password $registryPassword $registry
    echo "Successfully logged in to container registry: $registry" >&2

    echo "Pushing service image"
    docker push "$serviceImageName" >&2
    if [ "$?" -ne 0 ]
    then
        echo "Failed to push service image" >&2
        exit 1
    fi

    echo "Pushing migrations image"
    docker push "$migrationsImageName" >&2
    if [ "$?" -ne 0 ]
    then
        echo "Failed to push migrations image" >&2
        exit 1
    fi

    echo "Pushing test image"
    docker push "$testImageName" >&2
    if [ "$?" -ne 0 ]
    then
        echo "Failed to push test image" >&2
        exit 1
    fi


else
    echo "No push to registry" >&2
fi

mkdir "$baseSourceDir/config"
'cp' -rf "$jsonFile" "$baseSourceDir/config"

echo ls $baseSourceDir >&2
echo ls $baseSourceDir/config >&2

echo "containerVersion=$buildVersion"

echo "BuildNetCoreWebApi.sh - End"
echo "========================================"