#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/.env.sh
source $DIR/.functions.sh

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -r|--repo)
        REPOSITORY="$2"
        ;;

        -b|--buildpath)
        BUILDPATH="$2"
        ;;

        -f|--file)
        DOCKERFILE="$2"
        ;;

        --target-platform)
        TARGET_PLATFORM="$2"
        ;;

        --scap-data-stream)
        SCAP_DATA_STREAM="$2"
        ;;

        *)
        # unknown option, use as additional params directly to docker
        EXTRA_PARAMS="$EXTRA_PARAMS $key $2"
        ;;
    esac
    shift
    shift
done

BUILDPATH="${BUILDPATH:-image}"
DOCKERFILE="${DOCKERFILE:-$BUILDPATH/Dockerfile.$TARGET_PLATFORM}"

# Fallback to $BUILDPATH/Dockerfile if $DOCKERFILE does not exist
if [ ! -e $DOCKERFILE ]; then
  DOCKERFILE="$BUILDPATH/Dockerfile"
fi

LOCAL_TAG=$REPOSITORY:$DOCKER_TAG-$TARGET_PLATFORM

echo_h1 "Build Docker Image"
echo "REPOSITORY ....... $REPOSITORY"
echo "DOCKER_TAG ....... $DOCKER_TAG"
echo "TARGET_PLATFORM .. $TARGET_PLATFORM"
echo "LOCAL_TAG ........ $LOCAL_TAG"
echo
echo "BUILDPATH ........ $BUILDPATH"
echo "DOCKERFILE ....... $DOCKERFILE"
echo "EXTRA_PARAMS ..... $EXTRA_PARAMS"
echo "VERSION_LABEL .... $DOCKER_TAG"
echo "RELEASE_LABEL .... $GITHUB_RUN_ID"
echo "VCS_REF .......... $GITHUB_SHA"
echo "VCS_URL .......... https://github.com/$GITHUB_REPOSITORY"

install_buildx

# Remove expires-after for release builds (only pre-release builds should auto-expire)
if [[ ! "$DOCKER_TAG" == *"-pre."* ]]; then
  echo "Removing quay.expires-after label from Dockerfile"
  sed -i "/quay.expires-after/d" $DOCKERFILE
fi

docker buildx create --name builder-$TARGET_PLATFORM
docker buildx use builder-$TARGET_PLATFORM
docker buildx build --progress plain \
  --load \
  --platform linux/$TARGET_PLATFORM \
  --build-arg ARCHITECTURE=$TARGET_PLATFORM \
  --build-arg VERSION_LABEL=$DOCKER_TAG \
  --build-arg RELEASE_LABEL=$GITHUB_RUN_ID \
  --build-arg VCS_REF=$GITHUB_SHA \
  --build-arg VCS_URL=https://github.com/$GITHUB_REPOSITORY \
  -t $LOCAL_TAG $EXTRA_PARAMS -f $DOCKERFILE $BUILDPATH || exit 1

# 5. Generate OSCAP(Security Content Automation Protocol) report
# ---------------------------------------------------------------------------------------------------------------------
echo_h2 "Generate OSCAP scan report and remediation script"
echo "Target platform ${TARGET_PLATFORM}"
echo "CONFIG_DIR: ${CONFIG_DIR}"
if [[ "$TARGET_PLATFORM" == "" ]] || [[ "$TARGET_PLATFORM" == "amd64" ]]; then
  if [[ "$OSCAP_ENABLED" != "true" ]]; then
    echo "SCAP scan is disabled, set OSCAP_ENABLED=true for SCAP scanning and image hardening during image build ${NAMESPACE}/${IMAGE}:${DOCKER_TAG}"
  else
    install_oscap
    mkdir -p $OSCAP_DIR
    echo "SCAP Data Stream: ${SCAP_DATA_STREAM}.xml"
    echo "Generating OSCAP scan report"
    if [[ "$TARGET_PLATFORM" == "" ]]; then
      sudo $DIR/oscap-docker.sh $REPOSITORY:latest xccdf eval --report $OSCAP_DIR/cli-base-report.html --results $OSCAP_DIR/cli-base-results.xml --profile stig $CONFIG_DIR/oscap/${SCAP_DATA_STREAM}.xml
    else
      sudo $DIR/oscap-docker.sh $REPOSITORY:$DOCKER_TAG-$TARGET_PLATFORM xccdf eval --report $OSCAP_DIR/cli-base-report.html --results $OSCAP_DIR/cli-base-results.xml --profile stig $CONFIG_DIR/oscap/${SCAP_DATA_STREAM}.xml
    fi
    sudo oscap xccdf generate fix --fix-type bash --output $OSCAP_DIR/cli-base-remediation.sh --result-id xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_stig $OSCAP_DIR/cli-base-results.xml
    ls -l $OSCAP_DIR
    # Upload the results to Artifactory
    #$DIR/artifactoryrelease.sh $OSCAP_DIR/$REPOSITORY-report.html --h2 --target-platform "${TARGET_PLATFORM}"
    #$DIR/artifactoryrelease.sh $OSCAP_DIR/$REPOSITORY-results.xml --h2 --target-platform "${TARGET_PLATFORM}"
    #$DIR/artifactoryrelease.sh $OSCAP_DIR/$REPOSITORY-remediation.sh --h2 --target-platform "${TARGET_PLATFORM}"
    #if isReleaseBranch || isMaintenanceDevBranch; then
    #  echo "Saving the oscap scan results to Database"
    #  $DIR/internal/oscap-results.py --namespace $NAMESPACE --image $IMAGE --tag $DOCKER_TAG
    #fi
  fi
else
  echo "OSCAP tooling can only process amd64 container images"
fi

