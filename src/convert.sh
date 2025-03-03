#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Créer les dossiers nécessaires
mkdir -p "$OUTPUT_DIR/pdf" "$OUTPUT_DIR/html"

# Fonction pour convertir en HTML
convert_to_html() {
  local input_file="$1"
  local output_dir="$2"
  local filename=$(basename "$input_file" .md)
  
  echo "  • Conversion en HTML..."
  
  # Conversion directe en HTML
  pandoc "$input_file" \
    --from markdown \
    --to html5 \
    --standalone \
    --embed-resources \
    --highlight-style=tango \
    --metadata title:"$filename" \
    --output "$output_dir/html/${filename}.html"
  
  # Ajouter le support Mermaid si nécessaire
  if grep -q '```mermaid' "$input_file"; then
    echo "    • Ajout du support Mermaid..."
    # Remplacer </body> par le script Mermaid suivi de </body>
    sed -i 's|</body>|<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>\n<script>mermaid.initialize({startOnLoad:true});</script>\n</body>|' "$output_dir/html/${filename}.html"
  fi
  
  echo "  ✓ HTML généré: $output_dir/html/${filename}.html"
}

# Fonction pour convertir en PDF
convert_to_pdf() {
  local input_file="$1"
  local output_dir="$2"
  local filename=$(basename "$input_file" .md)
  
  echo "  • Conversion en PDF..."
  
  # Conversion directe en PDF
  pandoc "$input_file" \
    --from markdown \
    --pdf-engine=xelatex \
    --highlight-style=tango \
    --metadata title:"$filename" \
    --output "$output_dir/pdf/${filename}.pdf"
  
  echo "  ✓ PDF généré: $output_dir/pdf/${filename}.pdf"
}

# Fonction principale de traitement
process_file() {
  local input_file="$1"
  local output_dir="$2"
  local format="$3"
  local filename=$(basename "$input_file" .md)
  
  echo "📄 Traitement de $input_file"
  
  # Vérifier que le fichier existe
  if [[ ! -f "$input_file" ]]; then
    echo "⚠️ Le fichier $input_file n'existe pas"
    return 1
  fi
  
  # Conversions selon le format demandé
  if [[ "$format" == "html" || "$format" == "both" ]]; then
    convert_to_html "$input_file" "$output_dir"
  fi
  
  if [[ "$format" == "pdf" || "$format" == "both" ]]; then
    convert_to_pdf "$input_file" "$output_dir"
  fi
  
  echo "✅ Traitement terminé pour $filename"
  echo
}

# Traiter les arguments
output_dir="$OUTPUT_DIR"
format="both"
files=()

# Si aucun argument n'est fourni, afficher l'aide
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 fichier.md [fichier2.md ...]"
  exit 0
fi

# Parser les arguments
while [[ $# -gt 0 ]]; do
  files+=("$1")
  shift
done

# Traiter chaque fichier
for file in "${files[@]}"; do
  process_file "$file" "$output_dir" "$format"
done

echo "🎉 Conversion terminée !"