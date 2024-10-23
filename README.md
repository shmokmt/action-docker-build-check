# GitHub Action: Run `docker build --check` with reviewdog 🐶

[![](https://img.shields.io/github/license/shmokmt/action-docker-build-check)](./LICENSE)
[![Test](https://github.com/shmokmt/action-docker-build-check/actions/workflows/test.yml/badge.svg)](https://github.com/shmokmt/action-docker-build-check/actions/workflows/test.yml)

This action runs `docker build --check` with reviewdog on pull requests to improve code review experience.

## Examples

![image](https://github.com/user-attachments/assets/07d0fbac-72b5-4136-8649-b24176da580f)

## Usage

```yaml
name: reviewdog

on: [pull_request]

permissions:
  contents: read
  pull-requests: write

jobs:
  docker-build-check:
    name: docker-build-check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shmokmt/action-docker-build-check@master
        with:
          github_token: ${{ secrets.github_token }}
```

>[!NOTE]
> We recommend using Ubuntu, the GitHub self hosted runner. This action assumes that Docker and buildx are already installed on your system. If your runner does not have these pre-installed, please set them up yourself.

## See Also
* https://docs.docker.com/reference/build-checks/
* https://github.com/actions/runner-images/
