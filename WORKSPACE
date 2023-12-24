workspace(name = "rules_mypy")

# --------------------
# Set up internal deps
# --------------------
load("//:repositories.bzl", "rules_mypy_internal_repos", "rules_mypy_repos")

rules_mypy_repos()

rules_mypy_internal_repos()

# --------------------
# Set up external deps
# --------------------
# rules_python
load("@rules_python//python:repositories.bzl", "python_register_toolchains", _rules_python_repositories = "py_repositories")

_rules_python_repositories()

# gazelle
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.6")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

# rules_python_gazelle_plugin
load("@rules_python_gazelle_plugin//:deps.bzl", _py_gazelle_deps = "gazelle_deps")

_py_gazelle_deps()

# rules_proto_grpc base
load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_repos", "rules_proto_grpc_toolchains")

rules_proto_grpc_toolchains()

rules_proto_grpc_repos()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()

# rules_proto_grpc buf
load("@rules_proto_grpc//buf:repositories.bzl", rules_proto_grpc_buf_repos = "buf_repos")

rules_proto_grpc_buf_repos()

# rules_proto_grpc python
load("@rules_proto_grpc//python:repositories.bzl", rules_proto_grpc_python_repos = "python_repos")

rules_proto_grpc_python_repos()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()

# ---------------
# Toolchain setup
# ---------------
# Set up python toolchain
python_register_toolchains(
    name = "python_3_11",
    python_version = "3.11",
)

load("@python_3_11//:defs.bzl", "interpreter")
load("//:pip.bzl", "rules_mypy_py_deps")

rules_mypy_py_deps(
    python_interpreter_target = interpreter,
    requirements_lock = "//:requirements_lock.txt",
)

# TODO(alexmirrington): Move into above macro
load("@rules_mypy_pip_deps//:requirements.bzl", install_pip_deps = "install_deps")

install_pip_deps()
