#!/bin/bash
find . -type f -name "*.ts" -print0 | while read -r -d '' file; do lconvert -if ts -i "$file" -of qm -o "${file%%.ts}.qm"; done
