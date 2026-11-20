#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$HOME/Scrivania/Universita/02_Appunti_Latex/IndustrialRobotics/Esercitazioni Matlab"
DEST_DIR="$HOME/Scrivania/Esercitazioni_Merged"
DESKTOP_DIR="$HOME/Scrivania"
OUT_NAME="E10_Full_Esercitazioni.pdf"

if [ ! -d "$SRC_DIR" ]; then
    echo "Errore: Cartella Sorgente Non Trovata: $SRC_DIR" >&2
    exit 1
fi

if ! command -v pdfunite >/dev/null 2>&1; then
    echo "Errore: 'pdfunite' Non Trovato. Installa poppler-utils." >&2
    exit 1
fi

# --- Scelta della modalità ---
echo "  1) Sposta I PDF In '$DEST_DIR' E Crea Il File Unito"
echo "  2) Crea Solo Il File Unito In '/Scrivania'"
while true; do
    read -rp "Scelta [1/2]: " choice
    case "$choice" in
        1|2) break ;;
        *) echo "Scelta Non Valida, Scrivi 1 Oppure 2." ;;
    esac
done

if [ "$choice" = "1" ]; then
    OUT_PATH="$DEST_DIR/$OUT_NAME"
    mkdir -p "$DEST_DIR"

    # Sposta tutti i PDF dalle esercitazioni alla cartella di destinazione
    find "$SRC_DIR" -type f -name '*.pdf' -exec mv -t "$DEST_DIR" {} +

    # Raccoglie i PDF nella cartella di destinazione in ordine alfabetico per nome file
    mapfile -d '' -t pdf_files < <(
        find "$DEST_DIR" -maxdepth 1 -type f -name '*.pdf' ! -name "$OUT_NAME" -print0 | LC_ALL=C sort -z
    )
    EMPTY_MSG="Nessun File PDF Trovato In $DEST_DIR Da Unire."
else
    OUT_PATH="$DESKTOP_DIR/$OUT_NAME"

    # Legge i PDF direttamente dalla sorgente (senza spostarli),
    # ordinati alfabeticamente per nome file (non per percorso completo)
    mapfile -d '' -t pdf_files < <(
        find "$SRC_DIR" -type f -name '*.pdf' ! -name "$OUT_NAME" -printf '%f\t%p\0' \
            | LC_ALL=C sort -z | cut -z -f2-
    )
    EMPTY_MSG="Nessun File PDF Trovato In $SRC_DIR Da Unire."
fi

if [ "${#pdf_files[@]}" -eq 0 ]; then
    echo "$EMPTY_MSG"
    exit 0
fi

echo "Unione Di ${#pdf_files[@]} PDF In Ordine Alfabetico:"
for f in "${pdf_files[@]}"; do
    echo "  - $(basename "$f")"
done

rm -f "$OUT_PATH"
if [ "${#pdf_files[@]}" -eq 1 ]; then
    cp -f "${pdf_files[0]}" "$OUT_PATH"
else
    pdfunite "${pdf_files[@]}" "$OUT_PATH"
fi

echo "PDF Completo Creato: $OUT_PATH"
