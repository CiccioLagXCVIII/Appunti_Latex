# ==============================================================================
# allCompile.ps1 - Compilatore e Pulitore Interattivo LaTeX
# ==============================================================================

# AA CONFIGURAZIONE PERCORSO BASE
$baseDir = ".\"

if (-not (Test-Path -LiteralPath $baseDir)) {
    Write-Host "ERRORE: La cartella '$baseDir' non esiste!" -ForegroundColor Red
    exit
}

# Funzione ausiliaria per rilevare il motore di compilazione adatto (xelatex vs pdflatex)
function Get-LatexEngine {
    param([string]$filePath)
    $engine = "pdflatex"
    try {
        $headLines = Get-Content -LiteralPath $filePath -TotalCount 35 -ErrorAction SilentlyContinue
        if ($headLines -match "(?i)%\s*!TEX\s+(ts-)?program\s*=\s*xelatex" -or
            $headLines -match "\\usepackage(\[.*?\])?\{fontspec\}" -or
            $headLines -match "\\usepackage(\[.*?\])?\{unicode-math\}") {
            $engine = "xelatex"
        } elseif ($headLines -match "(?i)%\s*!TEX\s+(ts-)?program\s*=\s*lualatex") {
            $engine = "lualatex"
        }
    } catch {
        $engine = "pdflatex"
    }
    return $engine
}

# Stack di navigazione per tornare indietro nei sottomenu
$navStack = [System.Collections.Generic.Stack[string]]::new()
$currentPath = (Resolve-Path -LiteralPath $baseDir).Path
$rootPath = $currentPath

$selectedTarget = $null

