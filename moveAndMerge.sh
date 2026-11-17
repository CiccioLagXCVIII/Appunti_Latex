#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$HOME/Scrivania/Universita/02_Appunti_Latex/IndustrialRobotics/Esercitazioni Matlab"
DEST_DIR="$HOME/Scrivania/Esercitazioni_Semifinali"
OUT_NAME="E10_Full_Esercitazioni.pdf"
OUT_PATH="$DEST_DIR/$OUT_NAME"

if [ ! -d "$SRC_DIR" ]; then
    echo "Errore: cartella sorgente non trovata: $SRC_DIR" >&2
    exit 1
fi

if ! command -v pdfunite >/dev/null 2>&1; then
    echo "Errore: 'pdfunite' non trovato. Installa poppler-utils (sudo apt install poppler-utils)." >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

# Sposta tutti i PDF dalle esercitazioni alla cartella di destinazione
find "$SRC_DIR" -type f -name '*.pdf' -exec mv -t "$DEST_DIR" {} +

# Raccoglie i PDF nella cartella di destinazione in ordine alfabetico per nome file
mapfile -d '' -t pdf_files < <(
    find "$DEST_DIR" -maxdepth 1 -type f -name '*.pdf' ! -name "$OUT_NAME" -print0 | LC_ALL=C sort -z
)

if [ "${#pdf_files[@]}" -eq 0 ]; then
    echo "Nessun file PDF trovato in $DEST_DIR da unire."
    exit 0
fi

echo "Unione di ${#pdf_files[@]} PDF in ordine alfabetico:"
for f in "${pdf_files[@]}"; do
    echo "  - $(basename "$f")"
done

rm -f "$OUT_PATH"
if [ "${#pdf_files[@]}" -eq 1 ]; then
    cp -f "${pdf_files[0]}" "$OUT_PATH"
else
    pdfunite "${pdf_files[@]}" "$OUT_PATH"
fi

echo "PDF completo creato: $OUT_PATH"
