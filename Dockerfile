##
## Download hadolint
##

FROM docker.io/library/debian:12.11-slim@sha256:90522eeb7e5923ee2b871c639059537b30521272f10ca86fdbbbb2b75a8c40cd AS build
SHELL ["/bin/bash", "-u", "-e", "-o", "pipefail", "-c"]
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
	apt-get -qq update && \
	apt-get -qq install --yes --no-install-recommends ca-certificates wget && \
	rm -rf /etc/*- /var/lib/dpkg/*-old /var/lib/dpkg/status /var/cache/* /var/log/*

# https://github.com/hadolint/hadolint/tags
# https://github.com/hadolint/hadolint/issues/245 - Request Signed releases

ARG HADOLINT_VERSION=v2.12.0
RUN ARCH=$(dpkg --print-architecture) && \
	[[ $ARCH == amd64 ]] && export SUFFIX=x86_64; \
	[[ $ARCH == arm64 ]] && export SUFFIX=arm64; \
	[[ -z ${SUFFIX:-} ]] && echo "Unknown arch: $ARCH" && exit 1; \
	wget --no-hsts --quiet \
		"https://github.com/hadolint/hadolint/releases/download/$HADOLINT_VERSION/hadolint-Linux-${SUFFIX}" \
		"https://github.com/hadolint/hadolint/releases/download/$HADOLINT_VERSION/hadolint-Linux-${SUFFIX}.sha256" && \
	sha256sum  --check --strict "hadolint-Linux-$SUFFIX.sha256" && \
	mv "hadolint-Linux-$SUFFIX" /usr/local/bin/hadolint && \
	rm -rf "hadolint-Linux-$SUFFIX.sha256"

##
## Final stage
##

FROM docker.io/library/bash:5.2.37@sha256:64defcbc5126c2d81122b4fb78a629a6d27068f0842c4a8302b8273415b12e30
COPY --link --chown=0:0 --chmod=555 --from=build /usr/local/bin/hadolint /usr/local/bin/hadolint
COPY --link --chown=0:0 --chmod=555 entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/bash", "/usr/local/bin/entrypoint.sh"]
USER 1000:1000
