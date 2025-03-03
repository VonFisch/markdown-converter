#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/src/functions.sh"

# Vérifier les dépendances
check_dependencies || { echo "⚠️ Dépendances manquantes, abandon"; exit 1; }

# Trouver tous les fichiers markdown à traiter
find_markdown_files() {
  local search_dir="$1"
  find "$search_dir" -type f -name "*.md" -not -path "*/output/*" -not -path "*/node_modules/*" -not -path "*/\.*"
}

# Si des arguments sont fournis, les utiliser, sinon traiter tous les fichiers markdown
if [[ $# -gt 0 ]]; then
  echo "🚀 Conversion des fichiers spécifiés..."
  "${SCRIPT_DIR}/src/convert.sh" "$@"
else
  echo "🔍 Recherche des fichiers markdown..."
  mapfile -t markdown_files < <(find_markdown_files "$SCRIPT_DIR")
  
  if [[ ${#markdown_files[@]} -eq 0 ]]; then
    echo "⚠️ Aucun fichier markdown trouvé"
    exit 0
  fi
  
  echo "🚀 Conversion de ${#markdown_files[@]} fichiers markdown..."
  for file in "${markdown_files[@]}"; do
    "${SCRIPT_DIR}/src/convert.sh" "$file"
  done
fi

echo "✨ Traitement terminé avec succès"