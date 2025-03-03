#!/bin/bash

# Créer les dossiers
mkdir -p output/pdf output/html

# Convertir en HTML
echo "Conversion en HTML..."
pandoc docs/example.md -f markdown -t html5 -s -o output/html/example.html

# Convertir en PDF
echo "Conversion en PDF..."
pandoc docs/example.md -f markdown -t pdf --pdf-engine=xelatex -o output/pdf/example.pdf

echo "Conversion terminée !"
