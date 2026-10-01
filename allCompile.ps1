
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
    $selectedPath = $baseDir
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
Write-Host "[1] Cancella Solo I PDF Generati Da LaTeX"
Write-Host "[2] Ricompila Solo I File .tex"
Write-Host "[3] Entrambi (Cancella E Poi Ricompila)"

$actionChoice = Read-Host "`nInserisci l'opzione [1, 2 o 3]"

$doClean   = $actionChoice -in @("1", "3")
$doCompile = $actionChoice -in @("2", "3")

if (-not $doClean -and -not $doCompile) {
    Write-Host "Opzione non valida. Uscita dallo script." -ForegroundColor Red
    exit
}

# 3. PULIZIA DEI FILE PDF GENERATI DA .TEX
if ($doClean) {
    Write-Host "`n--- Ricerca Dei PDF Generati Da LaTeX In Corso... ---" -ForegroundColor Magenta

    # Cerca tutti i .pdf e filtra solo quelli che hanno un .tex corrispondente nella stessa cartella
    $pdfsToDelete = Get-ChildItem -Path $selectedPath -Filter "*.pdf" -Recurse | Where-Object {
        $texCounterpart = Join-Path $_.DirectoryName "$($_.BaseName).tex"
        Test-Path $texCounterpart
    }

    if ($pdfsToDelete) {
        Write-Host "Trovati $($pdfsToDelete.Count) PDF Generati Da .tex. Eliminazione In Corso..." -ForegroundColor Magenta
        foreach ($pdf in $pdfsToDelete) {
            Remove-Item -Path $pdf.FullName -Force
            Write-Host "  Rimosso: $($pdf.Name)" -ForegroundColor DarkGray
        }
        Write-Host "Pulizia Completata Con Successo!`n" -ForegroundColor Green
    } else {
        Write-Host "Nessun PDF Generato Da .tex Trovato Da Rimuovere.`n" -ForegroundColor Gray
    }
}

# 4. COMPILAZIONE DEI FILE .TEX
if ($doCompile) {
    $files = Get-ChildItem -Path $selectedPath -Filter "*.tex" -Recurse

    if ($files.Count -eq 0) {
        Write-Host "Nessun File .tex Trovato Nel Percorso Selezionato." -ForegroundColor Gray
    } else {
        Write-Host "`nTrovati $($files.Count) File .tex Da Compilare..." -ForegroundColor Yellow

        foreach ($file in $files) {
            Write-Host "`n==================================================" -ForegroundColor Gray
            Write-Host "Compilando: $($file.Name)" -ForegroundColor Cyan
            Write-Host "Cartella:   $($file.DirectoryName)" -ForegroundColor Gray
            Write-Host "==================================================" -ForegroundColor Gray

            # Entra nella cartella del file per accedere a pacchetti, immagini e stili locali
            Push-Location $file.DirectoryName

            # Esegue XeLaTeX in modalità silenziosa
            xelatex -synctex=1 -interaction=nonstopmode -file-line-error "$($file.Name)" *>$null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "OK: Compilazione Di $($file.Name) Eseguita." -ForegroundColor Green
            } else {
                Write-Host "ERRORE: Compilazione Di $($file.Name) Fallita." -ForegroundColor Red
            }

            # Ritorna alla posizione precedente
            Pop-Location
        }
    }
}

Write-Host "`nProcesso Completato!" -ForegroundColor Yellow
