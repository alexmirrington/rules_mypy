import sys

try:
    from mypy.main import main
except ImportError:
    print(
        "Could not import mypy. Did you provide the library via "
        + "'--@com_alexmirrington_rules_mypy//:mypy=...'?"
    )
    sys.exit(1)


if __name__ == "__main__":
    main(stdout=sys.stdout, stderr=sys.stderr)
