# busybox contains wget that can be used todownload files and we could reduce the dependencies to one image,
# but wget does not support tls verification (https://github.com/docker-library/busybox/issues/80)
# and wget fails on arch arm64 (https://github.com/docker-library/busybox/issues/162#issuecomment-1773905855)

FROM docker.io/curlimages/curl:8.18.0@sha256:d94d07ba9e7d6de898b6d96c1a072f6f8266c687af78a74f380087a0addf5d17 AS build
SHELL ["/bin/ash", "-u", "-e", "-o", "pipefail", "-c"]
ARG TARGETARCH
RUN [ "$TARGETARCH" = amd64 ] && export ARCH=x86_64; \
	[ "$TARGETARCH" = arm64 ] && export ARCH=arm64; \
	[ -z "${ARCH:-}" ] && echo "Unknown arch: $TARGETARCH" && exit 1; \
	curl --fail --silent --location --remote-name-all "https://github.com/hadolint/hadolint/releases/download/v2.14.0/{hadolint-linux-$ARCH,hadolint-linux-$ARCH.sha256}" && \
	sha256sum -c -s "hadolint-linux-$ARCH.sha256" && rm "hadolint-linux-$ARCH.sha256" && \
	mv "hadolint-linux-$ARCH" /tmp/hadolint && chmod +x /tmp/hadolint && \
	/tmp/hadolint --version

FROM docker.io/library/busybox:1.37.0-uclibc@sha256:68fb61caa577f233800d50bef8fe0ee1235ed56a641178783032935223630576
COPY --chmod=555 --chown=0:0 --from=build /tmp/hadolint /usr/bin/hadolint
COPY --chmod=555 --chown=0:0 entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
USER 1000:1000
