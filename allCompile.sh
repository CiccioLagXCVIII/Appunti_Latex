#!/usr/bin/env bash
# ==============================================================================
# allCompile.sh - Compilatore e Pulitore Interattivo LaTeX per Ubuntu / Linux
# ==============================================================================

set -o pipefail

# Colori per il terminale
C_RESET="\033[0m"
C_RED="\033[1;31m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_CYAN="\033[1;36m"
C_DARKCYAN="\033[0;36m"
C_GRAY="\033[0;90m"
C_MAGENTA="\033[1;35m"

# Configurazione cartella di base
BASE_DIR="${1:-.}"

if [ ! -d "$BASE_DIR" ]; then
    echo -e "${C_RED}ERRORE: La cartella '$BASE_DIR' non esiste!${C_RESET}"
    exit 1
fi

BASE_DIR="$(cd "$BASE_DIR" && pwd)"
ROOT_PATH="$BASE_DIR"
CURRENT_PATH="$ROOT_PATH"

# Estensioni generate da LaTeX da rimuovere
TARGET_EXTENSIONS=(
    "pdf" "aux" "log" "synctex.gz" "synctex" "out" "toc"
    "lof" "lot" "bbl" "blg" "fls" "fdb_latexmk" "nav"
    "snm" "vrb" "bcf" "run.xml" "xdv"
)

# ------------------------------------------------------------------------------
# Rilevamento automatico del motore LaTeX
# ------------------------------------------------------------------------------
get_latex_engine() {
    local file_path="$1"
    local engine="pdflatex"

    if [ -f "$file_path" ]; then
        local head_lines
        head_lines=$(head -n 35 "$file_path" 2>/dev/null)

        if echo "$head_lines" | grep -Eiq '%\s*!TEX\s+(ts-)?program\s*=\s*xelatex|\\usepackage(\[[^]]*\])?\{fontspec\}|\\usepackage(\[[^]]*\])?\{unicode-math\}'; then
            engine="xelatex"
        elif echo "$head_lines" | grep -Eiq '%\s*!TEX\s+(ts-)?program\s*=\s*lualatex'; then
            engine="lualatex"
        fi
    fi

    echo "$engine"
}

# ------------------------------------------------------------------------------
# Chiusura forzata processi LaTeX appesi
# ------------------------------------------------------------------------------
kill_latex_processes() {
    pkill -9 -f '(pdftex|xelatex|lualatex|latex|texify)' 2>/dev/null || true
}

# Stack per navigazione indietro [I]
nav_stack=()

TARGET_TYPE=""
TARGET_PATH=""
TARGET_NAME=""

# ------------------------------------------------------------------------------
# LOOP DI NAVIGAZIONE INTERATTIVA
# ------------------------------------------------------------------------------
while [ -z "$TARGET_TYPE" ]; do
    if [ "$CURRENT_PATH" = "$ROOT_PATH" ]; then
        # Cartelle al livello 1
        mapfile -t root_folders < <(find "$CURRENT_PATH" -mindepth 1 -maxdepth 1 -type d \
            ! -name '.*' ! -name 'node_modules' 2>/dev/null | sort)

        # File .tex con \documentclass nella root
        root_tex_files=()
        while IFS= read -r f; do
            [ -n "$f" ] && grep -q '\\documentclass' "$f" 2>/dev/null && root_tex_files+=("$f")
        done < <(find "$CURRENT_PATH" -mindepth 1 -maxdepth 1 -type f -name '*.tex' 2>/dev/null | sort)

        if [ ${#root_folders[@]} -eq 0 ] && [ ${#root_tex_files[@]} -eq 0 ]; then
            echo -e "${C_YELLOW}Nessun contenuto compilabile trovato all'interno di '$ROOT_PATH'.${C_RESET}"
            exit 0
        fi

        echo -e "\n${C_CYAN}=== SELEZIONA LA CARTELLA DI LAVORO O IL FILE ===${C_RESET}"

        declare -a menu_types=()
        declare -a menu_items=()
        r_index=1

        for dir in "${root_folders[@]}"; do
            echo -e "[$r_index] $(basename "$dir")"
            menu_types[r_index]="Dir"
            menu_items[r_index]="$dir"
            ((r_index++))
        done

        if [ ${#root_tex_files[@]} -gt 0 ]; then
            echo -e "\n${C_GRAY}--- File .tex Principali ---${C_RESET}"
            for file in "${root_tex_files[@]}"; do
                echo -e "[$r_index] [File]     $(basename "$file")"
                menu_types[r_index]="File"
                menu_items[r_index]="$file"
                ((r_index++))
            done
        fi

        echo -e "\n[A] Tutte Le Cartelle (Ricorsivo)"
        echo -e "[Q] Esci Dallo Script"

        read -rp $'\nInserisci Numero Corrispondente [oppure A o Q]: ' choice
        choice=$(echo "$choice" | tr -d '[:space:]')

        case "$choice" in
            [Qq])
                echo -e "${C_GRAY}Uscita dallo script.${C_RESET}"
                exit 0
                ;;
            [Aa])
                TARGET_TYPE="FolderRecursive"
                TARGET_PATH="$CURRENT_PATH"
                TARGET_NAME="Tutte Le Cartelle (Ricorsivo)"
                ;;
            ''|*[!0-9]*)
                echo -e "${C_RED}Selezione non valida. Riprova.${C_RESET}"
                ;;
            *)
                if [ "$choice" -ge 1 ] && [ "$choice" -lt "$r_index" ]; then
                    if [ "${menu_types[choice]}" = "Dir" ]; then
                        nav_stack+=("$CURRENT_PATH")
                        CURRENT_PATH="${menu_items[choice]}"
                    else
                        TARGET_TYPE="SingleFile"
                        TARGET_PATH="${menu_items[choice]}"
                        TARGET_NAME="File: $(basename "${menu_items[choice]}")"
                    fi
                else
                    echo -e "${C_RED}Selezione fuori intervallo. Riprova.${C_RESET}"
                fi
                ;;
        esac

    else
        # Sottomenu di drill-down
        rel_display="${CURRENT_PATH#"$ROOT_PATH"/}"
        curr_dir_name="$(basename "$CURRENT_PATH")"

        # Sottocartelle che contengono almeno un file .tex
        sub_dirs=()
        while IFS= read -r d; do
            [ -z "$d" ] && continue
            bname="$(basename "$d")"
            [[ "$bname" =~ ^\. ]] && continue
            [ "$bname" = "node_modules" ] && continue
            [ "$bname" = "E0_PDF_Compilati" ] && continue
            [[ "$bname" =~ (^|_)images?($|_) ]] && continue

            if find "$d" -type f -name '*.tex' -print -quit 2>/dev/null | grep -q .; then
                sub_dirs+=("$d")
            fi
        done < <(find "$CURRENT_PATH" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

        # File .tex con \documentclass nella cartella corrente
        direct_tex_files=()
        while IFS= read -r f; do
            [ -n "$f" ] && grep -q '\\documentclass' "$f" 2>/dev/null && direct_tex_files+=("$f")
        done < <(find "$CURRENT_PATH" -mindepth 1 -maxdepth 1 -type f -name '*.tex' 2>/dev/null | sort)

        echo -e "\n${C_DARKCYAN}Percorso: $rel_display${C_RESET}"
        echo -e "${C_CYAN}=== COSA VUOI ELABORARE? ===${C_RESET}"
        echo -e "[A] Tutta La Cartella '$curr_dir_name' (Ricorsivo)"

        declare -a sub_menu_types=()
        declare -a sub_menu_items=()
        opt_index=1

        if [ ${#sub_dirs[@]} -gt 0 ]; then
            echo -e "\n${C_GRAY}--- Sottocartelle Disponibili ---${C_RESET}"
            for sd in "${sub_dirs[@]}"; do
                echo -e "[$opt_index] [Cartella] $(basename "$sd")"
                sub_menu_types[opt_index]="Dir"
                sub_menu_items[opt_index]="$sd"
                ((opt_index++))
            done
        fi

        if [ ${#direct_tex_files[@]} -gt 0 ]; then
            echo -e "\n${C_GRAY}--- File .tex Compilabili ---${C_RESET}"
            for tf in "${direct_tex_files[@]}"; do
                echo -e "[$opt_index] [File]     $(basename "$tf")"
                sub_menu_types[opt_index]="File"
                sub_menu_items[opt_index]="$tf"
                ((opt_index++))
            done
        fi

        echo -e "\n[I] Torna Indietro"
        echo -e "[Q] Esci Dallo Script"

        read -rp $'\nInserisci Opzione [A, Numero, I o Q]: ' sub_choice
        sub_choice=$(echo "$sub_choice" | tr -d '[:space:]')

        case "$sub_choice" in
            [Qq])
                echo -e "${C_GRAY}Uscita dallo script.${C_RESET}"
                exit 0
                ;;
            [Ii])
                if [ ${#nav_stack[@]} -gt 0 ]; then
                    CURRENT_PATH="${nav_stack[-1]}"
                    unset 'nav_stack[${#nav_stack[@]}-1]'
                else
                    CURRENT_PATH="$ROOT_PATH"
                fi
                ;;
            [Aa])
                TARGET_TYPE="FolderRecursive"
                TARGET_PATH="$CURRENT_PATH"
                TARGET_NAME="Cartella: $curr_dir_name (Ricorsivo)"
                ;;
            ''|*[!0-9]*)
                echo -e "${C_RED}Selezione non valida. Riprova.${C_RESET}"
                ;;
            *)
                if [ "$sub_choice" -ge 1 ] && [ "$sub_choice" -lt "$opt_index" ]; then
                    if [ "${sub_menu_types[sub_choice]}" = "Dir" ]; then
                        nav_stack+=("$CURRENT_PATH")
                        CURRENT_PATH="${sub_menu_items[sub_choice]}"
                    else
                        TARGET_TYPE="SingleFile"
                        TARGET_PATH="${sub_menu_items[sub_choice]}"
                        TARGET_NAME="File: $(basename "${sub_menu_items[sub_choice]}")"
                    fi
                else
                    echo -e "${C_RED}Selezione fuori intervallo. Riprova.${C_RESET}"
                fi
                ;;
        esac
    fi
done

echo -e "\n${C_GREEN}Hai Selezionato: $TARGET_NAME${C_RESET}"

# ------------------------------------------------------------------------------
# SELEZIONE OPERAZIONE
# ------------------------------------------------------------------------------
echo -e "\n${C_CYAN}=== SELEZIONA L'OPERAZIONE DA ESEGUIRE ===${C_RESET}"
if [ "$TARGET_TYPE" = "SingleFile" ]; then
    echo "[1] Cancella I File Ausiliari E Il PDF Di Questo Documento"
    echo "[2] Ricompila Solo Questo File .tex"
    echo "[3] Entrambi (Cancella E Poi Ricompila)"
else
    echo "[1] Cancella I PDF E I File Ausiliari Generati Da LaTeX"
    echo "[2] Ricompila Solo I File .tex"
    echo "[3] Entrambi (Cancella E Poi Ricompila)"
fi

read -rp $'\nInserisci l\'opzione [1, 2 o 3]: ' action_choice
action_choice=$(echo "$action_choice" | tr -d '[:space:]')

DO_CLEAN=false
DO_COMPILE=false

case "$action_choice" in
    1) DO_CLEAN=true ;;
    2) DO_COMPILE=true ;;
    3) DO_CLEAN=true; DO_COMPILE=true ;;
    *) echo -e "${C_RED}Opzione non valida. Uscita dallo script.${C_RESET}"; exit 1 ;;
