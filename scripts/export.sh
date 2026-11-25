#!/usr/bin/env bash
# 모델 하나를 STL, 형상 3MF(.mesh.3mf), 미리보기 PNG로 내보낸다.
# 사용법: scripts/export.sh <모델 이름> [-D 변수=값 ...]
# 예:     scripts/export.sh skadis-hair-dryer-holder -D hook_depth=5.2
set -euo pipefail

OPENSCAD="${OPENSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -lt 1 ]; then
  echo "사용법: $0 <모델 이름> [-D 변수=값 ...]" >&2
  echo "모델 목록:" >&2
  ls "$ROOT/models" >&2
  exit 1
fi

NAME="$1"; shift
SRC="$ROOT/models/$NAME/$NAME.scad"
OUT="$ROOT/models/$NAME/out"

[ -x "$OPENSCAD" ] || { echo "OpenSCAD를 찾지 못했습니다: $OPENSCAD" >&2; exit 1; }
[ -f "$SRC" ] || { echo "모델 파일이 없습니다: $SRC" >&2; exit 1; }
mkdir -p "$OUT"

# --export-format은 같은 실행의 모든 -o에 적용되므로 STL과 3MF를 따로 실행한다
"$OPENSCAD" --backend Manifold --export-format binstl -o "$OUT/$NAME.stl" "$@" "$SRC"
# <이름>.3mf는 Bambu Studio 프로젝트를 저장하는 자리라서 형상만 담은 3MF는 다른 이름으로 낸다
"$OPENSCAD" --backend Manifold -o "$OUT/$NAME.mesh.3mf" "$@" "$SRC"

"$OPENSCAD" --backend Manifold --render --autocenter --viewall \
  --imgsize 1200,900 -o "$OUT/$NAME.png" "$@" "$SRC" \
  || echo "미리보기 PNG는 만들지 못했습니다 (STL, 3MF는 정상)" >&2

ls -l "$OUT"
