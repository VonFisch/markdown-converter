#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Vérification des dépendances
check_dependencies() {
  local missing_deps=()
  
  echo "🔍 Vérification des dépendances..."
  
  # Dépendances requises
  local dependencies=(
    "pandoc"
    "xelatex"
    "plantuml"
  )
  
  # Vérifier chaque dépendance
  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
      missing_deps+=("$dep")
    fi
  done
  
  # Si des dépendances sont manquantes
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "⚠️ Dépendances manquantes:"
    for dep in "${missing_deps[@]}"; do
      echo "  - $dep"
    done
    echo
    echo "📋 Installez les dépendances manquantes avec:"
    echo "  make install"
    return 1
  fi
  
  echo "✅ Toutes les dépendances sont installées"
  return 0
}

# Fonctions pour l'installation des dépendances
install_pandoc() {
  local pandoc_version="3.1.12"
  
  echo "📦 Installation de Pandoc ${pandoc_version}..."
  
  if command -v pandoc &> /dev/null; then
    echo "  → Pandoc est déjà installé: $(pandoc --version | head -n 1)"
    return 0
  fi
  
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    wget "https://github.com/jgm/pandoc/releases/download/${pandoc_version}/pandoc-${pandoc_version}-1-amd64.deb" -O /tmp/pandoc.deb
    sudo dpkg -i /tmp/pandoc.deb
    rm /tmp/pandoc.deb
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    brew install pandoc
  else
    echo "⚠️ Système d'exploitation non pris en charge pour l'installation automatique de Pandoc"
    echo "  → Téléchargez et installez Pandoc manuellement depuis https://pandoc.org/installing.html"
    return 1
  fi
  
  echo "✅ Pandoc installé avec succès: $(pandoc --version | head -n 1)"
}

install_latex() {
  echo "📦 Installation de LaTeX..."
  
  if command -v xelatex &> /dev/null; then
    echo "  → LaTeX est déjà installé: $(xelatex --version | head -n 1)"
    return 0
  fi
  
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt-get update
    sudo apt-get install -y texlive-xetex texlive-latex-extra texlive-fonts-recommended texlive-lang-french texlive-latex-recommended
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    brew install --cask mactex
  else
    echo "⚠️ Système d'exploitation non pris en charge pour l'installation automatique de LaTeX"
    echo "  → Téléchargez et installez LaTeX manuellement"
    return 1
  fi
  
  echo "✅ LaTeX installé avec succès"
}

install_plantuml() {
  local plantuml_version="1.2024.0"
  
  echo "📦 Installation de PlantUML ${plantuml_version}..."
  
  if command -v plantuml &> /dev/null; then
    echo "  → PlantUML est déjà installé"
    return 0
  fi
  
  # Vérifier si Java est installé
  if ! command -v java &> /dev/null; then
    echo "⚠️ Java est requis pour PlantUML et n'est pas installé"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt-get update
      sudo apt-get install -y default-jre
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install --cask adoptopenjdk
    else
      echo "  → Installez Java manuellement"
      return 1
    fi
  fi
  
  # Installer PlantUML
  wget "https://github.com/plantuml/plantuml/releases/download/v${plantuml_version}/plantuml-${plantuml_version}.jar" -O /tmp/plantuml.jar
  sudo mkdir -p /opt/plantuml
  sudo mv /tmp/plantuml.jar /opt/plantuml/plantuml.jar
  
  # Créer le script wrapper
  echo '#!/bin/bash' | sudo tee /usr/local/bin/plantuml > /dev/null
  echo 'java -jar /opt/plantuml/plantuml.jar "$@"' | sudo tee -a /usr/local/bin/plantuml > /dev/null
  sudo chmod +x /usr/local/bin/plantuml
  
  echo "✅ PlantUML installé avec succès"
}

# Installer toutes les dépendances
install_all_dependencies() {
  echo "🚀 Installation de toutes les dépendances..."
  
  install_pandoc
  install_latex
  install_plantuml
  
  echo "✅ Installation terminée"
}