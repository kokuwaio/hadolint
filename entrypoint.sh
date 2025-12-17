#!/bin/sh
set -eu;

##
## build command
##

COMMAND="hadolint"
if [ -n "${PLUGIN_FORMAT:-}" ]; then
	COMMAND="$COMMAND --format=$PLUGIN_FORMAT"
fi
if [ -n "${PLUGIN_FAILURE_THRESHOLD:-}" ]; then
	COMMAND="$COMMAND --failure-threshold=$PLUGIN_FAILURE_THRESHOLD"
else
	COMMAND="$COMMAND --failure-threshold=style"
fi
if [ "${PLUGIN_STRICT_LABELS:-}" = "true" ]; then
	COMMAND="$COMMAND --strict-labels"
fi
if [ "${PLUGIN_VERBOSE:-}" = "true" ]; then
	COMMAND="$COMMAND --verbose"
fi
if [ "${PLUGIN_DISABLE_IGNORE_PRAGMA:-}" = "true" ]; then
	COMMAND="$COMMAND --disable-ignore-pragmal"
fi
if [ "${PLUGIN_NO_COLOR:-}" = "true" ]; then
	COMMAND="$COMMAND --no-color"
fi
if [ "${PLUGIN_NO_FAIL:-}" = "true" ]; then
	COMMAND="$COMMAND --no-fail"
fi

# custom args, e.g. docker run --rm --volume=$(pwd):$(pwd) --workdir=$(pwd) --env=CI=test kokuwaio/hadolint --format=json
if [ -n "${1:-}" ]; then
	COMMAND="$COMMAND $*"
fi

##
## collect files
##

FILES=$(find "$PWD" -type f \( -name 'Dockerfile' -o -name 'Containerfile' \) -not -path '*/node_modules/*')
if [ ! "$FILES" ]; then
	echo "No files found!"
	exit 1
fi
for FILE in ${FILES}; do
	COMMAND="$COMMAND $FILE"
done

##
## evecute command
##

echo "$COMMAND"
eval "$COMMAND"
