FROM registry.access.redhat.com/ubi9/python-311
ARG VERSION_LABEL
# ----- Start as "default" user ----------------------------------------------
# Running as userId = default
# HOME=/opt/app-root

# 1. Upgrade system packages
USER root
RUN dnf update -y --skip-broken --nobest &&\
    dnf upgrade -y --skip-broken --nobest &&\
    dnf install nano jq -y &&\
    dnf clean all

# 2. Upgrade pip, install wheel, then install Python modules
USER default
COPY --chown=default:root install /tmp/install
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel &&\
    python3 -m pip install --no-cache-dir -r /tmp/install/requirements.txt

# 3. Install required tools & Ansible collections
USER root
RUN umask 0002 && \
    bash /tmp/install/install-oc.sh && \
    bash /tmp/install/install-ibmpak.sh && \
    bash /tmp/install/install-ibmcloud.sh && \
    bash /tmp/install/install-skopeo.sh && \
    bash /tmp/install/install-aws.sh && \
    bash /tmp/install/install-helm.sh && \
    bash /tmp/install/install-mongo-tools.sh && \
    bash /tmp/install/install-yq.sh && \
    rm -rf /tmp/install && \
    rm /opt/app-root/src/.wget-hsts /opt/app-root/src/README.md /opt/app-root/src/LICENSE

# 4. Install tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /tini
RUN chmod +x /tini

# 11. Setup working environment
WORKDIR /mascli
ENTRYPOINT ["/tini", "--"]
CMD bash
