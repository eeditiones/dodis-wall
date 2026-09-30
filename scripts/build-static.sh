#!/bin/sh
# Pregenerate static pb-view content with opm and upload it to the app's "cached" collection.
# Requires opm and xst; run from the app root. Pass --no-upload to only generate.
set -e
cd "$(dirname "$0")/.."

opm chunk data/documents --format pb-view --force

if [ "$1" != "--no-upload" ]; then
    xst upload chunks/ /db/apps/wall-came-down/cached/ -v
fi
