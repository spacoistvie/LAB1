# Единая точка сборки ЛР1 (Architecture-as-Code)
# usage: make build-docs | make lint | make clean
SOURCES := $(wildcard docs/architecture/*.puml docs/architecture/*.cml)

.PHONY: build-docs lint clean help

build-docs: ## Рендер всех .puml в evidence/ (PNG + SVG)
	python3 scripts/build-docs.py

lint: ## Проверка синтаксиса PlantUML и CML
	./scripts/lint.sh

clean: ## Удалить сгенерированные артефакты
	rm -f evidence/*.png evidence/*.svg

help: ## Список целей
	@grep -hE '^# usage|^[a-z-]+:' Makefile | sed 's/ ##/ —/'
