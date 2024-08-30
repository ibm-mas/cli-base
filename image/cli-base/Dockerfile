FROM registry.access.redhat.com/ubi9/python-39
ARG VERSION_LABEL
ARG ARCHITECTURE
USER default
COPY --chown=default:root install /tmp/install
USER root
RUN bash /tmp/install/install-rclone.sh --target-platform $ARCHITECTURE