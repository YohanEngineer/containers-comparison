#!/usr/bin/env bash
set -e

PATH=$PATH:/home/toto/acbuild/bin

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

# Start the build with an empty ACI
acbuild --debug begin

# In the event of the script exiting, end the build
trap '{ export EXT=$?; acbuild --debug end && exit $EXT; }' EXIT

# Name the ACI
acbuild --debug set-name frontend-thesis

acbuild --debug dep add quay.io/coreos/alpine-sh

acbuild --debug run -- apk update
acbuild --debug run -- apk add nodejs

# Set the working directory in the ACI
acbuild --debug set-working-directory /usr/src/app

# Copy package.json and package-lock.json to the ACI
acbuild --debug copy ./package*.json /usr/src/app/

# Install dependencies in the ACI
acbuild --debug run -- npm install

# Copy the rest of your app's source code to the ACI
acbuild --debug copy . /usr/src/app/

# Have the app listen on port 3000
acbuild --debug environment add PORT 3000

# Add a port for http traffic on port 3000
acbuild --debug port add http tcp 3000

# Run the application
acbuild --debug set-exec -- /usr/local/bin/node /usr/src/app/server.js

# Write the result
acbuild --debug write --overwrite frontend-thesis-linux-arm64.aci
