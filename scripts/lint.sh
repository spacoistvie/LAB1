#!/bin/sh
# lint.sh: проверка синтаксиса диаграмм и управляемости связей.
# - PlantUML: реальный рендер каждого файла через build-docs.py (валидация сервером);
# - CML: структурные проверки балансировки скобок и обязательных узлов ContextMap.
set -u
cd "$(dirname "$0")/.."
fail=0

echo "== PlantUML lint (рендер = проверка синтаксиса) =="
python3 scripts/build-docs.py || fail=1

echo "== Context Mapper DSL lint =="
for f in docs/architecture/*.cml; do
  [ -e "$f" ] || { echo "нет .cml файлов"; fail=1; continue; }
  awk 'BEGIN{d=0} {n=gsub(/{/,"{"); m=gsub(/}/,"}"); d+=n-m} END{if(d!=0){print FILENAME": несбалансированные скобки ("d")"; exit 1}}' "$f" || fail=1
  grep -q "ContextMap" "$f" || { echo "$f: нет узла ContextMap"; fail=1; }
  grep -q "state" "$f" || { echo "$f: нет state (AS_IS/TO_BE)"; fail=1; }
  grep -qE "implements" "$f" || { echo "$f: нет привязки BoundedContext->Subdomain"; fail=1; }
  echo "OK  $f"
done

exit $fail
