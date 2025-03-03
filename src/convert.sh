#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$PROJECT_ROOT/templates"
CONFIG_DIR="$PROJECT_ROOT/config"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Créer les dossiers nécessaires s'ils n'existent pas
mkdir -p "$OUTPUT_DIR/pdf" "$OUTPUT_DIR/html" "$OUTPUT_DIR/temp"

# Fonction pour afficher l'aide
show_help() {
  echo "Usage: $0 [options] file.md [file2.md ...]"
  echo
  echo "Options:"
  echo "  -h, --help             Affiche ce message d'aide"
  echo "  -o, --output DIR       Dossier de sortie (défaut: $OUTPUT_DIR)"
  echo "  -t, --template NAME    Template à utiliser (défaut: default)"
  echo "  -f, --format FORMAT    Format de sortie: pdf, html, both (défaut: both)"
  echo
  exit 0
}

# Fonction pour traiter les diagrammes PlantUML
process_plantuml() {
  local input_file="$1"
  local temp_dir="$2"
  local filename=$(basename "$input_file" .md)
  
  echo "  • Traitement des diagrammes PlantUML..."
  
  # Vérifier si plantuml est installé
  if ! command -v plantuml &> /dev/null; then
    echo "⚠️ PlantUML n'est pas installé, les diagrammes ne seront pas traités."
    return 1
  fi
  
  # Extraire et traiter les diagrammes PlantUML
  grep -n -A 1000 '```plantuml' "$input_file" | 
  grep -B 1000 -m 1 '```' | 
  grep -v '```' > "$temp_dir/${filename}_plantuml.puml"
  
  if [ -s "$temp_dir/${filename}_plantuml.puml" ]; then
    plantuml -tsvg "$temp_dir/${filename}_plantuml.puml" -o "$temp_dir"
    echo "  ✓ Diagrammes PlantUML générés"
  else
    echo "  → Aucun diagramme PlantUML trouvé"
    rm "$temp_dir/${filename}_plantuml.puml"
  fi
}

# Fonction pour traiter les diagrammes Mermaid
process_mermaid() {
  local input_file="$1"
  local temp_dir="$2"
  
  echo "  • Traitement des diagrammes Mermaid..."
  
  # Les versions récentes de Pandoc prennent en charge Mermaid nativement
  # Aucun traitement spécial n'est nécessaire
  echo "  ✓ Diagrammes Mermaid seront traités nativement par Pandoc"
}

# Fonction pour convertir en HTML
convert_to_html() {
  local input_file="$1"
  local output_dir="$2"
  local template="$3"
  local filename=$(basename "$input_file" .md)
  
  echo "  • Conversion en HTML..."
  
  # Créer le dossier de sortie HTML s'il n'existe pas
  mkdir -p "$output_dir/html"
  
  # Conversion Markdown -> HTML
  pandoc "$input_file" \
    --from markdown \
    --to html5 \
    --template="$TEMPLATE_DIR/${template}.html" \
    --css="$TEMPLATE_DIR/styles.css" \
    --highlight-style=tango \
    --self-contained \
    --toc \
    --toc-depth=3 \
    -o "$output_dir/html/${filename}.html"
  
  echo "  ✓ HTML généré: $output_dir/html/${filename}.html"
}

# Fonction pour convertir en PDF
convert_to_pdf() {
  local input_file="$1"
  local output_dir="$2"
  local template="$3"
  local filename=$(basename "$input_file" .md)
  
  echo "  • Conversion en PDF..."
  
  # Créer le dossier de sortie PDF s'il n'existe pas
  mkdir -p "$output_dir/pdf"
  
  # Conversion Markdown -> PDF via LaTeX
  pandoc "$input_file" \
    --from markdown \
    --template="$TEMPLATE_DIR/${template}.tex" \
    --pdf-engine=xelatex \
    --highlight-style=tango \
    --toc \
    --toc-depth=3 \
    --variable=geometry:margin=2.5cm \
    -o "$output_dir/pdf/${filename}.pdf"
  
  echo "  ✓ PDF généré: $output_dir/pdf/${filename}.pdf"
}

# Fonction principale de traitement
process_file() {
  local input_file="$1"
  local output_dir="$2"
  local template="$3"
  local format="$4"
  local filename=$(basename "$input_file" .md)
  local temp_dir="$output_dir/temp"
  
  echo "📄 Traitement de $input_file"
  
  # Vérifier que le fichier existe et est un fichier markdown
  if [[ ! -f "$input_file" ]]; then
    echo "⚠️ Le fichier $input_file n'existe pas"
    return 1
  fi
  
  if [[ ! "$input_file" =~ \.md$ ]]; then
    echo "⚠️ Le fichier $input_file n'est pas un fichier markdown"
    return 1
  fi
  
  # Créer le dossier temporaire s'il n'existe pas
  mkdir -p "$temp_dir"
  
  # Traitement des diagrammes
  process_plantuml "$input_file" "$temp_dir"
  process_mermaid "$input_file" "$temp_dir"
  
  # Conversions selon le format demandé
  if [[ "$format" == "html" || "$format" == "both" ]]; then
    convert_to_html "$input_file" "$output_dir" "$template"
  fi
  
  if [[ "$format" == "pdf" || "$format" == "both" ]]; then
    convert_to_pdf "$input_file" "$output_dir" "$template"
  fi
  
  echo "✅ Traitement terminé pour $filename"
  echo
}

# Traiter les arguments
output_dir="$OUTPUT_DIR"
template="default"
format="both"
files=()

# Si aucun argument n'est fourni, afficher l'aide
if [[ $# -eq 0 ]]; then
  show_help
fi

# Parser les options
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    -o|--output)
      output_dir="$2"
      shift 2
      ;;
    -t|--template)
      template="$2"
      shift 2
      ;;
    -f|--format)
      format="$2"
      shift 2
      ;;
    -*)
      echo "Option inconnue: $1"
      show_help
      ;;
    *)
      files+=("$1")
      shift
      ;;
  esac
done

# Vérifier que des fichiers ont été spécifiés
if [[ ${#files[@]} -eq 0 ]]; then
  echo "⚠️ Aucun fichier à traiter"
  show_help
fi

# Traiter chaque fichier
for file in "${files[@]}"; do
  process_file "$file" "$output_dir" "$template" "$format"
done

# Nettoyer les fichiers temporaires
rm -rf "$output_dir/temp"

echo "🎉 Conversion terminée !"