esac

# Terminazione processi appesi
echo -e "\n${C_YELLOW}--- Terminazione Eventuali Processi LaTeX Appesi In Background... ---${C_RESET}"
kill_latex_processes

# ------------------------------------------------------------------------------
# FASE DI PULIZIA
# ------------------------------------------------------------------------------
if [ "$DO_CLEAN" = true ]; then
    echo -e "\n${C_MAGENTA}--- Ricerca Dei File Generati Da LaTeX In Corso... ---${C_RESET}"
    files_to_delete=()

    if [ "$TARGET_TYPE" = "SingleFile" ]; then
        dir_name="$(dirname "$TARGET_PATH")"
        base_name="$(basename "$TARGET_PATH" .tex)"

        while IFS= read -r file; do
            [ -n "$file" ] && files_to_delete+=("$file")
        done < <(find "$dir_name" -maxdepth 1 -type f -name "${base_name}*.synctex*(busy)" 2>/dev/null)

        for ext in "${TARGET_EXTENSIONS[@]}"; do
            candidate="$dir_name/$base_name.$ext"
            [ -f "$candidate" ] && files_to_delete+=("$candidate")
        done
    else
        # Trova file con le estensioni note solo se esiste il corrispettivo file .tex
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            f_dir="$(dirname "$f")"
            f_file="$(basename "$f")"

            # Rimuovi sempre i synctex busy rimasti appesi
            if [[ "$f_file" =~ \.synctex.*\(busy\)$ ]]; then
                files_to_delete+=("$f")
                continue
            fi

            for ext in "${TARGET_EXTENSIONS[@]}"; do
                if [[ "$f_file" == *."$ext" ]]; then
                    name_no_ext="${f_file%."$ext"}"
                    if [ -f "$f_dir/$name_no_ext.tex" ]; then
                        files_to_delete+=("$f")
                        break
                    fi
                fi
            done
        done < <(find "$TARGET_PATH" -type f 2>/dev/null)
    fi

    if [ ${#files_to_delete[@]} -gt 0 ]; then
        echo -e "${C_MAGENTA}Trovati ${#files_to_delete[@]} File Generati Da .tex. Eliminazione In Corso...${C_RESET}"
        for f in "${files_to_delete[@]}"; do
            rm -f "$f" 2>/dev/null
            echo -e "  ${C_GRAY}Rimosso: $(basename "$f")${C_RESET}"
        done
        echo -e "${C_GREEN}Pulizia Completata Con Successo!${C_RESET}\n"
    else
        echo -e "${C_GRAY}Nessun File Generato Da .tex Trovato Da Rimuovere.${C_RESET}\n"
    fi
fi

# ------------------------------------------------------------------------------
# FASE DI COMPILAZIONE
# ------------------------------------------------------------------------------
if [ "$DO_COMPILE" = true ]; then
    files_to_compile=()

    if [ "$TARGET_TYPE" = "SingleFile" ]; then
        files_to_compile+=("$TARGET_PATH")
    else
        while IFS= read -r f; do
            [ -n "$f" ] && files_to_compile+=("$f")
        done < <(find "$TARGET_PATH" -type f -name '*.tex' 2>/dev/null | sort)
    fi

    if [ ${#files_to_compile[@]} -eq 0 ]; then
        echo -e "${C_GRAY}Nessun File .tex Trovato Nel Percorso Selezionato.${C_RESET}"
    else
        echo -e "\n${C_YELLOW}Trovati ${#files_to_compile[@]} File .tex Da Analizzare...${C_RESET}"

        for file in "${files_to_compile[@]}"; do
            f_name="$(basename "$file")"
            f_dir="$(dirname "$file")"

            # Salta i frammenti sprovvisti di \documentclass
            if ! grep -q '\\documentclass' "$file" 2>/dev/null; then
                echo -e "\n${C_GRAY}[SALTATO] $f_name (Frammento privo di \\documentclass)${C_RESET}"
                continue
            fi

            engine="$(get_latex_engine "$file")"

            # Controllo esistenza del compilatore
            if ! command -v "$engine" &>/dev/null; then
                echo -e "\n${C_RED}ERRORE: Motore '$engine' non installato sul sistema!${C_RESET}"
                echo -e "${C_YELLOW}Installa TeX Live con: sudo apt install texlive-latex-extra texlive-xetex${C_RESET}"
                continue
            fi

            echo -e "\n${C_GRAY}==================================================${C_RESET}"
            echo -e "${C_CYAN}Compilando: $f_name [Motore: $engine]${C_RESET}"
            echo -e "${C_GRAY}Cartella:   $f_dir${C_RESET}"
            echo -e "${C_GRAY}==================================================${C_RESET}"

            # Esecuzione in subshell per preservare la directory corrente
            (
                cd "$f_dir" || exit 1

                # 1a Passata (chiusura stdin con </dev/null per evitare blocchi interattivi)
                if "$engine" -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$f_name" </dev/null >/dev/null 2>&1; then
                    # 2a Passata (Indice, riferimenti e synctex)
                    if "$engine" -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$f_name" </dev/null >/dev/null 2>&1; then
                        echo -e "${C_GREEN}OK: Compilazione Di $f_name Eseguita ($engine - Indice e SyncTeX aggiornati).${C_RESET}"
                    else
                        echo -e "${C_RED}ERRORE: 2a Passata Di $f_name Fallita ($engine).${C_RESET}"
                        exit 1
                    fi
                else
                    echo -e "${C_RED}ERRORE: Compilazione Di $f_name Fallita ($engine).${C_RESET}"

                    # Diagnostica: stampa a schermo le prime righe di errore dal .log
                    log_file="${f_name%.tex}.log"
                    if [ -f "$log_file" ]; then
                        echo -e "${C_YELLOW}Dettaglio errori rilevati nel log:${C_RESET}"
                        grep -E -A 1 '^!' "$log_file" | head -n 10
                    fi

                    kill_latex_processes
                    rm -f ./*.synctex*\(busy\)* 2>/dev/null
                    exit 1
                fi
            )
        done
    fi
fi

echo -e "\n${C_YELLOW}Processo Completato!${C_RESET}"
