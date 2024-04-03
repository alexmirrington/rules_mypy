.PHONY: check
check:
	./tools/trunk check

.PHONY: fix
fix:
	./tools/trunk fmt

.PHONY: repin
repin:
	bazel run //:requirements.update
	bazel run //:gazelle_python_manifest.update

.PHONY: venv
venv:
	bazel run //:venv

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
