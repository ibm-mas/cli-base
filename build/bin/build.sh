#!/bin/bash
set -e

TARGET_PLATFORM=$1
echo "GITHUB_REF=$GITHUB_REF"
echo "GITHUB_EVENT_NAME=$GITHUB_EVENT_NAME"

# Login to quay.io
docker login --username "${{ secrets.QUAYIO_USERNAME }}" --password "${{ secrets.QUAYIO_PASSWORD }}" quay.io
if [[ "$TARGET_PLATFORM" != "amd64" ] || [ "$TARGET_PLATFORM" != "arm64" ]];
then
 # Before we build the s390x image we need to download some pre-build dependencies from Artifactory
    #wget --header="Authorization:Bearer $ARTIFACTORY_TOKEN" https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/rclone/rclone.tar.gz -O $GITHUB_WORKSPACE/image/cli-base/install/rclone.tar.gz
    echo "after rclone"
    python3 $GITHUB_WORKSPACE/build/bin/python-collect-prebuilt-wheels.py --req-file $GITHUB_WORKSPACE/image/cli-base/install/requirements.txt --dest $GITHUB_WORKSPACE/image/cli-base/install/ --add-dependency cryptography --target-platform $TARGET_PLATFORM
fi
# Build the image
$GITHUB_WORKSPACE/build/bin/docker-build.sh -r quay.io/ibmmas/cli-base --target-platform $TARGET_PLATFORM -b image/cli-base

# Squash the image layers
python3 -m pip install docker-squash
docker-squash --load-image --tag quay.io/ibmmas/cli-base:${{ env.DOCKER_TAG }}-$TARGET_PLATFORM quay.io/ibmmas/cli-base:${{ env.DOCKER_TAG }}-$TARGET_PLATFORM

# List available images
docker images

# Push the images
docker push quay.io/ibmmas/cli-base:${{ env.DOCKER_TAG }}-$TARGET_PLATFORM
