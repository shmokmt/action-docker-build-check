# GitHub Action: Run `docker build --check` with action-docker-build-check

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

## See Also
* https://docs.docker.com/reference/build-checks/
