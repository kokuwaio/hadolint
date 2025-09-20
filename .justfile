# https://just.systems/man/en/

[private]
@default:
	just --list --unsorted

# Run linter.
@lint:
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/shellcheck
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/hadolint
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/yamllint
	docker run --rm --read-only --volume=$(pwd):$(pwd):rw --workdir=$(pwd) kokuwaio/markdownlint --fix
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/renovate-config-validator
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) woodpeckerci/woodpecker-cli lint

# Build image with local docker daemon.
@build:
	docker buildx build . --build-arg=NPM_CONFIG_REGISTRY --platform=linux/amd64,linux/arm64

# Print image size.
size:
	#!/usr/bin/env bash
	docker run --quiet --detach --publish=5000:5000 --name=registry registry >/dev/null
	docker build . --build-arg=NPM_CONFIG_REGISTRY --quiet --tag localhost:5000/i --push >/dev/null
	printf "uncompressed: %'14d bytes (on your disk)\n" "$(docker image inspect localhost:5000/i --format='{{{{.Size}}')"
	printf "compressed:   %'14d bytes (transferred from registry to disk)\n" "$(docker manifest inspect localhost:5000/i --insecure | jq .layers[].size | tr '\n' '+' | cat - <(echo "0") | bc)"
	docker rm registry --force --volumes >/dev/null 2>&1

# Inspect image layers with `dive`.
@dive TARGET="":
	dive build . --build-arg=NPM_CONFIG_REGISTRY --target={{TARGET}}

# Test created image.
@test:
	docker build . --build-arg=NPM_CONFIG_REGISTRY --tag=kokuwaio/hadolint:dev
	docker run --rm --read-only --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/hadolint:dev
