"""
MyPy rules to work alongside rules_python
Initial source taken from here: https://github.com/bazel-contrib/bazel-mypy-integration
"""

load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:shell.bzl", "shell")
load("//rules/venv:venv.bzl", "PyVenvInfo")

MyPyAspectInfo = provider(
    "TODO: documentation",
    fields = {
        "exe": "Used to pass the rule implementation built exe back to calling aspect.",
        "out": "Used to pass the dummy output file back to calling aspect.",
    },
)

# Switch to True only during debugging and development.
# All releases should have this as False.
BASH_DEBUG = False
MYPY_DEBUG = False

VALID_EXTENSIONS = ["py", "pyi"]

DEFAULT_ATTRS = {
    "_mypy_config": attr.label(
        default = Label("//config:mypy_config"),
        allow_single_file = True,
    ),
    "_template": attr.label(
        default = Label("//rules/mypy:mypy.bash.tpl"),
        allow_single_file = True,
    ),
    "_venv": attr.label(
        default = Label("//rules/mypy:venv"),
        executable = False,
    ),
}

def _sources_to_cache_map_triples(srcs, is_aspect):
    triples_as_flat_list = []
    for f in srcs:
        if is_aspect:
            f_path = f.path
        else:
            # "The path of this file relative to its root. This excludes the aforementioned root, i.e. configuration-specific fragments of the path.
            # This is also the path under which the file is mapped if it's in the runfiles of a binary."
            # - https://docs.bazel.build/versions/master/skylark/lib/File.html
            f_path = f.short_path
        triples_as_flat_list.extend([
            shell.quote(f_path),
            shell.quote("{}.meta.json".format(f_path)),
            shell.quote("{}.data.json".format(f_path)),
        ])
    return triples_as_flat_list

def _is_external_dep(dep):
    return dep.label.workspace_root.startswith("external/")

def _is_external_src(src_file):
    return src_file.path.startswith("external/")

def _extract_srcs(srcs):
    direct_src_files = {}
    for src in srcs:
        for f in src.files.to_list():
            direct_src_files[f.path] = f
    return direct_src_files.values()

def _extract_generated_stubs(deps):
    file_map = {}
    for dep in deps:
        for f in dep.default_runfiles.files.to_list():
            if f.extension == "pyi":
                file_map[f.path] = f
    return file_map.values()

def _extract_transitive_deps(deps):
    transitive_deps = []
    for dep in deps:
        if PyInfo in dep and not _is_external_dep(dep):
            transitive_deps.append(dep[PyInfo].transitive_sources)

            # Extract any generated stub files from default runfiles for python deps,
            # as they are not included in PyInfo transitive sources
            generated_stub_deps = _extract_generated_stubs(deps)
            transitive_deps.append(depset(direct = generated_stub_deps))
    return transitive_deps

def _extract_imports(imports, label):
    # NOTE: Bazel's implementation of this for py_binary, py_test is at
    # src/main/java/com/google/devtools/build/lib/bazel/rules/python/BazelPythonSemantics.java
    mypypath_parts = []
    for import_ in imports:
        if import_.startswith("/"):
            # buildifier: disable=print
            print("ignoring invalid absolute path '{}'".format(import_))
        elif import_ in ["", "."]:
            mypypath_parts.append(label.package)
        else:
            mypypath_parts.append("{}/{}".format(label.package, import_))
    return mypypath_parts

def _prioritize_stubs(files):
    """Include all .py and .pyi files, in the given file list, but prioritizing .pyi files.

    MyPy will error if we say to run over the same module with both its .py and .pyi files, so we
    must be careful to only use the .pyi stub if it exists.
    """
    filtered_files = {}
    for f in files:
        if f.extension == "pyi":
            # Remove the equivalent .py source if it was already registered
            py_source_path = f.path[:-1]
            if filtered_files.get(py_source_path) != None:
                filtered_files.pop(py_source_path)
            filtered_files[f.path] = f
        elif f.extension == "py":
            # Only add a .py file if an equivalent .pyi source is not already registered
            pyi_source_path = f.path + "i"
            if filtered_files.get(pyi_source_path) == None:
                filtered_files[f.path] = f
    return filtered_files.values()

