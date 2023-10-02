# Copyright 2021 cedar.ai. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import itertools
import json
import os
import pathlib
import subprocess
import sys
import textwrap
import venv
from enum import Enum
from pathlib import Path
from typing import Dict, List, NamedTuple

import importlib_metadata


class EnvPathType(Enum):
    SITE_PACKAGES = 1
    DATA = 2


class EnvFile(NamedTuple):
    path: pathlib.Path
    env_path: pathlib.Path
    type_: EnvPathType = EnvPathType.SITE_PACKAGES


def path_starts_with(path: pathlib.Path, prefix: pathlib.Path) -> bool:
    return path.parts[: len(prefix.parts)] == prefix.parts


def get_env_path(
    workspace: str, path: pathlib.Path, imports: List[pathlib.Path]
) -> EnvFile:
    # Import prefixes start with the workspace name, which might be the local workspace.
    # We first normalize the given path so that it starts with its workspace name.
    if path.parts[0] == "..":
        wspath = path.relative_to("..")
        is_external = True
    else:
        wspath = pathlib.Path(workspace) / path
        is_external = False

    for imp in imports:
        if path_starts_with(wspath, imp):
            return EnvFile(path, wspath.relative_to(imp))

        imp_data = imp.parent / "data"
        if path_starts_with(wspath, imp_data):
            return EnvFile(path, wspath.relative_to(imp_data), EnvPathType.DATA)

    if not is_external:
        # If the input wasn't an external path and it didn't match any import prefixes,
        # just return it as given.
        return EnvFile(path, path)

    # External file that didn't match imports. Include but warn.
    # We include it as relative to its workspace directory, so strip the first component
    # off wspath.
    include_path = wspath.relative_to(wspath.parts[0])
    print(f"Warning: [{path}] didn't match any imports. Including as [{include_path}]")

    return EnvFile(path, include_path)


def is_external(file_: pathlib.Path) -> bool:
    return file_.parts[0] == ".."


def find_site_packages(env_path: pathlib.Path) -> pathlib.Path:
    if sys.platform == "win32":
        lib_path = env_path / "Lib"

        site_packages_path = lib_path / "site-packages"
        if site_packages_path.exists():
            return site_packages_path

    else:
        lib_path = env_path / "lib"

        # We should find one "pythonX.X" directory in here.
        for child in lib_path.iterdir():
            if child.name.startswith("python"):
                site_packages_path = child / "site-packages"
                if site_packages_path.exists():
                    return site_packages_path

    raise Exception("Unable to find site-packages path in venv")


def get_files(build_env_input: Dict) -> List[EnvFile]:
    files = []

    always_link = build_env_input.get("always_link", False)
    imports = [pathlib.Path(imp) for imp in build_env_input["imports"]]
    workspace = build_env_input["workspace"]
    for depfile in build_env_input["files"]:
        # Bucket files into external and workspace groups.
        # Only generated workspace files are kept.
        type_ = depfile["t"]
        input_path = pathlib.Path(depfile["p"])

        # If this is a directory, expand to each recursive child.
        if input_path.is_dir():
            paths = input_path.glob("**/*")
            paths = [p for p in paths if not p.is_dir()]
        else:
            paths = [input_path]

        for path in paths:
            env_file = get_env_path(workspace, path, imports)
            if env_file.env_path != path or always_link:
                files.append(env_file)

    return files


def install_site_file(
    site_packages_path: pathlib.Path, file: EnvFile, should_link: bool
) -> None:
    site_path = site_packages_path / file.env_path
    if not site_path.exists():
        site_path.parent.mkdir(parents=True, exist_ok=True)
        if should_link:
            site_path.symlink_to(file.path.resolve())


def install_files(
    env_path: pathlib.Path, files: List[EnvFile], should_link: bool
) -> None:
    site_packages_path = find_site_packages(env_path)
    for file in files:
        install_site_file(site_packages_path, file, should_link)


def main():
    if "BUILD_ENV_INPUT" not in os.environ:
        raise Exception("Missing BUILD_ENV_INPUT environment variable")
    if "VENV_LOCATION" not in os.environ:
        raise Exception("Missing VENV_LOCATION environment variable")

    # Only symlink to runfiles on bazel run
    should_link = os.environ.get("LINK_RUNFILES") is not None

    execroot = os.getcwd()
    with open(Path(execroot) / os.environ["BUILD_ENV_INPUT"]) as f:
        build_env_input = json.load(f)

    files = get_files(build_env_input)

    # Hack: fully resolve the current interpreter's known path to get venv to link to the
    # files in their actual location
    sys._base_executable = str(pathlib.Path(sys._base_executable).resolve())
    env_path = Path(execroot) / os.environ.get("VENV_LOCATION")

    builder = venv.EnvBuilder(clear=True, symlinks=True, with_pip=True)
    builder.create(str(env_path))

    install_files(env_path, files, should_link)


if __name__ == "__main__":
    main()