# AA LOOP DI NAVIGAZIONE INTERATTIVA
while ($null -eq $selectedTarget) {
    $isRoot = ($currentPath -eq $rootPath)

    if ($isRoot) {
        # Menu Livello 1: Cartelle principali e file .tex nella root
        $rootFolders = Get-ChildItem -LiteralPath $currentPath -Directory | Where-Object {
            $_.Name -notmatch "^\." -and $_.Name -ne "node_modules"
        }
        $rootTexFiles = Get-ChildItem -LiteralPath $currentPath -Filter "*.tex" -File | Where-Object {
            Select-String -LiteralPath $_.FullName -Pattern "\\documentclass" -Quiet -ErrorAction SilentlyContinue
        }

        if ($rootFolders.Count -eq 0 -and $rootTexFiles.Count -eq 0) {
            Write-Host "Nessun contenuto compilabile trovato all'interno di '$baseDir'." -ForegroundColor Yellow
            exit
        }

        Write-Host "`n=== SELEZIONA LA CARTELLA DI LAVORO O IL FILE ===" -ForegroundColor Cyan
        $rootOptionMap = @{}
        $rIndex = 1

        for ($i = 0; $i -lt $rootFolders.Count; $i++) {
            Write-Host "[$rIndex] $($rootFolders[$i].Name)"
            $rootOptionMap[$rIndex] = @{ Type = "Dir"; Item = $rootFolders[$i] }
            $rIndex++
        }

        if ($rootTexFiles.Count -gt 0) {
            Write-Host "`n--- File .tex Principali ---" -ForegroundColor Gray
            foreach ($rtf in $rootTexFiles) {
                Write-Host "[$rIndex] [File]     $($rtf.Name)"
                $rootOptionMap[$rIndex] = @{ Type = "File"; Item = $rtf }
                $rIndex++
            }
        }

        Write-Host "`n[A] Tutte Le Cartelle In 02_Appunti_Latex"
        Write-Host "[Q] Esci Dallo Script"

        $choice = (Read-Host "`nInserisci Numero Corrispondente [oppure A o Q]").Trim()

        if ($choice -match '^[Qq]$') {
            Write-Host "Uscita dallo script." -ForegroundColor Gray
            exit
        } elseif ($choice -match '^[Aa]$') {
            $selectedTarget = @{
                Type = "FolderRecursive"
                Path = $currentPath
                DisplayName = "Tutte Le Cartelle In 02_Appunti_Latex"
            }
            break
        } elseif ($choice -match '^\d+$' -and $rootOptionMap.ContainsKey([int]$choice)) {
            $picked = $rootOptionMap[[int]$choice]
            if ($picked.Type -eq "Dir") {
                $navStack.Push($currentPath)
                $currentPath = $picked.Item.FullName
            } elseif ($picked.Type -eq "File") {
                $selectedTarget = @{
                    Type = "SingleFile"
                    Path = $picked.Item.FullName
                    DisplayName = "File: $($picked.Item.Name)"
                    FileObj = $picked.Item
                }
                break
            }
        } else {
            Write-Host "Selezione non valida. Riprova." -ForegroundColor Red
        }
    } else {
        # Menu Livelli Successivi: Drill-Down in sottocartelle e file .tex
        $currentDir = Get-Item -LiteralPath $currentPath
        $relDisplay = (Resolve-Path -LiteralPath $currentPath -Relative).TrimStart(".\")

        # Trova sottocartelle che contengono almeno un file .tex (ricorsivamente)
        $subDirs = Get-ChildItem -LiteralPath $currentPath -Directory | Where-Object {
            $_.Name -notmatch "^\." -and
            $_.Name -ne "node_modules" -and
            $_.Name -notmatch "(?i)(^|_)images?($|_)" -and
            $_.Name -ne "E0_PDF_Compilati" -and
            (Get-ChildItem -LiteralPath $_.FullName -Filter "*.tex" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1)
        }

        # Trova file .tex compilabili (con \documentclass) nella cartella corrente
        $directTexFiles = Get-ChildItem -LiteralPath $currentPath -Filter "*.tex" -File | Where-Object {
            Select-String -LiteralPath $_.FullName -Pattern "\\documentclass" -Quiet -ErrorAction SilentlyContinue
        }

        Write-Host "`nPercorso: $relDisplay" -ForegroundColor DarkCyan
        Write-Host "=== COSA VUOI ELABORARE? ===" -ForegroundColor Cyan
        Write-Host "[A] Tutta La Cartella '$($currentDir.Name)' (Ricorsivo)"

        # Mappa delle opzioni numeriche per questa schermata
        $optionMap = @{}
        $optIndex = 1

        if ($subDirs.Count -gt 0) {
            Write-Host "`n--- Sottocartelle Disponibili ---" -ForegroundColor Gray
            foreach ($sd in $subDirs) {
                Write-Host "[$optIndex] [Cartella] $($sd.Name)"
                $optionMap[$optIndex] = @{ Type = "Dir"; Item = $sd }
                $optIndex++
            }
        }

        if ($directTexFiles.Count -gt 0) {
            Write-Host "`n--- File .tex Compilabili ---" -ForegroundColor Gray
            foreach ($tf in $directTexFiles) {
                Write-Host "[$optIndex] [File]     $($tf.Name)"
                $optionMap[$optIndex] = @{ Type = "File"; Item = $tf }
                $optIndex++
            }
        }

        Write-Host "`n[I] Torna Indietro"
        Write-Host "[Q] Esci Dallo Script"

        $subChoice = (Read-Host "`nInserisci Opzione [A, Numero, I o Q]").Trim()

        if ($subChoice -match '^[Qq]$') {
            Write-Host "Uscita dallo script." -ForegroundColor Gray
            exit
        } elseif ($subChoice -match '^[Ii]$') {
            if ($navStack.Count -gt 0) {
                $currentPath = $navStack.Pop()
            } else {
                $currentPath = $rootPath
            }
        } elseif ($subChoice -match '^[Aa]$') {
            $selectedTarget = @{
                Type = "FolderRecursive"
                Path = $currentPath
                DisplayName = "Cartella: $($currentDir.Name) (Ricorsivo)"
            }
            break
        } elseif ($subChoice -match '^\d+$' -and $optionMap.ContainsKey([int]$subChoice)) {
            $selectedOpt = $optionMap[[int]$subChoice]
            if ($selectedOpt.Type -eq "Dir") {
                # Entra nella sottocartella
                $navStack.Push($currentPath)
                $currentPath = $selectedOpt.Item.FullName
            } elseif ($selectedOpt.Type -eq "File") {
                # Seleziona il singolo file .tex
                $selectedTarget = @{
                    Type = "SingleFile"
                    Path = $selectedOpt.Item.FullName
                    DisplayName = "File: $($selectedOpt.Item.Name)"
                    FileObj = $selectedOpt.Item
                }
                break
            }
        } else {
            Write-Host "Selezione non valida. Riprova." -ForegroundColor Red
        }
    }
}

Write-Host "`nHai Selezionato: $($selectedTarget.DisplayName)" -ForegroundColor Green

# AA SELEZIONE DELL'OPERAZIONE
$actionTitle = if ($selectedTarget.Type -eq "SingleFile") {
    "SELEZIONA L'OPERAZIONE PER QUESTO FILE"
} else {
    "SELEZIONA L'OPERAZIONE DA ESEGUIRE"
}

Write-Host "`n=== $actionTitle ===" -ForegroundColor Cyan
if ($selectedTarget.Type -eq "SingleFile") {
    Write-Host "[1] Cancella I File Ausiliari E Il PDF Di Questo Documento"
    Write-Host "[2] Ricompila Solo Questo File .tex"
    Write-Host "[3] Entrambi (Cancella E Poi Ricompila)"
} else {
    Write-Host "[1] Cancella I PDF E I File Ausiliari Generati Da LaTeX"
    Write-Host "[2] Ricompila Solo I File .tex"
    Write-Host "[3] Entrambi (Cancella E Poi Ricompila)"
}

$actionChoice = (Read-Host "`nInserisci l'opzione [1, 2 o 3]").Trim()

$doClean   = $actionChoice -in @("1", "3")
$doCompile = $actionChoice -in @("2", "3")

if (-not $doClean -and -not $doCompile) {
    Write-Host "Opzione non valida. Uscita dallo script." -ForegroundColor Red
    exit
}

# AA SBLOCCO PREVENTIVO DEI PROCESSI LATEX APPESI
Write-Host "`n--- Terminazione Eventuali Processi LaTeX Appesi In Background... ---" -ForegroundColor DarkYellow
Stop-Process -Name *pdftex*, *xelatex*, *lualatex*, *latex*, *texify*, perl -Force -ErrorAction SilentlyContinue

# Estensioni dei file generati da LaTeX da rimuovere
$targetExtensions = @(
    ".pdf", ".aux", ".log", ".synctex.gz", ".synctex",
    ".synctex(busy)", ".synctex.gz(busy)",
    ".out", ".toc", ".lof", ".lot", ".bbl", ".blg",
    ".fls", ".fdb_latexmk", ".nav", ".snm", ".vrb",
    ".bcf", ".run.xml", ".xdv"
)

# 3. PULIZIA DEI FILE (PDF E AUSILIARI)
if ($doClean) {
    Write-Host "`n--- Ricerca Dei File Generati Da LaTeX In Corso... ---" -ForegroundColor Magenta

    $filesToDelete = @()

    if ($selectedTarget.Type -eq "SingleFile") {
        $singleFile = $selectedTarget.FileObj
        $baseName = $singleFile.BaseName
        $parentDir = $singleFile.DirectoryName

        $candidates = Get-ChildItem -LiteralPath $parentDir -File -ErrorAction SilentlyContinue | Where-Object {
            $f = $_
            if ($f.Name -like "$baseName*.synctex*(busy)") { return $true }
            foreach ($ext in $targetExtensions) {
                if ($f.Name -eq "$baseName$ext") { return $true }
            }
            return $false
        }
        $filesToDelete = @($candidates)
    } else {
        $filesToDelete = Get-ChildItem -LiteralPath $selectedTarget.Path -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
            $file = $_
            if ($file.Name -like "*.synctex*(busy)") {
                return $true
            }
            foreach ($ext in $targetExtensions) {
                if ($file.Name.EndsWith($ext, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $baseName = $file.Name.Substring(0, $file.Name.Length - $ext.Length)
                    $texCounterpart = Join-Path $file.DirectoryName "$baseName.tex"
                    return (Test-Path -LiteralPath $texCounterpart)
                }
            }
            return $false
        }
    }

    if ($filesToDelete.Count -gt 0) {
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
    $files = @()
    if ($selectedTarget.Type -eq "SingleFile") {
        $files = @($selectedTarget.FileObj)
    } else {
        $files = Get-ChildItem -LiteralPath $selectedTarget.Path -Filter "*.tex" -Recurse -File -ErrorAction SilentlyContinue
    }

    if ($files.Count -eq 0) {
        Write-Host "Nessun File .tex Trovato Nel Percorso Selezionato." -ForegroundColor Gray
    } else {
        Write-Host "`nTrovati $($files.Count) File .tex Da Analizzare..." -ForegroundColor Yellow

        foreach ($file in $files) {
            # Salta i file .tex che sono solo frammenti (privi di \documentclass) per evitare blocchi
            $hasDocClass = Select-String -LiteralPath $file.FullName -Pattern "\\documentclass" -Quiet -ErrorAction SilentlyContinue
            if (-not $hasDocClass) {
                Write-Host "`n[SALTATO] $($file.Name) (Frammento privo di \documentclass)" -ForegroundColor DarkGray
                continue
            }

            # Rilevamento automatico dell'engine LaTeX appropriato
            $engine = Get-LatexEngine -filePath $file.FullName

            Write-Host "`n==================================================" -ForegroundColor Gray
            Write-Host "Compilando: $($file.Name) [Motore: $engine]" -ForegroundColor Cyan
            Write-Host "Cartella:   $($file.DirectoryName)" -ForegroundColor Gray
            Write-Host "==================================================" -ForegroundColor Gray

            # Entra nella cartella del file per accedere a pacchetti, immagini e stili locali
            Push-Location -LiteralPath $file.DirectoryName

            # 1a Passata: "$null |" impedisce di restare appesi in attesa di input da tastiera
            $null | & $engine -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$($file.Name)" *>$null

            if ($LASTEXITCODE -eq 0) {
                # 2a Passata: Risolve Indice (.toc) e Riferimenti Incrociati (\ref, \cref) e genera .synctex.gz
                $null | & $engine -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error "$($file.Name)" *>$null
                Write-Host "OK: Compilazione Di $($file.Name) Eseguita ($engine - Indice e SyncTeX aggiornati)." -ForegroundColor Green
            } else {
                Write-Host "ERRORE: Compilazione Di $($file.Name) Fallita ($engine)." -ForegroundColor Red
                # Assicura la chiusura del processo e rimuove eventuali .synctex(busy) rimasti a metà
                Stop-Process -Name *pdftex*, *xelatex*, *lualatex*, *latex* -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "*.synctex*(busy)" -Force -ErrorAction SilentlyContinue
            }

            # Ritorna alla posizione precedente
            Pop-Location
        }
    }
}

Write-Host "`nProcesso Completato!" -ForegroundColor Yellow
