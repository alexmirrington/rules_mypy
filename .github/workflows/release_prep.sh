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

load("@com_alexmirrington_rules_mypy//:repositories.bzl", "rules_mypy_repos")

rules_mypy_repos()

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python_3_11",
    python_version = "3.11",
)

load("@python_3_11//:defs.bzl", "interpreter")

load("@com_alexmirrington_rules_mypy//:pip.bzl", "rules_mypy_py_deps")
rules_mypy_py_deps(
    python_interpreter_target = interpreter,
    requirements_lock = "//:requirements_lock.txt",
)

load("@rules_mypy_pip_deps//:requirements.bzl", install_rules_mypy_pip_deps = "install_deps")

install_rules_mypy_pip_deps()

\`\`\`

BUILD snippet:
\`\`\`starlark
exports_files([
    ".mypy.ini",
])
\`\`\`

Example command:
\`\`\`shell
bazel build --@com_alexmirrington_rules_mypy//config:mypy_config=//:.mypy.ini --aspects @com_alexmirrington_rules_mypy//rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy ...
\`\`\`
EOF