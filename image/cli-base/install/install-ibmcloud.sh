#!/bin/bash

# Install IBM CLoud CLI with container-service plugin
set -e

wget -q https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.12.1/IBM_Cloud_CLI_2.12.1_amd64.tar.gz
tar -xzf IBM_Cloud_CLI_2.12.1_amd64.tar.gz
mv Bluemix_CLI/bin/ibmcloud /usr/local/bin/
rm -rf Bluemix_CLI IBM_Cloud_CLI_2.12.1_amd64.tar.gz
ibmcloud plugin repo-plugins -r 'IBM Cloud'
ibmcloud plugin install container-service
ibmcloud plugin install container-registry

# We don't want remove the plugins (in .bluemix/plugins) only the configuration file generated by the above actions
rm /opt/app-root/src/.bluemix/config.json

# Fix up permissions so that the group has the same permissions as the (root) user
chown -R default:root /opt/app-root/src/.bluemix
chmod -R g=u /opt/app-root/src/.bluemix
