function updateStructure(filtroNomi)
% UPDATESTRUCTURE Rigenera i Live Script (.mlx), esporta le figure a 300 DPI
% e aggiorna le cartelle E*_Images in "Esercitazioni Matlab" tracciando ogni
% operazione in tempo reale su "Codici Matlab\logEsecuzione.txt".
%
% Uso:
%   updateStructure()                  % Elabora tutti i 15 script E*.m
%   updateStructure({'E4', 'E8'})      % Elabora solo gli script filtrati
%   updateStructure('E5')              % Elabora un singolo prefisso

    if nargin < 1 || isempty(filtroNomi)
        filtroNomi = {};
    elseif ischar(filtroNomi) || isstring(filtroNomi)
        filtroNomi = cellstr(filtroNomi);
    end

    % Individuazione cartella radice "Codici Matlab"
    rootDir = fileparts(mfilename('fullpath'));
    if isempty(rootDir)
        rootDir = pwd;
    end
    [~, currFolderName] = fileparts(rootDir);
    if strcmpi(currFolderName, 'Script Aggiornati') || strcmpi(currFolderName, 'Notebook Aggiornati')
        rootDir = fileparts(rootDir);
    end

    industrialDir    = fileparts(rootDir);
    scriptDir        = fullfile(rootDir, 'Script Aggiornati');
    notebookDir      = fullfile(rootDir, 'Notebook Aggiornati');
    imgOutDir        = fullfile(rootDir, 'Immagini Script Aggiornate');
    esercitazioniDir = fullfile(industrialDir, 'Esercitazioni Matlab');
    logFile          = fullfile(rootDir, 'logEsecuzione.txt');

    if ~isfolder(scriptDir)
        error('Cartella "Script Aggiornati" non trovata in: %s', rootDir);
    end
    if ~isfolder(notebookDir), mkdir(notebookDir); end
    if ~isfolder(imgOutDir),   mkdir(imgOutDir);   end

    % Salvataggio stato corrente e chiusura preventiva editor/figure
    origDir = pwd;
    cleanupObj = onCleanup(@() RipristinaStato(origDir)); %#ok<NASGU>
    addpath(scriptDir);

    allDocs = matlab.desktop.editor.getAll;
    if ~isempty(allDocs)
        allDocs.close();
    end
    close all force;

    % Selezione e ordinamento dei file E*.m in "Script Aggiornati"
    files = dir(fullfile(scriptDir, 'E*.m'));
    if ~isempty(files)
        [~, idxSort] = sort({files.name});
        files = files(idxSort);
    end

    if ~isempty(filtroNomi)
        keep = false(numel(files), 1);
        for f = 1:numel(files)
            for p = 1:numel(filtroNomi)
                if startsWith(files(f).name, filtroNomi{p}, 'IgnoreCase', true)
                    keep(f) = true;
                    break;
                end
            end
        end
        files = files(keep);
    end

    % 1. PULIZIA INIZIALE (globale se senza filtro, mirata se con filtro)
    if isempty(filtroNomi)
        SvuotaCartella(imgOutDir);
        mlxOld = dir(fullfile(notebookDir, '*.mlx'));
        for m = 1:numel(mlxOld)
            delete(fullfile(notebookDir, mlxOld(m).name));
        end
    else
        for f = 1:numel(files)
            [~, bName, ~] = fileparts(files(f).name);
            [prefTmp, ~] = GetInfoEsercitazione(bName, esercitazioniDir);
            stageTmp = fullfile(imgOutDir, [prefTmp, '_Images']);
            if isfolder(stageTmp)
                rmdir(stageTmp, 's');
            end
            oldMlx = fullfile(notebookDir, [bName, '.mlx']);
            if isfile(oldMlx)
                delete(oldMlx);
            end
        end
    end

    % Ricopia subito le funzioni ausiliarie in "Notebook Aggiornati"
    helpers = {'Compute_DH_Transformations.m', 'Compute_Rotation_Matrix.m'};
    for h = 1:numel(helpers)
        srcH = fullfile(scriptDir, helpers{h});
        dstH = fullfile(notebookDir, helpers{h});
        if isfile(srcH)
            copyfile(srcH, dstH, 'f');
        end
    end

    % Inizializza/sovrascrive il file di log in UTF-8
    InizializzaLog(logFile, filtroNomi);

    nFiles = numel(files);
    if nFiles == 0
        ScriviLog(logFile, 'Nessun file E*.m trovato corrispondente al filtro specificato.');
        return;
    end

    % 2. CICLO PRINCIPALE SUGLI SCRIPT E*.m
    for k = 1:nFiles
        [~, baseName, ~] = fileparts(files(k).name);
        srcM    = fullfile(scriptDir, files(k).name);
        tempMlx = fullfile(rootDir, [baseName, '.mlx']);
        destMlx = fullfile(notebookDir, [baseName, '.mlx']);

        [prefix, cartellaEsercitazione] = GetInfoEsercitazione(baseName, esercitazioniDir);
        imgFolderName = [prefix, '_Images'];
        stageImgDir   = fullfile(imgOutDir, imgFolderName);
        targetExDir   = fullfile(esercitazioniDir, cartellaEsercitazione);
        targetImgDir  = fullfile(targetExDir, imgFolderName);

        if k > 1
            ScriviLog(logFile, '');
        end
        ScriviLog(logFile, baseName);

        % --- Passo 1: Apertura (verifica esistenza e leggibilita del .m) ---
        try
            if ~isfile(srcM)
                error('File non trovato: %s', srcM);
            end
            fidCheck = fopen(srcM, 'r', 'n', 'UTF-8');
            if fidCheck == -1
                error('Impossibile aprire in lettura: %s', srcM);
            end
            fclose(fidCheck);
            ScriviLog(logFile, '1. Apertura OK');
        catch ME
            ScriviLog(logFile, sprintf('1. Apertura ERRORE: %s', ME.message));
            continue;
        end

        % --- Passo 2: Cancellazione Output Vecchi ---
        try
            openDocs = matlab.desktop.editor.getAll;
            if ~isempty(openDocs)
                openDocs.close();
            end
            close all force;
            if isfile(tempMlx)
                delete(tempMlx);
            end
            if isfile(destMlx)
                delete(destMlx);
            end
            ScriviLog(logFile, '2. Cancellazione Output OK');
        catch ME
            ScriviLog(logFile, sprintf('2. Cancellazione Output ERRORE: %s', ME.message));
            continue;
        end

        % --- Passo 3: Esecuzione Script in Modalita Invisibile ---
        execOK = false;
        set(0, 'DefaultFigureVisible', 'off');
        try
            cd(scriptDir);
            evalin('base', sprintf('%s;', baseName));
            execOK = true;
        catch ME
            execErrMsg = ME.message;
        end
        set(0, 'DefaultFigureVisible', 'on');

        if execOK
            ScriviLog(logFile, '3. Esecuzione: OK');
        else
            ScriviLog(logFile, sprintf('3. Esecuzione: ERRORE - %s', execErrMsg));
            close all force;
            continue;
        end

        % --- Passo 4: Creazione Cartella <Prefisso>_Images ---
        figs = TrovaFigureValide();
        hasFigures = ~isempty(figs);

        if ~hasFigures
            ScriviLog(logFile, sprintf('4. Creazione Cartella %s N/A (Nessuna figura prevista)', imgFolderName));
        else
            try
                if isfolder(stageImgDir)
                    SvuotaCartella(stageImgDir);
                else
                    mkdir(stageImgDir);
                end
                ScriviLog(logFile, sprintf('4. Creazione Cartella %s OK', imgFolderName));
            catch ME
                ScriviLog(logFile, sprintf('4. Creazione Cartella %s ERRORE: %s', imgFolderName, ME.message));
                close all force;
                continue;
            end

            % --- Passo 5: Esportazione Immagini a 300 DPI ---
            try
                [~, ord] = sort([figs.Number]);
                figs = figs(ord);
                nFigs = numel(figs);

                for j = 1:nFigs
                    if nFigs == 1
                        imgName = sprintf('%s.png', baseName);
                    else
                        imgName = sprintf('%s_fig%d.png', baseName, j);
                    end
                    imgPath = fullfile(stageImgDir, imgName);
                    exportgraphics(figs(j), imgPath, 'Resolution', 300);
                end
                close all force;
                ScriviLog(logFile, sprintf('5. Esportazione Immagini In %s OK', imgFolderName));
            catch ME
                close all force;
                ScriviLog(logFile, sprintf('5. Esportazione Immagini In %s ERRORE: %s', imgFolderName, ME.message));
                continue;
            end

            % --- Passo 6: Sostituzione Cartella <Prefisso>_Images in Esercitazioni Matlab ---
            try
                if ~isfolder(targetExDir)
                    error('Cartella esercitazione non trovata: %s', targetExDir);
                end

                % Preserva eventuali schemi teorici statici (image_* oppure figure_2.png in E9)
                if isfolder(targetImgDir)
                    oldItems = dir(targetImgDir);
                    for idxItem = 1:numel(oldItems)
                        if oldItems(idxItem).isdir
                            continue;
                        end
                        fName = oldItems(idxItem).name;
                        isStaticImage = startsWith(fName, 'image_', 'IgnoreCase', true) || ...
                            (strcmpi(prefix, 'E9') && strcmpi(fName, 'figure_2.png'));

                        if isStaticImage
                            srcStatic = fullfile(targetImgDir, fName);
                            dstStatic = fullfile(stageImgDir, fName);
                            copyfile(srcStatic, dstStatic, 'f');
                            if ~isfile(dstStatic)
                                error('Copia schema statico fallita per: %s', fName);
                            end
                        end
                    end

                    % Rimuove la vecchia cartella <Prefisso>_Images (eliminando figure_0/1 obsolete)
                    [okRm, msgRm] = rmdir(targetImgDir, 's');
                    if ~okRm
                        pause(0.2);
                        [okRm, msgRm] = rmdir(targetImgDir, 's');
                        if ~okRm
                            error('Impossibile rimuovere %s: %s', targetImgDir, msgRm);
                        end
                    end
                end

                % Sposta la nuova cartella <Prefisso>_Images al posto della vecchia
                [okMv, msgMv] = movefile(stageImgDir, targetImgDir, 'f');
                if ~okMv
                    pause(0.2);
                    [okMv, msgMv] = movefile(stageImgDir, targetImgDir, 'f');
                    if ~okMv
                        error('Impossibile spostare %s in %s: %s', stageImgDir, targetImgDir, msgMv);
                    end
                end

                ScriviLog(logFile, sprintf('6. Sostituzione Cartella %s In "Esercitazioni Matlab\\%s" OK', ...
                    imgFolderName, cartellaEsercitazione));
            catch ME
                ScriviLog(logFile, sprintf('6. Sostituzione Cartella %s In "Esercitazioni Matlab\\%s" ERRORE: %s', ...
                    imgFolderName, cartellaEsercitazione, ME.message));
                continue;
            end
        end

        % --- Passo 7: Conversione in .mlx ed Esecuzione con Salvataggio Output ---
        try
            doc = matlab.desktop.editor.openDocument(srcM);
            doc.saveAs(tempMlx);
            doc.close();

            matlab.internal.liveeditor.executeAndSave(tempMlx);

            openDocs = matlab.desktop.editor.getAll;
            if ~isempty(openDocs)
                openDocs.close();
            end
            close all force;
            ScriviLog(logFile, '7. Conversione In .mlx OK');
        catch ME
            openDocs = matlab.desktop.editor.getAll;
            if ~isempty(openDocs)
                openDocs.close();
            end
            close all force;
            ScriviLog(logFile, sprintf('7. Conversione In .mlx ERRORE: %s', ME.message));
            continue;
        end

        % --- Passo 8: Spostamento del .mlx in "Notebook Aggiornati" ---
        try
            [okMvMlx, msgMvMlx] = movefile(tempMlx, destMlx, 'f');
            if ~okMvMlx
                pause(0.2);
                [okMvMlx, msgMvMlx] = movefile(tempMlx, destMlx, 'f');
                if ~okMvMlx
                    error('Impossibile spostare %s in %s: %s', tempMlx, destMlx, msgMvMlx);
                end
            end
            ScriviLog(logFile, '8. Spostamento In Notebook Aggiornati OK');
        catch ME
            ScriviLog(logFile, sprintf('8. Spostamento In Notebook Aggiornati ERRORE: %s', ME.message));
            continue;
        end
    end

    fprintf('\n====================================================================\n');
    fprintf(' Elaborazione completata (%d script). Log salvato in:\n %s\n', nFiles, logFile);
    fprintf('====================================================================\n');
