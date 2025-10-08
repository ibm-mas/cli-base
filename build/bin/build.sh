#!/bin/bash
set -e

TARGET_PLATFORM=$1
echo "GITHUB_REF=$GITHUB_REF"
echo "GITHUB_EVENT_NAME=$GITHUB_EVENT_NAME"

# Copy OSCAP remediation file from artifactory
wget --header="Authorization:Bearer ${ARTIFACTORY_TOKEN}" ${OSCAP_REMEDIATION_URL} -O ${OSCAP_REMEDIATION_FILE}

# Login to quay.io
docker login --username $QUAYIO_USERNAME --password $QUAYIO_PASSWORD quay.io
if [[ "$TARGET_PLATFORM" == "s390x" || "$TARGET_PLATFORM" == "ppc64le" ]]; then
 # Before we build the s390x image we need to download some pre-build dependencies from Artifactory
    echo "in ... $TARGET_PLATFORM"
    wget --header="Authorization:Bearer $ARTIFACTORY_TOKEN" https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/rclone/$TARGET_PLATFORM/rclone.tar.gz -O $GITHUB_WORKSPACE/image/cli-base/install/rclone.tar.gz
    python3 $GITHUB_WORKSPACE/build/bin/python-collect-prebuilt-wheels.py --req-file $GITHUB_WORKSPACE/image/cli-base/install/requirements.txt --dest $GITHUB_WORKSPACE/image/cli-base/install/ --add-dependency cryptography --target-platform $TARGET_PLATFORM
fi
# Build the image
$GITHUB_WORKSPACE/build/bin/docker-build.sh -r quay.io/ibmmas/cli-base --target-platform $TARGET_PLATFORM -b image/cli-base --scap-data-stream ssg-rhel9-ds

# Squash the image layers
python3 -m pip install docker-squash
docker-squash --load-image --tag quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM

# List available images
docker images

# Push the images
docker push quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM
