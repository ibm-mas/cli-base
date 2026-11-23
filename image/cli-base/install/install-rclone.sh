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
  echo "rclone version: "
  rclone version
else
  echo "WARNING: rclone is not available for ${TARGET_PLATFORM}, skipping installation"
fi