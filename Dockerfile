# ignore pipefail because
# bash is non-default location https://github.com/tianon/docker-bash/issues/29
# hadolint only uses default locations https://github.com/hadolint/hadolint/issues/977
# hadolint global ignore=DL4006

FROM docker.io/library/bash:5.3.0@sha256:6a3e1c2ddbdee552cd69ad8244eee84ad6cc00049c338f700ef5ef247be16f7b
SHELL ["/usr/local/bin/bash", "-u", "-e", "-o", "pipefail", "-c"]

RUN ARCH=$(uname -m) && \
	[[ $ARCH == x86_64 ]] && export SUFFIX=x86_64; \
	[[ $ARCH == aarch64 ]] && export SUFFIX=arm64; \
	[[ -z ${SUFFIX:-} ]] && echo "Unknown arch: $ARCH" && exit 1; \
	wget -q "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-$SUFFIX" --output-document=/usr/local/bin/hadolint && \
	chmod 555 /usr/local/bin/hadolint

COPY --chmod=555 entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
USER 1000:1000
