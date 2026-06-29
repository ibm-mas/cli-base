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

mv /tmp/install/bin/db2u_migrate-$TARGET_PLATFORM /usr/local/bin/db2u_migrate
chmod +x /usr/local/bin/db2u_migrate

echo "db2_migrate --help"
db2u_migrate --help
