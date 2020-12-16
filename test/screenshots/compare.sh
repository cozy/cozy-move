#!/usr/bin/env bash
set -eu

WORK_DIR="$(dirname "$0")"
BIN="$(realpath "$WORK_DIR/../../assets/node_modules/.bin/pixelmatch")"

for img in "$WORK_DIR"/actual/*.png
do
	echo "Comparing $img..."
	"$BIN" "$img" "${img/actual/expected}"
done
