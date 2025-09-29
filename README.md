# Hadolint WoodpeckerCI Plugin

[![pulls](https://img.shields.io/docker/pulls/kokuwaio/hadolint)](https://hub.docker.com/r/kokuwaio/hadolint)
[![size](https://img.shields.io/docker/image-size/kokuwaio/hadolint)](https://hub.docker.com/r/kokuwaio/hadolint)
[![dockerfile](https://img.shields.io/badge/source-Dockerfile%20-blue)](https://git.kokuwa.io/woodpecker/hadolint/src/branch/main/Dockerfile)
[![license](https://img.shields.io/badge/License-EUPL%201.2-blue)](https://git.kokuwa.io/woodpecker/hadolint/src/branch/main/LICENSE)
[![prs](https://img.shields.io/gitea/pull-requests/open/woodpecker/hadolint?gitea_url=https%3A%2F%2Fgit.kokuwa.io)](https://git.kokuwa.io/woodpecker/hadolint/pulls)
[![issues](https://img.shields.io/gitea/issues/open/woodpecker/hadolint?gitea_url=https%3A%2F%2Fgit.kokuwa.io)](https://git.kokuwa.io/woodpecker/hadolint/issues)

A [WoodpeckerCI](https://woodpecker-ci.org) plugin for [hadolint](https://github.com/hadolint/hadolint) to lint Dockerfiles.  
Also usable with Gitlab, Github or locally, see examples for usage.

## Features

- preconfigure hadolint parameters
- searches for Dockerfiles recursive
- runnable with local docker daemon

## Example

Woodpecker:

```yaml
steps:
  hadolint:
    depends_on: []
    image: kokuwaio/hadolint:v2.14.0
    settings:
      strict-labels: true
      format: json
    when:
      event: pull_request
      path: [.hadolint.yaml, "**/Dockerfile"]
```

Gitlab: (using script is needed because of <https://gitlab.com/gitlab-org/gitlab/-/issues/19717>)

```yaml
hadolint:
  needs: []
  stage: lint
  image:
    name: kokuwaio/hadolint:v2.14.0
    entrypoint: [""]
  script: [/usr/local/bin/entrypoint.sh]
  variables:
    PLUGIN_STRICT_LABELS: true
    PLUGIN_FORMAT: json
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes: [.hadolint.yaml, "**/Dockerfile"]
```

CLI:

```bash
docker run --rm --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/hadolint --strict-labels --format=json
```

## Settings

| Settings Name           | Environment                  | Default | Description                                                     |
| ----------------------- | ---------------------------- | ------- | --------------------------------------------------------------- |
| `no-fail`               | PLUGIN_NO_FAIL               | `none`  | Don't exit with a failure status code when any rule is violated |
| `no-color`              | PLUGIN_NO_COLOR              | `none`  | Don't colorize output                                           |
| `strict-labels`         | PLUGIN_STRICT_LABELS         | `none`  | Do not permit labels other than specified in `label-schema`     |
| `disable-ignore-pragma` | PLUGIN_DISABLE_IGNORE_PRAGMA | `none`  | Disable inline ignore pragmas `# hadolint ignore=DLxxxx`        |
| `failure-threshold`     | PLUGIN_FAILURE_THRESHOLD     | `style` | Exit with failure code only when rules with a severity equal to or above THRESHOLD are violated. Accepted values: error, warning, info, style, ignore, none |
| `format`                | PLUGIN_FORMAT                | `tty`   | The output format for the results: tty, json, checkstyle, codeclimate, gitlab_codeclimate, gnu, codacy, sonarqube, sarif |
| `verbose`               | PLUGIN_VERBOSE               | `false` | Enables verbose logging of hadolint's output to stderr          |

## Alternatives

| Image                                                                               | Comment                           | amd64 | arm64 |
| ----------------------------------------------------------------------------------- | --------------------------------- |:-----:|:-----:|
| [kokuwaio/hadolint](https://hub.docker.com/r/kokuwaio/hadolint)                     | Woodpecker plugin                 | [![size](https://img.shields.io/docker/image-size/kokuwaio/hadolint?arch=amd64&label=)](https://hub.docker.com/r/kokuwaio/hadolint) | [![size](https://img.shields.io/docker/image-size/kokuwaio/hadolint?arch=arm64&label=)](https://hub.docker.com/r/kokuwaio/hadolint) |
| [hadolint/hadolint](https://hub.docker.com/r/hadolint/hadolint)                     | not a Woodpecker plugin, official | [![size](https://img.shields.io/docker/image-size/hadolint/hadolint?arch=amd64&label=)](https://hub.docker.com/r/hadolint/hadolint) | [![size](https://img.shields.io/docker/image-size/hadolint/hadolint?arch=arm64&label=)](https://hub.docker.com/r/hadolint/hadolint) |
| [pipelinecomponents/hadolint](https://hub.docker.com/r/pipelinecomponents/hadolint) | not a Woodpecker plugin           | [![size](https://img.shields.io/docker/image-size/pipelinecomponents/hadolint?arch=amd64&label=)](https://hub.docker.com/r/pipelinecomponents/hadolint) | [![size](https://img.shields.io/docker/image-size/pipelinecomponents/hadolint?arch=arm64&label=)](https://hub.docker.com/r/pipelinecomponents/hadolint) |
