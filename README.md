# rules_mypy

## Overview

`rules_mypy` aims to make the process of adding [`mypy`](https://github.com/python/mypy)
type-checking to your existing `rules_python` targets as seamless as possible,
through the use of Bazel [aspects](https://bazel.build/extending/aspects).

With this approach, we get all the benefits of `rules_python` for Python builds
and packaging, as well as `rules_python_gazelle_plugin` for build file generation.

## Usage

This repository is under active development, but is currently pre-alpha,
since support as an external bazel repository has not yet been added.
Contributions are welcome!

To use the rules in this repository at the current moment, you'll have to copy
the rules over to your monorepo and tweak your setup to integrate it correctly.

Note that the current implementation is roughly equivalent to `mypy --no-silence-site-packages $src_file`
in terms of the errors it picks up, sincesymlinked stubs are not actually under a site-packages directory.

TODO(alexmirrington): Ignore stub files either in config or automatically via CLI

## Features and Roadmap

- [x] Integration with `rules_python` and `gazelle` for basic `mypy` type-checking via aspects
- [x] Integration with `rules_proto_grpc` for protobuf and gRPC type stubs
- [ ] Direct integration with `rules_python` toolchains
- [ ] Support as an external repo
- [ ] `bzlmod` support

## Developing

- Install [Bazelisk](https://github.com/bazelbuild/bazelisk) to easily get up and running with the right version of Bazel for the project.