end

% =========================================================================
% FUNZIONI AUSILIARIE LOCALI
% =========================================================================

function InizializzaLog(logFile, filtroNomi)
    fid = fopen(logFile, 'w', 'n', 'UTF-8');
    if fid == -1
        error('Impossibile inizializzare il file di log: %s', logFile);
    end
    ts = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    fprintf(fid, '====================================================================\n');
    fprintf(fid, ' LOG ESECUZIONE updateStructure - %s\n', ts);
    if ~isempty(filtroNomi)
        fprintf(fid, ' Filtro: %s\n', strjoin(filtroNomi, ', '));
    else
        fprintf(fid, ' Modalita: Completa (Tutti gli script E*.m)\n');
    end
    fprintf(fid, '====================================================================\n\n');
    fclose(fid);
end

function ScriviLog(logFile, riga)
    fid = fopen(logFile, 'a', 'n', 'UTF-8');
    if fid ~= -1
        fprintf(fid, '%s\n', riga);
        fclose(fid);
    end
    fprintf('%s\n', riga);
end

function SvuotaCartella(dirPath)
    if ~isfolder(dirPath)
        mkdir(dirPath);
        return;
    end
    items = dir(dirPath);
    for i = 1:numel(items)
        nm = items(i).name;
        if strcmp(nm, '.') || strcmp(nm, '..')
            continue;
        end
        fullP = fullfile(dirPath, nm);
        if items(i).isdir
            rmdir(fullP, 's');
        else
            delete(fullP);
        end
    end
