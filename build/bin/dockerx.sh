#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/.functions.sh

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -n|--namespace)
    NAMESPACE="$2"
    ;;

    -i|--image)
    IMAGE="$2"
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

    *)
    # unknown option, use as additional params directly to docker
    EXTRA_PARAMS="$EXTRA_PARAMS $key $2"
    ;;
  esac
  shift  # $1 (key)
  shift  # $2 (value)
done

# 1. Prepare
# ---------------------------------------------------------------------------------------------------------------------
BUILDPATH="${BUILDPATH:-image/$IMAGE}"
DOCKERFILE="${DOCKERFILE:-$BUILDPATH/Dockerfile.$TARGET_PLATFORM}"

# Fallback to $BUILDPATH/Dockerfile if $DOCKERFILE does not exist
if [ ! -e $DOCKERFILE ]; then
  DOCKERFILE="$BUILDPATH/Dockerfile"
fi

if [ ! -e $DOCKERFILE ]; then
  echo_warning "$DOCKERFILE does not exist"
  exit 1
fi

# Note: Travis will ******* out the sensitive information here, but it will prove that
# the value matches the value in the config if it does, which is the goal!
echo_h1 "Docker Build: $NAMESPACE/$IMAGE"
echo "TARGET_PLATFORM ............. $TARGET_PLATFORM"
echo "BUILDPATH ................... $BUILDPATH"
echo "DOCKERFILE .................. $DOCKERFILE"
echo "EXTRA_PARAMS ................ $EXTRA_PARAMS"
echo "VERSION_LABEL ............... $VERSION"
echo "RELEASE_LABEL ............... $TRAVIS_BUILD_NUMBER"
echo "VCS_REF ..................... $TRAVIS_COMMIT"
echo "VCS_URL ..................... https://github.ibm.com/$TRAVIS_REPO_SLUG"

if [[ "$TARGET_PLATFORM" != "" ]] && [[ "$TARGET_PLATFORM" != "amd64" ]]; then
  install_buildx
fi


# 2. Build
# ---------------------------------------------------------------------------------------------------------------------
# For preview builds we override the version to apply specific build number to the version string.  This allows
# the operator to differentiate between individual builds of the same pre-release.
if [[ "$TRAVIS_BRANCH" == "$PREVIEW_BRANCH" ]]; then
  echo_highlight "Overriding VERSION_LABEL for preview build to '${VERSION}+${TRAVIS_BUILD_NUMBER}'"
  VERSION=${VERSION}+${TRAVIS_BUILD_NUMBER}
fi

if [[ "$TARGET_PLATFORM" == "" ]] || [[ "$TARGET_PLATFORM" == "amd64" ]]; then
  if [[ "$TARGET_PLATFORM" == "amd64" ]]
  then LOCAL_TAG=$NAMESPACE/$IMAGE:$TARGET_PLATFORM
  else LOCAL_TAG=$NAMESPACE/$IMAGE
  fi
  travis_fold start dockerbuild
  echo_highlight "Running single-architecture build using docker build >>>"
  docker build --progress plain \
    --build-arg ARCHITECTURE=amd64 \
    --build-arg VERSION_LABEL=$VERSION \
    --build-arg RELEASE_LABEL=$TRAVIS_BUILD_NUMBER \
    --build-arg VCS_REF=$TRAVIS_COMMIT \
    --build-arg VCS_URL=https://github.ibm.com/$TRAVIS_REPO_SLUG \
    -t $LOCAL_TAG $EXTRA_PARAMS -f $DOCKERFILE $BUILDPATH || exit 1
  travis_fold end dockerbuild
else
  LOCAL_TAG=$NAMESPACE/$IMAGE:$TARGET_PLATFORM
  travis_fold start dockerbuildx
  echo_highlight "Running multi-architecture build using docker buildx >>>"
  docker buildx build --progress plain \
    --load \
    --platform linux/$TARGET_PLATFORM \
    --build-arg ARCHITECTURE=$TARGET_PLATFORM \
    --build-arg VERSION_LABEL=$VERSION \
    --build-arg RELEASE_LABEL=$TRAVIS_BUILD_NUMBER \
    --build-arg VCS_REF=$TRAVIS_COMMIT \
    --build-arg VCS_URL=https://github.ibm.com/$TRAVIS_REPO_SLUG \
    -t $LOCAL_TAG $EXTRA_PARAMS -f $DOCKERFILE $BUILDPATH || exit 1
  travis_fold end dockerbuildx
fi

