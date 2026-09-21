#!/usr/bin/env python3
"""build-docs: рендер PlantUML-диаграмм через PlantUML-сервер в evidence/.

Единая точка сборки документации (`make build-docs`).
Каждый .puml из docs/architecture/ валидируется и рендерится в PNG и SVG.
"""
import sys
import zlib
import base64
import pathlib
import urllib.request

GITHUB = "https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master"
WHITELIST = (GITHUB,)
ROOT = pathlib.Path(__file__).resolve().parents[1]
PUML_DIR = ROOT / "docs" / "architecture"
OUT_DIR = ROOT / "evidence"


PLANTUML_ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"
BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def encode(text: str) -> str:
    data = zlib.compress(text.encode("utf-8"), 9)[2:-4]
    b64 = base64.b64encode(data).decode()
    return b64.translate(str.maketrans(BASE64_ALPHABET, PLANTUML_ALPHABET))


def render(name: str, fmt: str) -> bytes:
    src = (PUML_DIR / name).read_text(encoding="utf-8")
    for line in src.splitlines():
        if line.startswith("!include"):
            url = line.split(maxsplit=1)[1].strip()
            assert url.startswith(WHITELIST), f"нештатный include: {url}"
    url = f"https://www.plantuml.com/plantuml/{fmt}/{encode(src)}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (build-docs)"})
    with urllib.request.urlopen(req) as resp:
        assert resp.status == 200, resp.status
        png = resp.read()
    assert b"Usage Error" not in png[:2000], f"ошибка PlantUML в {name}"
    return png


def main() -> int:
    pumls = sorted(p.name for p in PUML_DIR.glob("*.puml"))
    if not pumls:
        print("нет *.puml файлов", file=sys.stderr)
        return 1
    OUT_DIR.mkdir(exist_ok=True)
    failures = []
    for name in pumls:
        stem = pathlib.Path(name).stem
        for fmt in ("png", "svg"):
            try:
                blob = render(name, fmt)
            except Exception as exc:
                failures.append(name)
                print(f"FAIL {fmt.upper()} {name}: {exc}", file=sys.stderr)
                break
            out = OUT_DIR / f"{stem}.{fmt}"
            out.write_bytes(blob)
            print(f"OK  {out.relative_to(ROOT)} ({len(blob)} байт)")
    if failures:
        print("FAIL:", ", ".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
