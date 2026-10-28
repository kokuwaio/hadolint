# busybox contains wget that can be used todownload files and we could reduce the dependencies to one image,
# but wget does not support tls verification (https://github.com/docker-library/busybox/issues/80)
# and wget fails on arch arm64 (https://github.com/docker-library/busybox/issues/162#issuecomment-1773905855)

FROM docker.io/curlimages/curl:8.23.0@sha256:3fb7e13e5d179a845c97d78204f3f1064d1907037f26a3ebf91710571151fd93 AS build
SHELL ["/bin/ash", "-u", "-e", "-o", "pipefail", "-c"]
ARG TARGETARCH
RUN [ "$TARGETARCH" = amd64 ] && export ARCH=x86_64; \
	[ "$TARGETARCH" = arm64 ] && export ARCH=arm64; \
	[ -z "${ARCH:-}" ] && echo "Unknown arch: $TARGETARCH" && exit 1; \
	curl --fail --silent --location --remote-name-all "https://github.com/hadolint/hadolint/releases/download/v2.15.1/{hadolint-linux-$ARCH,checksums.sha256}" && \
	grep "hadolint-linux-$ARCH" checksums.sha256 | sha256sum -csw  && rm checksums.sha256 && \
	mv "hadolint-linux-$ARCH" /tmp/hadolint && chmod +x /tmp/hadolint && \
	/tmp/hadolint --version

FROM docker.io/library/busybox:1.38.0-uclibc@sha256:ddb91a9b37968119844068ea623ee9603f34ad384e2bd9739b9cf573d513c691
COPY --chmod=555 --chown=0:0 --from=build /tmp/hadolint /usr/bin/hadolint
COPY --chmod=555 --chown=0:0 entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
USER 1000:1000
