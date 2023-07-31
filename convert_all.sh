#!/bin/bash
DRAW_IO="/Applications/draw.io.app/Contents/MacOS/draw.io"

for file in diagrams/*.drawio; do
    $DRAW_IO -x -f png --scale 2.5 -o "${file%.drawio}.png" $file
done
