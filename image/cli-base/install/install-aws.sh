#!/bin/bash

# Install AWS CLI
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
if [[ "$TARGET_PLATFORM" == "amd64" ]]
  then TARGET_PLATFORM=x86_64
fi
if [[ "$TARGET_PLATFORM" == "arm64" ]]
  then TARGET_PLATFORM=aarch64
fi
if [[ "$TARGET_PLATFORM" == "s390x" ]]; then
  echo "aws cli not supported in s390x"
  exit 0
fi
if [[ "$TARGET_PLATFORM" == "ppc64le" ]]; then
  echo "aws cli not supported in ppc64le"
  exit 0
fi

curl "https://awscli.amazonaws.com/awscli-exe-linux-${TARGET_PLATFORM}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws
rm  awscliv2.zip
echo "AWS version:"
aws --version

# Set up bash completion for aws. The AWS CLI v2 has no 'completion bash'
# generator, instead it provides the aws_completer binary to be registered
# via complete -C. Files in /etc/bash_completion.d are sourced as shell
# scripts, so the binary itself must not be placed (or symlinked) there.
echo "complete -C '/usr/local/bin/aws_completer' aws" > /etc/bash_completion.d/aws_completion
