workspace(name = "rules_mypy")

# --------------------
# Set up internal deps
# --------------------
load("//:repositories.bzl", "install_internal_deps")

install_internal_deps()

# --------------------
# Set up external deps
# --------------------
# rules_python
load("@rules_python//python:repositories.bzl", "python_register_toolchains", _rules_python_repositories = "py_repositories")

_rules_python_repositories()

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

load("@com_github_grpc_grpc//bazel:grpc_extra_deps.bzl", "grpc_extra_deps")

grpc_extra_deps()

# ---------------
# Toolchain setup
# ---------------
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
