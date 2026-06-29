# MAS CLI Base Image
This base container image allows us to build the CLI faster by separating the bulk of the image build into it's own repository so that it doesn't have to be built every time we want to make a change to the CLI.

Provides:

| content               | amd64 | s390x | ppc64le | arm64 |
| --------------------- | ----- | ----- | ------- | ----- |
| `python3 v3.12`       |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `ibmcloud v2.38.1`    |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `aws`                 |  ✔️  |  ❌   |  ❌    |  ✔️  |
| `helm v3`             |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `mongosh v2.3.3`      |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `mongodump v100.10.0` |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `oc`                  |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `oc mirror`           |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `oc ibm-pak v1.20.0`  |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `skopeo`              |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `nano`                |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `jq`                  |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `yq v4.49.1`          |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `tini v0.19.0`        |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `rclone`              |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `rosa`                |  ✔️  |  ❌   |  ❌    |  ✔️  |
| `boto3`               |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `argocd`              |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `redis-cli`           |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `ibm_db v3.2.3`       |  ✔️  |  ✔️   |  ✔️    |  ❌  |
| `libxcrypt-compat`    |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `cpio`                |  ✔️  |  ✔️   |  ✔️    |  ✔️  |
| `db2u_migrate`.       |  ✔️  |  ✔️   |  ✔️    |  ✔️  |

**Notes:**
- IBM Cloud `Container-Registry` plugin is supported on ppc64le, however the `Container-Service` plugin is not.
- `ibm_db` (DB2 Python driver) is not supported on arm64 architecture due to upstream limitations.
