#!/bin/bash

FORMAT="svg"

# Convert all diagrams in the diagrams folder to pngs in the mdbook src/png-diagrams folder
SOURCE_DIR=$(dirname "$0")
TARGET_DIR=$(realpath "$(dirname "$0")/")

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
for page in $(seq 0 3); do
    SOURCE="diagrams.drawio"
    TARGET="${TARGET_DIR}/${SOURCE%.drawio}_${page}.${FORMAT}"
    # Only convert if the source is more recent than the target
    if [[ "$SOURCE" -nt "${TARGET}" ]]; then
        "$DRAW_IO" --export --page-index ${page} --format ${FORMAT} --scale 2.5 -o "${TARGET}" "${SOURCE}"
        if [ "$FORMAT" = "svg" ]; then
            # add styling for dark mode (https://github.com/jgraph/drawio-github/blob/master/DARK-MODE.md)
            sed -i -e "s$<defs/>$<defs><style type=\"text/css\"> @media (prefers-color-scheme: dark) { svg { filter: invert(93%) hue-rotate(180deg); background-color: transparent !important; } image { filter: invert(100%) hue-rotate(180deg) saturate(1.25); } } </style></defs>$" "${TARGET}"
        fi
    fi
done
popd >/dev/null
