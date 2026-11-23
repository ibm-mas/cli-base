#!/bin/bash
set -e

TARGET_PLATFORM=$1
echo "GITHUB_REF=$GITHUB_REF"
echo "GITHUB_EVENT_NAME=$GITHUB_EVENT_NAME"

# The Dockerfile always copies and runs remediate.sh. If the repository does not provide one, use a no-op script.
export OSCAP_REMEDIATION_FILE=${GITHUB_WORKSPACE}/image/cli-base/remediate.sh
if [[ ! -e ${OSCAP_REMEDIATION_FILE} ]]; then
    echo "WARNING: ${OSCAP_REMEDIATION_FILE} not found, image hardening (remediation) will be skipped"
    printf '#!/bin/bash\necho "No remediation script provided, skipping"\n' > ${OSCAP_REMEDIATION_FILE}
fi

# Login to quay.io
docker login --username $QUAYIO_USERNAME --password $QUAYIO_PASSWORD quay.io

# Build the image
$GITHUB_WORKSPACE/build/bin/docker-build.sh -r quay.io/ibmmas/cli-base --target-platform $TARGET_PLATFORM -b image/cli-base --scap-data-stream ssg-rhel9-ds

# Squash the image layers
python3 -m pip install docker-squash
docker-squash --load-image --tag quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM

# List available images
docker images

# Push the images
docker push quay.io/ibmmas/cli-base:$DOCKER_TAG-$TARGET_PLATFORM
