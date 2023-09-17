#!/usr/bin/env bash
set -euo pipefail

if output=$(git status --porcelain) && [ -z "$output" ]; then
    exit 0
else
    echo $output
    echo "Working directory is dirty"
    exit 1
fi