def _mypy_rule_impl(ctx, is_aspect = False):
    base_rule = ctx
    if is_aspect:
        base_rule = ctx.rule

    mypy_config_file = ctx.file._mypy_config

    mypypath_parts = []
    direct_src_files = []

    transitive_srcs_depsets = []
    if hasattr(base_rule.attr, "srcs"):
        direct_src_files = _extract_srcs(base_rule.attr.srcs)

    if hasattr(base_rule.attr, "deps"):
        transitive_srcs_depsets = _extract_transitive_deps(base_rule.attr.deps)

    if hasattr(base_rule.attr, "imports"):
        mypypath_parts += _extract_imports(base_rule.attr.imports, ctx.label)

    final_srcs_depset = depset(transitive = transitive_srcs_depsets +
                                            [depset(direct = direct_src_files)])
    src_files = [f for f in final_srcs_depset.to_list() if not _is_external_src(f)]
    src_files = _prioritize_stubs(src_files)

    if not src_files:
        return None

    mypypath = ":".join(mypypath_parts)

    # Ideally, a file should be passed into this rule. If this is an executable
    # rule, then we default to the implicit executable file, otherwise we create
    # a stub.
    if not is_aspect:
        if hasattr(ctx, "outputs"):
            exe = ctx.outputs.executable
        else:
            exe = ctx.actions.declare_file(
                "%s_mypy_exe" % base_rule.attr.name,
            )
        out = None
    else:
        out = ctx.actions.declare_file("%s_dummy_out" % ctx.rule.attr.name)
        exe = ctx.actions.declare_file(
            "%s_mypy_exe" % ctx.rule.attr.name,
        )

    # Compose a list of the files needed for use. Note that aspect rules can use
    # the project version of mypy however, other rules should fall back on their
    # relative runfiles.
    runfiles = ctx.runfiles(
        files = src_files + [ctx.attr._venv[PyVenvInfo].venv_dir] + [mypy_config_file],
    )

    src_root_paths = sets.to_list(
        sets.make([f.root.path for f in src_files]),
    )

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = exe,
        substitutions = {
            "{CACHE_MAP_TRIPLES}": " ".join(_sources_to_cache_map_triples(src_files, is_aspect)),
            "{MYPYPATH_PATH}": mypypath if mypypath else "",
            "{MYPY_INI_PATH}": mypy_config_file.path,
            "{OUTPUT}": out.path if out else "",
            "{PACKAGE_ROOTS}": " ".join([
                "--package-root " + shell.quote(path or ".")
                for path in src_root_paths
            ]),
            "{PY_INTERPRETER}": "%s/bin/python3" % ctx.attr._venv[PyVenvInfo].venv_dir.path,
            "{SRCS}": " ".join([
                shell.quote(f.path) if is_aspect else shell.quote(f.short_path)
                for f in src_files
            ]),
            "{VERBOSE_BASH}": "set -x" if BASH_DEBUG else "",
            "{VERBOSE_OPT}": "--verbose" if MYPY_DEBUG else "",
        },
        is_executable = True,
    )

    if is_aspect:
        return [
            DefaultInfo(executable = exe, runfiles = runfiles),
            MyPyAspectInfo(exe = exe, out = out),
        ]
    return DefaultInfo(executable = exe, runfiles = runfiles)

def _mypy_aspect_impl(_, ctx):
    if (ctx.rule.kind not in ["py_binary", "py_library", "py_test", "mypy_test"] or
        ctx.label.workspace_root.startswith("external")):
        return []

    providers = _mypy_rule_impl(
        ctx,
        is_aspect = True,
    )
    if not providers:
        return []

    info = providers[0]
    aspect_info = providers[1]

    ctx.actions.run(
        outputs = [aspect_info.out],
        inputs = info.default_runfiles.files,
        tools = [],
        executable = aspect_info.exe,
        mnemonic = "MyPy",
        progress_message = "Type-checking %s" % ctx.label,
        use_default_shell_env = True,
    )
    return [
        OutputGroupInfo(
            mypy = depset([aspect_info.out]),
        ),
    ]

def _mypy_test_impl(ctx):
    info = _mypy_rule_impl(ctx, is_aspect = False)
    if not info:
        fail("A list of python deps are required for mypy_test")
    return info

mypy_aspect = aspect(
    implementation = _mypy_aspect_impl,
    attr_aspects = [],
    attrs = DEFAULT_ATTRS,
)

mypy_test = rule(
    implementation = _mypy_test_impl,
    test = True,
    attrs = dict(DEFAULT_ATTRS.items() + [("deps", attr.label_list(aspects = [mypy_aspect]))]),
)
