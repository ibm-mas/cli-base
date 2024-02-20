# MAS CLI Base Image
This base container image allows us to build the CLI faster by seperating the bulk of the image build into it's own repository so that it doesn't jhave to be built every time we want to make a change to the CLI.

Provides:

- `python3` v3.9
- `ibmcloud` v2.23.0
- `aws` latest
- `helm` v3
- `cloudctl` v3.23.5
- `mongosh` v1.10.5
- `mongodump` v100.8.0
- `oc` latest
- `oc mirror` latest
- `oc ibm-pak` v1.13.0
- `skopeo`
- `nano`
- `jq`
- `yq` v4.41.1
- `tini` v0.19.0

Python Modules:
- `junit_xml` 1.9
- `pymongo` 4.6.1
- `xmljson` 0.2.1
- `ansible` 9.2.0
- `kubernetes` 29.0.0
- `openshift` 0.13.2
- `jmespath` 1.0.1
- `click` 8.1.7
- `prettytable` 3.10.0
- `slackclient` 2.9.4
- `jira` 3.6.0
