"""
Virtual environment rules to work alongside rules_python.
"""
PyVenvInfo = provider(
    "TODO(alexmirrington): docs",
    fields = {
        "venv_dir": "Directory containing a python virtual environment.",
    },
)

PY_TOOLCHAIN = "@bazel_tools//tools/python:toolchain_type"

INTERPRETER_FLAGS = ["-B", "-s", "-I"]

def resolve_toolchain(ctx):
    """Resolve the current python3 toolchain given the build context.


    Args:
        ctx: Build context

    Returns:
        struct(
            toolchain: Resolved toolchain runtime,
            files = A depset containing interpreter dependencies,
            python = Resolved toolchain interpreter,
            uses_interpreter_path Whether a direct interpreter path is used to build the interpreter,
            flags = Python flags to use to run against the resolved interpreter,
        )
    """
    toolchain_info = ctx.toolchains[PY_TOOLCHAIN]

    # print(toolchain_info)
    if not toolchain_info.py3_runtime:
        fail("A py3_runtime must be set on the Python toolchain")

    py3_toolchain = toolchain_info.py3_runtime

    interpreter = None
    uses_interpreter_path = False

    if py3_toolchain.interpreter != None:
        files = depset([py3_toolchain.interpreter], transitive = [py3_toolchain.files])
        interpreter = py3_toolchain.interpreter
    else:
        files = py3_toolchain.files
        interpreter = struct(
            path = py3_toolchain.interpreter_path,
            short_path = py3_toolchain.interpreter_path,
        )
        files = depset([])
        uses_interpreter_path = True

    return struct(
        toolchain = py3_toolchain,
        files = files,
        python = interpreter,
        uses_interpreter_path = uses_interpreter_path,
        flags = INTERPRETER_FLAGS,
    )

def _write_deps_file(ctx, out):
    toolchain_depset = ctx.toolchains[PY_TOOLCHAIN].py3_runtime.files or depset()
    toolchain_files = {f: None for f in toolchain_depset.to_list()}

    symlink_files = []
    for dep in ctx.attr.deps:
        # Skip files that are provided by the python toolchain.
        # They don't need to be in the venv.
        if dep in toolchain_files:
            continue
        for file in dep.default_runfiles.files.to_list():
            symlink_files.append(file.path)
    ctx.actions.write(out, "\n".join(symlink_files))

def _py_venv_impl(ctx):
    interpreter = resolve_toolchain(ctx)

    venv_dir = ctx.actions.declare_directory("%s_venv" % ctx.attr.name)
    venv_deps_file = ctx.actions.declare_file("%s_deps.txt" % ctx.attr.name)
    make_venv_exe = ctx.actions.declare_file("%s_venv.sh" % ctx.attr.name)

    _write_deps_file(ctx, venv_deps_file)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = make_venv_exe,
        substitutions = {
            "{DEPS_PATH}": venv_deps_file.path,
            "{PYTHON_INTERPRETER_PATH}": interpreter.python.path,
            "{VENV_LOCATION}": venv_dir.path,
        },
        is_executable = True,
    )

    venv_creation_depset = depset(
        direct = [venv_deps_file],
        transitive = [interpreter.files, depset([file for dep in ctx.attr.deps for file in dep.default_runfiles.files.to_list()])],
    )

    ctx.actions.run(
        executable = make_venv_exe,
        inputs = venv_creation_depset,
        outputs = [venv_dir],
        progress_message = "Creating virtual environment for %{label}",
        mnemonic = "CreateVenv",
    )
    return [
        PyInfo(
            has_py2_only_sources = False,
            has_py3_only_sources = True,
            uses_shared_libraries = False,
            transitive_sources = depset([]),  # TODO(alexmirrington): Populate
        ),
        DefaultInfo(
            files = depset(direct = [venv_dir, make_venv_exe, venv_deps_file], transitive = [interpreter.files]),  # TODO(alexmirrington): Populate
            runfiles = ctx.runfiles(files = interpreter.files.to_list()),
        ),
        PyVenvInfo(
            venv_dir = venv_dir,
        ),
    ]

# A rule that creates a venv with symlinked site packages to point mypy to when type checking
py_venv = rule(
    implementation = _py_venv_impl,
    toolchains = [PY_TOOLCHAIN],
    attrs = {
        "deps": attr.label_list(
            allow_empty = True,
            mandatory = False,
            doc = "TODO(alexmirrington)",
        ),
        "_template": attr.label(
            default = Label("//rules/venv:venv.bash.tpl"),
            allow_single_file = True,
        ),
    },
)
