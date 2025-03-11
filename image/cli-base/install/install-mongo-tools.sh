#!/bin/bash

# Install Mongo Shell
set -e
#https://jira.mongodb.org/browse/MONGOSH-1231
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
  curl "https://downloads.mongodb.com/compass/mongodb-mongosh-shared-openssl3-2.3.3.x86_64.rpm" -o mongodb-mongosh-shared-openssl3-2.3.3.x86_64.rpm
  rpm -i mongodb-mongosh-shared-openssl3-2.3.3.x86_64.rpm
  rm mongodb-mongosh-shared-openssl3-2.3.3.x86_64.rpm
elif [[ "$TARGET_PLATFORM" == "arm64" ]]; then
  curl "https://downloads.mongodb.com/compass/mongodb-mongosh-shared-openssl3-2.3.3.aarch64.rpm" -o mongodb-mongosh-shared-openssl3-2.3.3.aarch64.rpm
  rpm -i mongodb-mongosh-shared-openssl3-2.3.3.aarch64.rpm
  rm mongodb-mongosh-shared-openssl3-2.3.3.aarch64.rpm
else
  curl "https://downloads.mongodb.com/compass/mongodb-mongosh-2.3.3.$TARGET_PLATFORM.rpm" -o mongodb-mongosh-2.3.3.$TARGET_PLATFORM.rpm
  rpm -i mongodb-mongosh-2.3.3.$TARGET_PLATFORM.rpm
  rm mongodb-mongosh-2.3.3.$TARGET_PLATFORM.rpm
fi
echo "mongosh version:"
mongosh --version

# Install Mongo Tools
if [[ "$TARGET_PLATFORM" == "amd64" ]]; then
  curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel93-x86_64-100.10.0.tgz" -o mongodb-database-tools-rhel90-x86_64-100.10.0.tgz
elif [[ "$TARGET_PLATFORM" == "arm64" ]]; then
  curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel93-aarch64-100.10.0.tgz" -o mongodb-database-tools-rhel90-aarch64-100.10.0.tgz
elif [[ "$TARGET_PLATFORM" == "ppc64le" ]]; then
  curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel81-ppc64le-100.11.0.tgz" -o mongodb-database-tools-rhel81-$TARGET_PLATFORM-100.10.0.tgz
else
  curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel83-s390x-100.10.0.tgz" -o mongodb-database-tools-rhel83-$TARGET_PLATFORM-100.10.0.tgz

fi
tar xvfz mongodb-database-tools-rhel*.tgz
mv mongodb-database-tools-rhel*/bin/* /usr/local/bin/
rm -rf mongodb-database-tools-rhel*

echo "mongodump version:"
mongodump --version
#mongodump version: 100.10.0
  #git version: 90481484c1783826fe26ca18bbdcd30e933f3b88
  #Go version: go1.21.11
  #   os: linux
  #   arch: s390x
  #   compiler: gc