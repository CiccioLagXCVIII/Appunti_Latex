# AA CONFIGURAZIONE PERCORSO BASE
$baseDir = ".\"

if (-not (Test-Path $baseDir)) {
    Write-Host "ERRORE: La cartella '$baseDir' non esiste!" -ForegroundColor Red
    exit
}

# Recupera tutte le sottocartelle dirette di 02_Appunti_Latex
$folders = Get-ChildItem -Path $baseDir -Directory

if ($folders.Count -eq 0) {
    Write-Host "Nessuna sottocartella trovata all'interno di '$baseDir'." -ForegroundColor Yellow
    exit
}

# AA SELEZIONE DELLA CARTELLA
Write-Host "`n=== SELEZIONA LA CARTELLA DI LAVORO ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $folders.Count; $i++) {
    Write-Host "[$($i + 1)] $($folders[$i].Name)"
}
Write-Host "[A] Tutte Le Cartelle In 02_Appunti_Latex"

$folderChoice = Read-Host "`nInserisci Numero Corrispondente (Oppure 'A')"

$selectedPath = $null
if ($folderChoice -match '^[Aa]$') {
    $selectedPath = (Resolve-Path $baseDir).Path
    Write-Host "Hai Selezionato: Tutte Le Cartelle In $baseDir" -ForegroundColor Green
} elseif ($folderChoice -match '^\d+$' -and [int]$folderChoice -ge 1 -and [int]$folderChoice -le $folders.Count) {
    $selectedFolder = $folders[[int]$folderChoice - 1]
    $selectedPath = $selectedFolder.FullName
    Write-Host "Hai Selezionato: $($selectedFolder.Name)" -ForegroundColor Green
} else {
    Write-Host "Selezione Non Valida. Uscita Dallo Script." -ForegroundColor Red
    exit
}

# AA SELEZIONE DELL'OPERAZIONE
Write-Host "`n=== SELEZIONA L'OPERAZIONE DA ESEGUIRE ===" -ForegroundColor Cyan
Write-Host "[1] Cancella I PDF E I File Ausiliari Generati Da LaTeX"
Write-Host "[2] Ricompila Solo I File .tex"
Write-Host "[3] Entrambi (Cancella E Poi Ricompila)"

$actionChoice = Read-Host "`nInserisci l'opzione [1, 2 o 3]"

$doClean   = $actionChoice -in @("1", "3")
$doCompile = $actionChoice -in @("2", "3")

if (-not $doClean -and -not $doCompile) {
    Write-Host "Opzione non valida. Uscita dallo script." -ForegroundColor Red
    exit
}

# AA SBLOCCO PREVENTIVO DEI PROCESSI LATEX APPESI
Write-Host "`n--- Terminazione Eventuali Processi LaTeX Appesi In Background... ---" -ForegroundColor DarkYellow
Stop-Process -Name *pdftex*, *xelatex*, *lualatex*, *latex*, *texify*, perl -Force -ErrorAction SilentlyContinue

# 3. PULIZIA DEI FILE (PDF E AUSILIARI) GENERATI DA .TEX
if ($doClean) {
    Write-Host "`n--- Ricerca Dei File Generati Da LaTeX In Corso... ---" -ForegroundColor Magenta

    # Estensioni dei file generati da LaTeX da rimuovere (inclusi i .synctex(busy))
    $targetExtensions = @(
        ".pdf", ".aux", ".log", ".synctex.gz", ".synctex",
        ".synctex(busy)", ".synctex.gz(busy)",
        ".out", ".toc", ".lof", ".lot", ".bbl", ".blg",
        ".fls", ".fdb_latexmk", ".nav", ".snm", ".vrb",
        ".bcf", ".run.xml", ".xdv"
    )

    # Cerca i file con tali estensioni (elimina sempre i file (busy) anche se il .tex è già stato cancellato)
    $filesToDelete = Get-ChildItem -Path $selectedPath -File -Recurse | Where-Object {
        $file = $_
        if ($file.Name -like "*.synctex*(busy)") {
            return $true
        }
        foreach ($ext in $targetExtensions) {
            if ($file.Name.EndsWith($ext, [System.StringComparison]::OrdinalIgnoreCase)) {
                $baseName = $file.Name.Substring(0, $file.Name.Length - $ext.Length)
                $texCounterpart = Join-Path $file.DirectoryName "$baseName.tex"
                return (Test-Path $texCounterpart)
            }
        }
        return $false
    }

    if ($filesToDelete) {
        Write-Host "Trovati $($filesToDelete.Count) File Generati Da .tex. Eliminazione In Corso..." -ForegroundColor Magenta
        foreach ($file in $filesToDelete) {
            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
            Write-Host "  Rimosso: $($file.Name)" -ForegroundColor DarkGray
        }
        Write-Host "Pulizia Completata Con Successo!`n" -ForegroundColor Green
    } else {
        Write-Host "Nessun File Generato Da .tex Trovato Da Rimuovere.`n" -ForegroundColor Gray
    }
}

# 4. COMPILAZIONE DEI FILE .TEX
if ($doCompile) {
    $files = Get-ChildItem -Path $selectedPath -Filter "*.tex" -Recurse

    if ($files.Count -eq 0) {
        Write-Host "Nessun File .tex Trovato Nel Percorso Selezionato." -ForegroundColor Gray
    } else {
        Write-Host "`nTrovati $($files.Count) File .tex Da Analizzare..." -ForegroundColor Yellow

        foreach ($file in $files) {
            # Salta i file .tex che sono solo frammenti (privi di \documentclass) per evitare blocchi
            $hasDocClass = Select-String -LiteralPath $file.FullName -Pattern "\\documentclass" -Quiet
            if (-not $hasDocClass) {
                Write-Host "`n[SALTATO] $($file.Name) (Frammento privo di \documentclass)" -ForegroundColor DarkGray
                continue
            }

            Write-Host "`n==================================================" -ForegroundColor Gray
            Write-Host "Compilando: $($file.Name)" -ForegroundColor Cyan
            Write-Host "Cartella:   $($file.DirectoryName)" -ForegroundColor Gray
            Write-Host "==================================================" -ForegroundColor Gray

            # Entra nella cartella del file per accedere a pacchetti, immagini e stili locali
            Push-Location -LiteralPath $file.DirectoryName

            # 1a Passata: "$null |" impedisce a pdflatex di restare appeso in attesa di input da tastiera
            $null | pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$($file.Name)" *>$null

            if ($LASTEXITCODE -eq 0) {
                # 2a Passata: Risolve Indice (.toc) e Riferimenti Incrociati (\ref, \cref) e genera .synctex.gz
                $null | pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$($file.Name)" *>$null
                Write-Host "OK: Compilazione Di $($file.Name) Eseguita (Indice e SyncTeX aggiornati)." -ForegroundColor Green
            } else {
                Write-Host "ERRORE: Compilazione Di $($file.Name) Fallita." -ForegroundColor Red
                # Assicura la chiusura del processo e rimuove eventuali .synctex(busy) rimasti a metà
                Stop-Process -Name *pdftex*, *latex* -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "*.synctex*(busy)" -Force -ErrorAction SilentlyContinue
            }

            # Ritorna alla posizione precedente
            Pop-Location
        }
    }
}

Write-Host "Processo Completato!" -ForegroundColor Yellow
