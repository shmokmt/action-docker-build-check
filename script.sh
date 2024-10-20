#!/bin/bash
set -e
set -o pipefail

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

# echo "::group:: Installing Docker..."
# # Re-install Docker Engine
# for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# # Install from official script
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
# echo "::endgroup"

echo "::group:: docker version"
docker version
echo "::endgroups::"

echo "::group:: docker buildx inspect"
docker buildx inspect
echo "::endgroups::"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

docker_files=$(git ls-files --exclude='*Dockerfile*' --ignored --cached)

for docker_file in "${docker_files[@]}" ; do
    export DOCKER_FILE_PATH=${docker_file}
    check_result=$(docker build -f "${docker_file}" --call=check,format=json . || true)
    echo "$check_result" | jq -f to-rdjson.jq \
      | reviewdog -f=rdjson -name="docker-build-check" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        "${INPUT_REVIEWDOG_FLAGS}"
done