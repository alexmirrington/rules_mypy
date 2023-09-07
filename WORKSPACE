workspace(name = "rules_mypy")

# Set up internal deps
load("//:repositories.bzl", "install_internal_deps")

install_internal_deps()

# Set up external deps
load("@rules_python//python:repositories.bzl", "python_register_toolchains", _rules_python_repositories = "py_repositories")

_rules_python_repositories()

# Set up python toolchain
python_register_toolchains(
    name = "python_3_11",
    python_version = "3.11",
)

load("@python_3_11//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "pip",
    python_interpreter_target = interpreter,
    requirements_lock = "//:requirements_lock.txt",
)

load("@pip//:requirements.bzl", install_pip_deps = "install_deps")

install_pip_deps()
