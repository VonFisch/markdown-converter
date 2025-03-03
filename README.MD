# Convertisseur Markdown vers PDF/HTML

Un outil en ligne de commande pour convertir des fichiers Markdown en PDF et HTML de haute qualité, avec prise en charge des blocs de code, diagrammes PlantUML, diagrammes Mermaid, et templates personnalisables.

## Fonctionnalités

- Conversion de Markdown vers PDF via LaTeX
- Conversion de Markdown vers HTML
- Coloration syntaxique pour de nombreux langages de programmation
- Support des diagrammes PlantUML
- Support des diagrammes Mermaid
- Templates LaTeX et HTML personnalisables
- Pipeline CI/CD avec GitHub Actions
- Publication automatique sur GitHub Pages

## Prérequis

- Pandoc
- LaTeX (avec XeLaTeX)
- PlantUML
- Java (pour PlantUML)
- Bash

## Installation

1. Clonez ce dépôt :
```bash
git clone https://github.com/votre-utilisateur/markdown-converter.git
cd markdown-converter
```

2. Installez les dépendances :
```bash
make install
```

Cette commande installera automatiquement Pandoc, LaTeX et PlantUML si nécessaire.

## Utilisation

### Conversion d'un fichier unique

```bash
./src/convert.sh chemin/vers/fichier.md
```

Options disponibles :
- `-o`, `--output` : Dossier de sortie (défaut: ./output)
- `-t`, `--template` : Template à utiliser (défaut: default)
- `-f`, `--format` : Format de sortie: pdf, html, both (défaut: both)

### Conversion de tous les fichiers Markdown

```bash
./build.sh
```

Les fichiers convertis seront placés dans le dossier `output/` :
- Les PDF dans `output/pdf/`
- Les HTML dans `output/html/`

### Personnalisation des templates

Vous pouvez personnaliser l'apparence des documents générés en modifiant les templates dans le dossier `templates/` :
- `default.tex` : Template LaTeX pour la génération de PDF
- `default.html` : Template HTML
- `styles.css` : Styles CSS pour le HTML

## CI/CD avec GitHub Actions

Ce projet inclut une configuration GitHub Actions qui :
1. Compile automatiquement tous les documents Markdown lors d'un push
2. Publie les résultats sur GitHub Pages
3. Stocke les PDF et HTML générés comme artifacts

Pour activer la CI/CD :
1. Assurez-vous que votre dépôt a GitHub Actions activé
2. Poussez votre code vers GitHub
3. Activez GitHub Pages dans les paramètres de votre dépôt (branch: gh-pages)

## Exemples

Consultez le dossier `docs/` pour des exemples de documents Markdown qui démontrent les fonctionnalités du convertisseur.

## Licence

Ce projet est sous licence MIT.