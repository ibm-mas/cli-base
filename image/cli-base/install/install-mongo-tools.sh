#!/bin/bash

set -e

# Install Mongo Shell
# -----------------------------------------------------------------------------
# https://github.com/mongodb-js/mongosh/releases
curl "https://github.com/mongodb-js/mongosh/releases/download/v1.10.6/mongodb-mongosh-shared-openssl3-1.10.6.x86_64.rpm" -o mongodb-mongosh-shared.rpm
rpm -i mongodb-mongosh-shared.rpm

mongosh --version
rm mongodb-mongosh-shared.rpm


# Install Mongo Tools
# -----------------------------------------------------------------------------
# https://www.mongodb.com/try/download/database-tools
curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel90-x86_64-100.9.4.tgz" -o mongodb-database-tools.tgz
tar xvfz mongodb-database-tools.tgz

mv mongodb-database-tools-rhel80-x86_64-100.8.0/bin/* /usr/local/bin/
rm -rf mongodb-database-tools-rhel80-x86_64-100.8.0
rm mongodb-database-tools.tgz

mongodump --version
