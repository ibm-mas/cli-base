#!/bin/bash

# Install yq CLI
set -e
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
     --target-platform)
    TARGET_PLATFORM="$2"
    ;;
        *)
        # unknown option, use as additional params directly to docker
        EXTRA_PARAMS="$EXTRA_PARAMS $key $2"
        ;;
    esac
    shift
    shift
done
#fallback to amd64 if architecture not defined
if [[ "$TARGET_PLATFORM" == "" ]]
  then TARGET_PLATFORM=amd64
fi
curl -L  "https://github.com/mikefarah/yq/releases/download/v4.44.5/yq_linux_${TARGET_PLATFORM}"  > /usr/bin/yq
chmod 755 /usr/bin/yq

echo "yq version:"
yq --version
