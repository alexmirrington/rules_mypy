# rules_mypy

## Overview

`rules_mypy` aims to make the process of adding [`mypy`](https://github.com/python/mypy)
type-checking to your existing `rules_python` targets as seamless as possible,
through the use of Bazel [aspects](https://bazel.build/extending/aspects).

With this approach, we get all the benefits of `rules_python` for Python builds
and packaging, as well as `rules_python_gazelle_plugin` for build file generation.

## Usage

Refer to the [latest release](https://github.com/alexmirrington/rules_mypy/releases)
for information on how to integrate these rules into your monorepo.

Note that the current implementation is roughly equivalent to `mypy --no-silence-site-packages $src_file`
in terms of the errors it picks up, since symlinked stubs are not actually under a `site-packages` directory
and are instead treated as source files by the `mypy` binary in this repository.
To get around this, we ignore all errors from these packages explicitly in `.mypy.ini`.

## Features and Roadmap

- [x] Integration with `rules_python` and `gazelle` for basic `mypy` type-checking via aspects
- [x] Integration with `rules_proto_grpc` for protobuf and gRPC type stubs
- [x] Support as an external repo
- [ ] `bzlmod` support

## Developing

- Install [Bazelisk](https://github.com/bazelbuild/bazelisk) to easily get up and running with the right version of Bazel for the project.

## Acknowledgements

The source code in this repo was initially inspired by [bazel-mypy-integration](https://github.com/bazel-contrib/bazel-mypy-integration),
with added PEP-561 and protobuf/gRPC type stub support.
