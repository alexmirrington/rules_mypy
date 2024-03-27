.PHONY: check
check:
	./tools/trunk check

.PHONY: fix
fix:
	./tools/trunk fmt

.PHONY: repin
repin:
	bazel run //:requirements_3_11.update
	bazel run //:requirements_3_10.update
	bazel run //:gazelle_python_manifest.update

.PHONY: generate
generate:
	bazel run //:gazelle

.PHONY: build
build: generate
	bazel build ...

.PHONY: test
test:
	bazel test ...
	./tests/shell/test_mypy.sh

.PHONY: build-mypy
build-mypy:
	bazel build --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy ...

.PHONY: run
run:
	bazel run //tests:print_python_version

.PHONY: run_3_10
run_3_10:
	bazel run //tests:print_python_version --@rules_python//python/config_settings:python_version="3.10"

.PHONY: run_3_11
run_3_11:
	bazel run //tests:print_python_version --@rules_python//python/config_settings:python_version="3.11"
