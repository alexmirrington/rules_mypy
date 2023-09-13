"""Fetch dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def install_internal_deps():
    http_archive(
        name = "rules_python",
        sha256 = "5868e73107a8e85d8f323806e60cad7283f34b32163ea6ff1020cf27abef6036",
        strip_prefix = "rules_python-0.25.0",
        url = "https://github.com/bazelbuild/rules_python/releases/download/0.25.0/rules_python-0.25.0.tar.gz",
    )

    http_archive(
        name = "rules_proto_grpc",
        sha256 = "9ba7299c5eb6ec45b6b9a0ceb9916d0ab96789ac8218269322f0124c0c0d24e2",
        strip_prefix = "rules_proto_grpc-4.5.0",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/releases/download/4.5.0/rules_proto_grpc-4.5.0.tar.gz"],
    )
