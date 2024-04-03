#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Fully resolve interpreter executable to ensure we use the right one.
INTERPRETER="$({PYTHON_INTERPRETER_PATH} -c 'import sys;from pathlib import Path;print(Path(sys.executable).resolve())')"
# With symlink following we get:
# /private/var/tmp/_bazel_alex/92566e41395ad559c6d11180c29adade/external/python_3_11_aarch64-apple-darwin/bin/python3.11
# otherwise we will get:
# /private/var/tmp/_bazel_alex/92566e41395ad559c6d11180c29adade/sandbox/darwin-sandbox/656/execroot/_main/external/rules_python~0.31.0~python~python_3_11_aarch64-apple-darwin/bin/python3

${INTERPRETER} -m venv --without-pip {VENV_LOCATION}
ls -la {VENV_LOCATION}/bin/

site_packages="{VENV_LOCATION}/lib/python3.11/site-packages"

# TODO(alexmirrington): This is super slow, make it faster by resolving site-packages symlinks differently.
while read -r line; do
  basepath="${line##*/}"
  dirpath=${line%${basepath}}
  mkdir -p "${site_packages}/${dirpath##*site-packages/}"
  ln -snf "$(readlink ${line})" "${site_packages}/${line##*site-packages/}"
done <{DEPS_PATH}
