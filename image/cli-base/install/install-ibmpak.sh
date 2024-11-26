#!/bin/bash

# Install IBM Pak oc addon
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

if [[ "$TARGET_PLATFORM" != "arm64" ]]; then
  curl -L https://github.com/IBM/ibm-pak-plugin/releases/download/v1.3.1/oc-ibm_pak-linux-$TARGET_PLATFORM.tar.gz -o oc-ibm_pak-linux-$TARGET_PLATFORM.tar.gz
  tar -xf oc-ibm_pak-linux-$TARGET_PLATFORM.tar.gz
  mv oc-ibm_pak-linux-$TARGET_PLATFORM /usr/local/bin/oc-ibm_pak
  rm oc-ibm_pak-linux-$TARGET_PLATFORM.tar.gz
  oc ibm-pak --version
  rm -rf /opt/app-root/src/.ibm-pak
fi

# Waiting for release
if [[ "$TARGET_PLATFORM" == "arm64" ]]; then
  # tar -xf /tmp/install/oc-ibm_pak-linux-$TARGET_PLATFORM
  mv /tmp/install/oc-ibm_pak-linux-$TARGET_PLATFORM /usr/local/bin/oc-ibm_pak
  chmod +x /usr/local/bin/oc-ibm_pak
  # rm oc-ibm_pak-linux-$TARGET_PLATFORM.tar.gz
  oc ibm-pak --version
fi