end

function figs = TrovaFigureValide()
    rawFigs = findall(0, 'Type', 'figure');
    if isempty(rawFigs)
        figs = rawFigs;
        return;
    end
    keep = false(numel(rawFigs), 1);
    for i = 1:numel(rawFigs)
        keep(i) = ~isempty(rawFigs(i).Number) && isnumeric(rawFigs(i).Number);
    end
    figs = rawFigs(keep);
end

function [prefix, cartellaEsercitazione] = GetInfoEsercitazione(baseName, esercitazioniDir)
    switch baseName
        case 'E1_RappresentazioneAsseAngolo'
            prefix = 'E1';
            defaultFolder = 'E1_RappresentazioneAsseAngolo';
        case 'E2_Angoli_Eulero'
            prefix = 'E2';
            defaultFolder = 'E2_Angoli_Eulero';
        case 'E3_1_CinematicaDirettaManipolatoreSfericoTipoI'
            prefix = 'E3_1';
            defaultFolder = 'E3_1_CinematicaDirettaManipolatoreSfericoTipoI';
        case 'E3_2_CinematicaDirettaManipolatoreSCARA'
            prefix = 'E3_2';
            defaultFolder = 'E3_2_CinematicaDirettaManipolatoreSCARA';
        case 'E3_3_CinematicaDirettaManipolatoreAntropomorfo'
            prefix = 'E3_3';
            defaultFolder = 'E3_3_CinematicaDirettaManipolatoreAntropomorfo';
        case 'E3_4_CinematicaDirettaManipolatoreSfericoTipoII'
            prefix = 'E3_4';
            defaultFolder = 'E3_4_CinematicaDirettaManipolatoreSfericoTipoII';
        case 'E3_5_CinematicaDirettaPolsoSferico'
            prefix = 'E3_5';
            defaultFolder = 'E3_5_CinematicaDirettaPolsoSferico';
        case 'E3_6_1_CinematicaDirettaManipolatoreStanford'
            prefix = 'E3_6_1';
            defaultFolder = 'E3_6_1_CinematicaDirettaManipolatoreStanford';
        case 'E3_6_2_1_DisaccoppiamentoPolsoStrutturaPortante'
            prefix = 'E3_6_2';
            defaultFolder = 'E3_6_2_DisaccoppiamentoPolsoStrutturaPortante';
        case 'E4_CinematicaInversaSpaziOperativiManipolatoreRRR'
            prefix = 'E4';
            defaultFolder = 'E4_CinematicaInversaSpaziOperativiManipolatoreRRR';
        case 'E5_CinematicaInversaManipolatoreStanford'
            prefix = 'E5';
            defaultFolder = 'E5_CinematicaInversaManipolatoreStanford';
        case 'E6_RelazioneVettoreVelocitaAngoliEulero'
            prefix = 'E6';
            defaultFolder = 'E6_RelazioneVettoreVelocitaAngoliEulero';
        case 'E7_CodiceCalcoloJacobianoGeometrico'
            prefix = 'E7';
            defaultFolder = 'E7_CodiceCalcoloJacobianoGeometrico';
        case {'E8_AnalisiMobilitaRRRPlanare', 'E8_AnalisiMobilitàRRRPlanare'}
            prefix = 'E8';
            defaultFolder = 'E8_AnalisiMobilitàRRRPlanare';
        case 'E9_AlgoritmoNewtonEGradiente'
            prefix = 'E9';
            defaultFolder = 'E9_AlgoritmoNewtonEGradiente';
        otherwise
            tok = regexp(baseName, '^(E\d+(?:_\d+)*)', 'tokens', 'once');
            if ~isempty(tok)
                prefix = tok{1};
            else
                prefix = baseName;
            end
            defaultFolder = baseName;
    end

    % Risoluzione dinamica su filesystem per gestire eventuali accenti nel nome cartella
    cartellaEsercitazione = defaultFolder;
    if isfolder(esercitazioniDir) && ~isfolder(fullfile(esercitazioniDir, cartellaEsercitazione))
        cand = dir(fullfile(esercitazioniDir, [prefix, '_*']));
        cand = cand([cand.isdir]);
        if ~isempty(cand)
            cartellaEsercitazione = cand(1).name;
        end
    end
end

function RipristinaStato(origDir)
    set(0, 'DefaultFigureVisible', 'on');
    if isfolder(origDir)
        cd(origDir);
    end
end

