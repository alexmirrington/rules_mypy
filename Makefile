.PHONY: check
check:
	./tools/trunk check

.PHONY: fix
fix:
	./tools/trunk fmt

.PHONY: repin
repin:
	bazel run //:requirements.update
