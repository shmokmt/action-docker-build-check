#!/bin/bash
set -e
set -o pipefail

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo "::group:: docker version"
docker version
echo "::endgroups::"

echo "::group:: docker buildx inspect"
docker buildx inspect
echo "::endgroups::"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

docker_build_jq='{
 source: {
  name: "docker-build-check",
  url: "https://docs.docker.com/reference/build-checks/",
},
severity: "WARNING",
diagnostics: .warnings | map({
  message: .description,
  location: {
    "path": $ENV.DOCKER_FILE_PATH,
    "range": {
      "start": {
        "line": .location.ranges[].start.line
      },
      "end": {
        "line": .location.ranges[].end.line
      },
    },
  },
  severity: "WARNING",
  code: {
    "value": .ruleName,
    "url": .url,
  },
})
}'

docker_files=$(git ls-files --exclude='*Dockerfile*' --ignored --cached)

for docker_file in "${docker_files[@]}" ; do
    export DOCKER_FILE_PATH=${docker_file}
    check_result=$(docker build -f "${docker_file}" --call=check,format=json . || true)
    echo "$check_result" | jq "$docker_build_jq" \
      | reviewdog -f=rdjson -name="docker-build-check" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        "${INPUT_REVIEWDOG_FLAGS}"
done
