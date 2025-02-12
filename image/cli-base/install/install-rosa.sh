#!/bin/bash
# Install ROSA Cli
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
if [[ "$TARGET_PLATFORM" == "s390x" ]]; then
  echo "aws cli not supported in s390x"
  exit 0
fi
if [[ "$TARGET_PLATFORM" == "ppc64le" ]]; then
  echo "aws cli not supported in power"
  exit 0
fi

wget -q https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
tar -xzf rosa-linux.tar.gz
mv rosa /usr/local/bin/
chmod +x /usr/local/bin/rosa
chown default:root /usr/local/bin/rosa
rm -rf rosa-linux.tar.gz

echo "rosa version:"
rosa version