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
  if [[ "$TARGET_PLATFORM" == "amd64" ]]; then
    curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip rclone-current-linux-amd64.zip
    cp ./rclone-*-linux-amd64/rclone /usr/local/bin/
    rclone version
    rm -rf rclone-*
  else
    echo "s390x rclone"
    cd /tmp/install
    #wget -q --header="Authorization:Bearer $ARTIFACTORY_TOKEN" https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/rclone/rclone.tar.gz
    ls -lrt
    tar -xvzf rclone.tar.gz
    ls -lrt
    cp rclone /usr/local/bin/
    rclone version
    rm -rf rclone.tar.gz
  fi