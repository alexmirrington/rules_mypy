#!/usr/bin/env bash

{VERBOSE_BASH}
set -o errexit
set -o nounset
set -o pipefail

main() {
  local output
  local report_file
  local status

  report_file="{OUTPUT}"

  export MYPYPATH="$(pwd):{MYPYPATH_PATH}"

  set +o errexit
  output=$({PY_INTERPRETER} -m mypy {VERBOSE_OPT}  --bazel {PACKAGE_ROOTS} --config-file {MYPY_INI_PATH} --cache-map {CACHE_MAP_TRIPLES} -- {SRCS} 2>&1)
  status=$?
  set -o errexit

  if [ ! -z "$report_file" ]; then
    echo "${output}" > "${report_file}"
  fi

  if [[ $status -ne 0 ]]; then
    # Show type checking errors to end-user via Bazel's console logging
    # TODO(alexmirrington): Consider UX improvements using https://mypy.readthedocs.io/en/stable/command_line.html#configuring-error-messages
    echo "${output}"
    exit 1
  fi

}

main "$@"