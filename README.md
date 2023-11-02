# MAS CLI Base Image
This base container image allows us to build the CLI faster by seperating the bulk of the image build into it's own repository so that it doesn't jhave to be built every time we want to make a change to the CLI.

Provides:

- `python3` v3.9
- `ibmcloud` v2.12.1
- `aws`
- `helm` v3
- `cloudctl` v3.17.0
- `mongosh` v1.10.5
- `mongodump` v100.8.0
- `oc`
- `oc mirror`
- `oc ibm-pak` v1.3.1
- `skopeo`
- `nano`
- `jq`
- `yq` v4.35.1
- `tini` v0.19.0
