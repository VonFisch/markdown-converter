.PHONY: all install clean build help

SCRIPT_DIR := $(shell pwd)

# Cibles par défaut
all: help

help:
	@echo "Utilisation du Makefile :"
	@echo "  make install    - Installe les dépendances"
	@echo "  make build      - Compile tous les documents markdown"
	@echo "  make clean      - Nettoie les fichiers générés"
	@echo "  make help       - Affiche cette aide"

install:
	@bash -c 'source $(SCRIPT_DIR)/src/functions.sh && install_all_dependencies'

build:
	@./build.sh

clean:
	@echo "🧹 Nettoyage des fichiers générés..."
	@rm -rf output/
	@echo "✅ Nettoyage terminé"