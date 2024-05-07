#!/bin/bash

FORMAT="svg"

# Convert all diagrams in the diagrams folder to pngs in the mdbook src/png-diagrams folder
SOURCE_DIR=$(dirname "$0")
TARGET_DIR=$(realpath "$(dirname "$0")/../src/diagrams/")

OS=$(uname)
case "$OS" in
"Darwin") # Mac
    DRAW_IO="/Applications/draw.io.app/Contents/MacOS/draw.io"
    ;;
"Linux") # Linux
    DRAW_IO="drawio"
    ;;
esac

if ! command -v "$DRAW_IO" &>/dev/null; then
    echo "Error: draw.io executable not found. Please install draw.io and make sure it's in your PATH."
    exit 1
fi

pushd "$SOURCE_DIR" >/dev/null
for file in *.drawio; do
    SOURCE="$file"
    TARGET="${TARGET_DIR}/${file%.drawio}.${FORMAT}"
    # Only convert if the source is more recent than the target
    if [[ "$SOURCE" -nt "${TARGET}" ]]; then
        "$DRAW_IO" --export --format ${FORMAT} --scale 2.5 --svg-theme "dark" -o "${TARGET}" "$SOURCE"
    fi
done
popd >/dev/null
