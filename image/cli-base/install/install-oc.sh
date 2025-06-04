#!/bin/bash

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
  shift  # Remove key
  shift  # Remove value
done

# Fallback to amd64 if architecture not defined
if [[ "$TARGET_PLATFORM" == "" ]]
  then TARGET_PLATFORM=amd64
fi

# Install OpenShift CLI (latest stable version)
wget -q https://mirror.openshift.com/pub/openshift-v4/$TARGET_PLATFORM/clients/ocp/stable/openshift-client-linux.tar.gz
tar -zxf openshift-client-linux.tar.gz
mv oc /usr/local/bin/
mv kubectl /usr/local/bin/
rm -f openshift-client-linux.tar.gz

echo "oc version:"
oc version

# Install oc mirror plugin (latest stable version)
wget -q https://mirror.openshift.com/pub/openshift-v4/$TARGET_PLATFORM/clients/ocp/stable/oc-mirror.tar.gz
tar -zxf oc-mirror.tar.gz
mv oc-mirror /usr/local/bin/
chmod +x /usr/local/bin/oc-mirror
rm -f oc-mirror.tar.gz
rm -f /opt/app-root/src/.oc-mirror.log
