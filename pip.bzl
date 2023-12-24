"""Macros for setting up python dependencies needed by binaries in this repo."""

load("@rules_python//python:pip.bzl", "pip_parse")

def rules_mypy_py_deps(requirements_lock, python_interpreter_target):
    """Install packages needed by binaries in this repo.

    Args:
        requirements_lock: A requirements lock file containing at least the mypy version to use,
            as well as any additional packages that need to be available when type checking.
            Generally, passing through the same requirements lock file used in your regular toolchain
            will suffice.
        python_interpreter_target: The python interpreter to use for binaries in this repo.
    """
    external_repo_name = "rules_mypy_pip_deps"
    excludes = native.existing_rules().keys()
    if external_repo_name not in excludes:
        pip_parse(
            name = external_repo_name,
            python_interpreter_target = python_interpreter_target,
            requirements_lock = requirements_lock,
        )

        # install_pip_deps()
