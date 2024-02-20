#!/bin/bash

# Install skopeo & cloudctl & hostname (needed by cloudctl) & httpd-tools (needed for htpasswd cmd)
set -e

dnf install skopeo hostname httpd-tools -y
dnf clean all

# https://github.com/IBM/cloud-pak-cli/releases
wget -q https://github.com/IBM/cloud-pak-cli/releases/download/v3.23.5/cloudctl-linux-amd64.tar.gz
tar -xf cloudctl-linux-amd64.tar.gz
mv cloudctl-linux-amd64 /usr/bin/cloudctl
rm cloudctl-linux-amd64.tar.gz
