"py_stubs rule"
MyPyStubsInfo = provider(
    "TODO: docs",
    fields = {
        "srcs": ".pyi stub files",
    },
)

def _extract_stub_deps(ctx, deps):
    """Generate a stubs folder from rules_python repository deps"""
    symlinks = []
    for dep in deps:
        for file in dep.default_runfiles.files.to_list():
            if file.extension == "pyi":
                parts = ["stubs"]
                has_site_packages = False
                is_stubs_only = False
                for part in file.dirname.split("/"):
                    if part == "site-packages":
                        has_site_packages = True
                        continue
                    if part.endswith("-stubs"):
                        is_stubs_only = True

                        # Append the part with the `-stubs` suffix removed so that the
                        # stubs package has the correct imports once resolved my mypy
                        parts.append(part.removesuffix("-stubs"))
                        continue
                    if has_site_packages and is_stubs_only:
                        parts.append(part)
                if has_site_packages and is_stubs_only:
                    parts.append(file.basename)
                    new_file = ctx.actions.declare_file("/".join(parts))
                    ctx.actions.symlink(output = new_file, target_file = file)
                    symlinks.append(new_file)
    return symlinks

def _py_stubs_impl(ctx):
    pyi_srcs = []
    for target in ctx.attr.srcs:
        pyi_srcs.extend(target.files.to_list())

    symlinks = _extract_stub_deps(ctx, ctx.attr.deps)

    # TODO(alexmirrington): transitive depset for symlinks?
    transitive_srcs = depset(direct = pyi_srcs + symlinks)
    return [
        MyPyStubsInfo(
            srcs = ctx.attr.srcs,
        ),
        PyInfo(
            # TODO(Jonathon): Stub files only for Py3 right?
            has_py2_only_sources = False,
            has_py3_only_sources = True,
            uses_shared_libraries = False,
            transitive_sources = transitive_srcs,
        ),
        DefaultInfo(
            files = depset(symlinks),
        ),
    ]

py_stubs = rule(
    implementation = _py_stubs_impl,
    attrs = {
        "deps": attr.label_list(
            allow_empty = True,
            mandatory = False,
            doc = "TODO(alexmirrington)",
        ),
        "srcs": attr.label_list(
            allow_empty = True,
            mandatory = False,
            doc = "TODO(alexmirrington)",
            allow_files = [".pyi"],
        ),
    },
)
