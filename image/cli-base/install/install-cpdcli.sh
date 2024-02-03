#!/bin/bash

# Install IBM Cloud Pak command line interface
set -e

curl -L https://github.com/IBM/cpd-cli/releases/download/v13.1.2/cpd-cli-linux-EE-13.1.2.tgz -o cpd-cli-linux.tgz
tar -xf cpd-cli-linux.tgz
mv cpd-cli-linux-EE-13.1.2-89 /usr/local/bin/cpd-cli
rm cpd-cli-linux.tgz

cpd-cli version
