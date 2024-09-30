"""Dependencies required by the project."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_mypy_repos():
    """Install all rule dependencies required by the project."""
    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "4912ced70dc1a2a8e4b86cec233b192ca053e82bc72d877b98e126156e8f228d",
        strip_prefix = "rules_python-0.32.2",
        url = "https://github.com/bazelbuild/rules_python/releases/download/0.32.2/rules_python-0.32.2.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

def rules_mypy_internal_repos():
    """Install all bazel dependencies required to build and develop the project."""
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "d93ef02f1e72c82d8bb3d5169519b36167b33cf68c252525e3b9d3d5dd143de7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.49.0/rules_go-v0.49.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.49.0/rules_go-v0.49.0.zip",
        ],
    )

    http_archive(
        name = "bazel_gazelle",
        sha256 = "8ad77552825b078a10ad960bec6ef77d2ff8ec70faef2fd038db713f410f5d87",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.38.0/bazel-gazelle-v0.38.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.38.0/bazel-gazelle-v0.38.0.tar.gz",
        ],
    )

    http_archive(
        name = "rules_python_gazelle_plugin",
        sha256 = "4912ced70dc1a2a8e4b86cec233b192ca053e82bc72d877b98e126156e8f228d",
        strip_prefix = "rules_python-0.32.2/gazelle",
        url = "https://github.com/bazelbuild/rules_python/releases/download/0.32.2/rules_python-0.32.2.tar.gz",
    )

    http_archive(
        name = "rules_proto_grpc",
        sha256 = "38a51a3183dffa5323bbf07b7d5473fa1f06707cf59607888f36cb735ab39cd8",
        strip_prefix = "rules_proto_grpc-5.0.1",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/releases/download/5.0.1/rules_proto_grpc-5.0.1.tar.gz"],
    )
