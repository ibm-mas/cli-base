#!/bin/bash

# Install Rclone CLI
set -e

curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip

cp ./rclone-*-linux-amd64/rclone /usr/local/bin/

rclone version

rm -rf rclone-*

#s390x not supported
#[root@aca72e69ab39 rclone-v1.65.2-linux-mipsle]# rclone version
 #bash: /usr/local/bin/rclone: cannot execute binary file: Exec format error