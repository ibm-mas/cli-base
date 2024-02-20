#!/bin/bash

# Install IBM Pak oc addon
set -e

# https://github.com/IBM/ibm-pak/releases
curl -L https://github.com/IBM/ibm-pak/releases/download/v1.13.0/oc-ibm_pak-linux-amd64.tar.gz -o oc-ibm_pak-linux-amd64.tar.gz
tar -xf oc-ibm_pak-linux-amd64.tar.gz
mv oc-ibm_pak-linux-amd64 /usr/local/bin/oc-ibm_pak
rm oc-ibm_pak-linux-amd64.tar.gz

oc ibm-pak --version
rm -rf /opt/app-root/src/.ibm-pak
