# Единая точка сборки ЛР1 (Architecture-as-Code)
# usage: make build-docs | make lint | make clean | make help
# Работает в любом POSIX-окружении: Linux, macOS, WSL, Git Bash.
# Единственная внешняя зависимость — Python 3 (нужен для build-docs.py).

# Кроссплатформенный поиск интерпретатора: python3 или python.
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo python3)

SOURCES := $(wildcard docs/architecture/*.puml docs/architecture/*.cml)

.PHONY: build-docs lint clean check help

build-docs: ## Рендер всех .puml в evidence/ (PNG + SVG через PlantUML-сервер)
	@$(PYTHON) scripts/build-docs.py

lint: ## Проверка синтаксиса PlantUML и CML (штатный линтер)
	@sh scripts/lint.sh

clean: ## Удалить сгенерированные артефакты
	$(RM) evidence/*.png evidence/*.svg

check: lint ## Собрать и провалидировать одной целью

help: ## Список целей
	@grep -hE '^# usage|^[a-z-]+:' Makefile | sed 's/ ##/ —/'
