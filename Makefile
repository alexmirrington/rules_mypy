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

.PHONY: generate
generate: repin
	bazel run //:gazelle

.PHONY: build
build: generate
	bazel build ...

.PHONY: test
test:
	bazel test ...

.PHONY: build-mypy
build-mypy:
	bazel build --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy ...
