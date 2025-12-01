# ignore pipefail because
# bash is non-default location https://github.com/tianon/docker-bash/issues/29
# hadolint only uses default locations https://github.com/hadolint/hadolint/issues/977
# hadolint global ignore=DL4006

FROM docker.io/library/bash:5.3.8@sha256:2f1d9161bd76a261dff228392a157769c8550fd2a7f51b4d7e182fce56fc2270
SHELL ["/usr/local/bin/bash", "-u", "-e", "-o", "pipefail", "-c"]

ARG TARGETARCH
RUN [[ $TARGETARCH == amd64 ]] && export ARCH=x86_64; \
	[[ $TARGETARCH == arm64 ]] && export ARCH=arm64; \
	[[ -z ${ARCH:-} ]] && echo "Unknown arch: $TARGETARCH" && exit 1; \
	wget -q "https://github.com/hadolint/hadolint/releases/download/v2.14.0/hadolint-Linux-$ARCH" --output-document=/usr/local/bin/hadolint && \
	chmod 555 /usr/local/bin/hadolint

COPY --chmod=555 entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
USER 1000:1000
