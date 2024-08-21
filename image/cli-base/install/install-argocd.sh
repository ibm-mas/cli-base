#!/bin/bash

# Install ArgoCD CLI
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
curl -sSL -o argocd-linux-${TARGET_PLATFORM} https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${TARGET_PLATFORM} && \
    install -m 555 argocd-linux-${TARGET_PLATFORM} /usr/local/bin/argocd && \
    rm argocd-linux-${TARGET_PLATFORM}