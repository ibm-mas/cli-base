#!/bin/bash

# Install Helm for argocd sidecar
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
if [[ "$TARGET_PLATFORM" == "amd64" ]]; then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  chown default:root /usr/local/bin/helm
  chmod  g=u /usr/local/bin/helm
  chmod 777 /usr/local/bin/helm
else
  curl -L https://get.helm.sh/helm-v3.16.3-linux-${TARGET_PLATFORM}.tar.gz -o helm-v3.16.3-linux-${TARGET_PLATFORM}.tar.gz
  tar -xvzf helm-v3.16.3-linux-${TARGET_PLATFORM}.tar.gz
  cd linux-${TARGET_PLATFORM}
  mv helm /usr/local/bin/
  chmod  g=u /usr/local/bin/helm
  chmod 777 /usr/local/bin/helm
fi
echo "Helm version:"
helm version