#!/bin/bash

# Convert all diagrams in the diagrams folder to pngs in the mdbook src/png-diagrams folder
SOURCE_DIR=$(dirname "$0")
TARGET_DIR=$(realpath "$(dirname "$0")/../src/png-diagrams/")

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
    "$DRAW_IO" -x -f png --scale 2.5 -o "${TARGET_DIR}/${file%.drawio}.png" "$file"
done
popd >/dev/null
