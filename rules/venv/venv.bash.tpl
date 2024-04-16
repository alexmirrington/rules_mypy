#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Fully resolve interpreter executable to ensure we use the right one.
INTERPRETER="$({PYTHON_INTERPRETER_PATH} -c 'import sys;from pathlib import Path;print(Path(sys.executable).resolve())')"
PYTHON_MINOR_VERSION="$({PYTHON_INTERPRETER_PATH} -c 'import sys;print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
# With symlink following we get:
# /private/var/tmp/_bazel_alex/92566e41395ad559c6d11180c29adade/external/python_3_11_aarch64-apple-darwin/bin/python3.11
# otherwise we will get:
# /private/var/tmp/_bazel_alex/92566e41395ad559c6d11180c29adade/sandbox/darwin-sandbox/656/execroot/_main/external/rules_python~0.31.0~python~python_3_11_aarch64-apple-darwin/bin/python3

${INTERPRETER} -m venv --without-pip {VENV_LOCATION}

site_packages="{VENV_LOCATION}/lib/python${PYTHON_MINOR_VERSION}/site-packages"

# TODO(alexmirrington): Move this to some other action or another script and include in runfiles
${INTERPRETER} -c "
import os

with open('{DEPS_PATH}', 'r') as f:
    for line in f.readlines():
        site_packages = '${site_packages}'
        src = os.readlink(line.rstrip())
        dst = os.path.join(site_packages, line.rstrip().split('site-packages/')[-1])
        # Make directories and symlink if they don't already exist
        os.makedirs(name=os.path.dirname(dst), exist_ok=True)
        if not os.path.exists(dst):
            os.symlink(src, dst)
"
