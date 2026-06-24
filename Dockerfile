# busybox contains wget that can be used todownload files and we could reduce the dependencies to one image,
# but wget does not support tls verification (https://github.com/docker-library/busybox/issues/80)
# and wget fails on arch arm64 (https://github.com/docker-library/busybox/issues/162#issuecomment-1773905855)

FROM docker.io/curlimages/curl:8.21.0@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13 AS build
SHELL ["/bin/ash", "-u", "-e", "-o", "pipefail", "-c"]
ARG TARGETARCH
RUN [ "$TARGETARCH" = amd64 ] && export ARCH=x86_64; \
	[ "$TARGETARCH" = arm64 ] && export ARCH=arm64; \
	[ -z "${ARCH:-}" ] && echo "Unknown arch: $TARGETARCH" && exit 1; \
	curl --fail --silent --location --remote-name-all "https://github.com/hadolint/hadolint/releases/download/v2.14.0/{hadolint-linux-$ARCH,hadolint-linux-$ARCH.sha256}" && \
	sha256sum -c -s "hadolint-linux-$ARCH.sha256" && rm "hadolint-linux-$ARCH.sha256" && \
	mv "hadolint-linux-$ARCH" /tmp/hadolint && chmod +x /tmp/hadolint && \
	/tmp/hadolint --version

FROM docker.io/library/busybox:1.38.0-uclibc@sha256:eea4ff5612c911abd1d0e9ed47ba642547b01c3490877d9c1bb5fd6346462da4
COPY --chmod=555 --chown=0:0 --from=build /tmp/hadolint /usr/bin/hadolint
COPY --chmod=555 --chown=0:0 entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
USER 1000:1000
