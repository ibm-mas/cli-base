#!/bin/bash

# Install skopeo & cloudctl & hostname (needed by cloudctl) & httpd-tools (needed for htpasswd cmd)
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

if [[ "$TARGET_PLATFORM" != "arm64" ]]; then
  wget -q https://github.com/IBM/cloud-pak-cli/releases/download/v3.17.0/cloudctl-linux-$TARGET_PLATFORM.tar.gz
  tar -xf cloudctl-linux-$TARGET_PLATFORM.tar.gz
  mv cloudctl-linux-$TARGET_PLATFORM /usr/bin/cloudctl
  rm cloudctl-linux-$TARGET_PLATFORM.tar.gz
fi