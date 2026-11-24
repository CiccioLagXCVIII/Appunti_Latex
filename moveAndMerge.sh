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

# AA Verifica dipendenze poppler-utils
for cmd in pdfunite pdfinfo; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Errore: '$cmd' Non Trovato. Installa poppler-utils." >&2
        exit 1
    fi
done

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

    # BB Sposta solo i PDF nelle sottocartelle esercitazioni (ignora le cartelle Images)
    find "$SRC_DIR" -maxdepth 2 -type f -name '*.pdf' ! -name "$OUT_NAME" -exec mv -t "$DEST_DIR" {} +

    # BB Raccoglie i PDF nella cartella di destinazione in ordine naturale
    mapfile -d '' -t pdf_files < <(
        find "$DEST_DIR" -maxdepth 1 -type f -name '*.pdf' ! -name "$OUT_NAME" -print0 | LC_ALL=C sort -z -V
    )
    EMPTY_MSG="Nessun File PDF Trovato In $DEST_DIR Da Unire."
else
    OUT_PATH="$DESKTOP_DIR/$OUT_NAME"

    # BB Legge i PDF direttamente dalla sorgente ignorando le sottocartelle Images
    mapfile -d '' -t pdf_files < <(
        find "$SRC_DIR" -maxdepth 2 -type f -name '*.pdf' ! -name "$OUT_NAME" -printf '%f\t%p\0' \
            | LC_ALL=C sort -z -V | cut -z -f2-
    )
    EMPTY_MSG="Nessun File PDF Trovato In $SRC_DIR Da Unire."
fi

if [ "${#pdf_files[@]}" -eq 0 ]; then
    echo "$EMPTY_MSG"
    exit 0
fi

# AA Generazione pagina PDF bianca valida (PDF 1.4 senza dipendenze esterne)
make_blank_pdf() {
    local out="$1" w="$2" h="$3"
    local hdr o1 o2 o3 p1 p2 p3 xref

    hdr=$'%PDF-1.4\n'
    o1=$'1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n'
    o2=$'2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n'
    o3="3 0 obj"$'\n'"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 $w $h] /Resources << >> >>"$'\n'"endobj"$'\n'

    # BB Calcolo offset byte esatti per la tabella xref
    p1=${#hdr}
    p2=$((p1 + ${#o1}))
    p3=$((p2 + ${#o2}))
    xref=$((p3 + ${#o3}))

    {
        printf '%s%s%s%s' "$hdr" "$o1" "$o2" "$o3"
        printf 'xref\n0 4\n0000000000 65535 f \n'
        printf '%010d 00000 n \n' "$p1" "$p2" "$p3"
        printf 'trailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n' "$xref"
    } > "$out"
}

# AA Costruzione sequenza di unione con allineamento fronte/retro
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

merge_list=()
total_pages=0
prev_orient=""
prev_w=""
prev_h=""

echo "Unione Di ${#pdf_files[@]} PDF (Allineamento Fronte/Retro):"
for idx in "${!pdf_files[@]}"; do
    f="${pdf_files[$idx]}"

    # BB Estrae numero pagine, dimensioni effettive e tipo (portrait / landscape via box o Title: Appendice)
    read -r pages eff_w eff_h orient < <(LC_ALL=C pdfinfo "$f" | LC_ALL=C awk '
        /^Title:/     { sub(/^Title:[[:space:]]*/, ""); if ($0 ~ /^Appendice[[:space:]]/) is_app=1 }
        /^Pages:/     { p=$2 }
        /^Page size:/ { w=$3+0; h=$5+0 }
        /^Page rot:/  { r=$3+0 }
        END {
            if (r % 180 != 0) { t=w; w=h; h=t }
            printf "%d %.2f %.2f %s\n", p, w, h, ((w > h || is_app) ? "landscape" : "portrait")
        }
    ')

    if [ -z "${pages:-}" ] || [ "$pages" -eq 0 ]; then
        echo "Errore: Impossibile Leggere Le Pagine Di $f" >&2
        exit 1
    fi

    # BB Inserisce pagina bianca se il totale e' dispari prima di un file verticale o cambio orientamento
    # CC Per risparmiare carta tra esercitazioni verticali consecutive, sostituisci [ "$orient" = "portrait" ] con [ "$idx" -eq 1 ]
    if [ "$total_pages" -gt 0 ] && (( total_pages % 2 == 1 )); then
        if [ "$orient" = "portrait" ] || [ "$prev_orient" != "$orient" ]; then
            blank_file="$TMP_DIR/blank_${#merge_list[@]}.pdf"
            make_blank_pdf "$blank_file" "$prev_w" "$prev_h"
            merge_list+=("$blank_file")
            total_pages=$((total_pages + 1))
            echo "  + [Pagina Bianca $prev_orient]"
        fi
    fi

    merge_list+=("$f")
    total_pages=$((total_pages + pages))
    prev_orient="$orient"
    prev_w="$eff_w"
    prev_h="$eff_h"
    echo "  - $(basename "$f") ($pages pag., $orient -> tot. $total_pages)"
done

# AA Generazione file PDF finale
rm -f "$OUT_PATH"
if [ "${#merge_list[@]}" -eq 1 ]; then
    cp -f "${merge_list[0]}" "$OUT_PATH"
else
    pdfunite "${merge_list[@]}" "$OUT_PATH"
fi

echo "PDF Completo Creato: $OUT_PATH"
