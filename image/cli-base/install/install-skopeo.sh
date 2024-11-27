#!/bin/bash

# Install skopeo, hostname & httpd-tools (needed for htpasswd cmd)
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
if [[ "$TARGET_PLATFORM" == "" ]]
  then TARGET_PLATFORM=amd64
fi
dnf install skopeo hostname httpd-tools -y
dnf clean all

echo "skopeo verison:"
skopeo --version