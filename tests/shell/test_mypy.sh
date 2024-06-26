#!/usr/bin/env bash
#
# Integration tests that execute, with `bazel build` and `bazel test`,
# build rules defined in the repo's /tests directory.

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=/dev/null
source "${dir}"/test_runner.sh
# shellcheck source=/dev/null
source "${dir}"/test_helper.sh

runner=$(get_test_runner "${1:-local}")

# Obviously doesn't test the integration's functionality, just the basics of repo's Bazel
# workspace setup, a prerequisite to testing the integration's functionality.
test_success_running_bazel_version() {
  action_should_succeed version
}

test_success_pandas_passes() {
  action_should_succeed build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests:pandas_passes
}

test_success_google_passes() {
  action_should_succeed build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests:google_passes
}

test_success_proto_passes() {
  action_should_succeed build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests:proto_passes
}

test_failure_test_transitive_main_passes() {
  action_should_succeed build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests/test_transitive:main_passes
}

test_failure_pandas_fails() {
  action_should_fail build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests:pandas_fails
}

test_failure_proto_fails() {
  action_should_fail build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests:proto_fails
}

test_failure_test_transitive_main_fails() {
  action_should_fail build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests/test_transitive:main_fails
}

test_failure_test_transitive_square_fails() {
  action_should_fail build --verbose_failures --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy //tests/test_transitive/square
}

# TODO(alexmirrington): Check output of failures against expected output
main() {
  $runner test_success_running_bazel_version
  $runner test_success_pandas_passes
  $runner test_success_google_passes
  $runner test_success_proto_passes
  $runner test_failure_test_transitive_main_passes

  $runner test_failure_pandas_fails
  $runner test_failure_proto_fails
  $runner test_failure_test_transitive_main_fails
  $runner test_failure_test_transitive_square_fails
}

main "$@"