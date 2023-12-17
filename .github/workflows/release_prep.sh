#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_mypy-${TAG}"
ARCHIVE="rules_mypy-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
WORKSPACE snippet:
\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "com_alexmirrington_rules_mypy",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/alexmirrington/rules_mypy/releases/download/${TAG}/${ARCHIVE}",
)
\`\`\`
EOF