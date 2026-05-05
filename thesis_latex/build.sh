#!/usr/bin/env bash
# Rebuild the thesis PDF.
# Run from within thesis_latex/ directory.
set -e

xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex

echo "Done — main.pdf"
