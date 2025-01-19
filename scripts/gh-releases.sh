#!/bin/bash

# Function to get the latest release version from GitHub
get_latest_release() {
    local repo=$1
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub API
        grep '"tag_name":' |                                             # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                     # Extract version number
}

# Retrieve all GitHub Releases from Dockerfile
deps=$(cat Dockerfile | grep "depName" | cut -d"=" -f2)

for dep in $(echo $deps); do
    echo "processing ${dep}"
    latest_version=$(get_latest_release $dep)
    echo "latest available version is ${latest_version}"
    current_version=$(cat Dockerfile | grep "depName=$dep" -A1 | grep "ENV" | cut -d"=" -f2 | sed 's/"//g')
    echo "current version is ${current_version}"
    if [ "$dep" == "tfutils/tfenv" ]; then
        latest_version=$(echo $latest_version | sed 's/^v//')
    fi
    if [ "$latest_version" != "$current_version" ]; then
        old_string=$(cat Dockerfile | grep "depName=$dep" -A1 | grep "ENV")
        new_string=$(cat Dockerfile | grep "depName=$dep" -A1 | grep "ENV" | sed "s/$current_version/$latest_version/g")
        sed -i "s/$old_string/$new_string/g" Dockerfile
        echo "Updated $dep from $current_version to $latest_version in Dockerfile"
    fi
done
