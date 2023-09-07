.PHONY: check
check:
	./tools/trunk check

.PHONY: fix
fix:
	./tools/trunk fmt

.PHONY: repin
repin:
	bazel run //:requirements.update

.PHONY: build
build:
	bazel build ...

.PHONY: build-mypy
build-mypy:
	bazel build --aspects //rules/mypy:mypy.bzl%mypy_aspect --output_groups=mypy ...
