#!/bin/bash
# Install Rclone CLI
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
echo "rclone $PWD"
if [[ "$TARGET_PLATFORM" == "amd64" || "$TARGET_PLATFORM" == "arm64" ]]; then
  curl -O https://downloads.rclone.org/rclone-current-linux-${TARGET_PLATFORM}.zip
  unzip rclone-current-linux-${TARGET_PLATFORM}.zip
  cp ./rclone-*-linux-${TARGET_PLATFORM}/rclone /usr/local/bin/
  rm -rf rclone-*
elif  [[ "$TARGET_PLATFORM" == "s390x" ]]; then
  echo "s390x rclone"
  wget --header="Authorization:Bearer $ARTIFACTORY_TOKEN" https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/rclone/rclone.tar.gz -O $GITHUB_WORKSPACE/image/cli-base/install/rclone.tar.gz
  cd /tmp/install
  tar -xvzf rclone.tar.gz
  cp rclone /usr/local/bin/
  rm -rf rclone.tar.gz
elif [[ "$TARGET_PLATFORM" == "ppc64le" ]]; then

fi

echo "rclone version: "
rclone version