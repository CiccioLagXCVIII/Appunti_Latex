function exportNotebooks()
% Esporta tutti i file .mlx di "Notebook Aggiornati" in Markdown dentro
% "Notebook Aggiornati/Notebook Markdown", rieseguendoli da zero.
%
% REQUISITI:
% - MATLAB R2023b o successivo (per l'export in Markdown)
% - Eseguire dalla cartella radice (quella che contiene "Notebook Aggiornati")
% - Lanciare dall'Editor (.m) o dalla Command Window, NON da un Live Script (.mlx)

origDir = pwd;
cleanupObj = onCleanup(@() cd(origDir)); % Ripristina sempre la cartella iniziale

inputDir  = fullfile(origDir, "Notebook Aggiornati");
outputDir = fullfile(inputDir, "Notebook Markdown");

if ~isfolder(inputDir)
    error("Cartella non trovata: %s. Lancia lo script dalla cartella radice.", inputDir);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

mlxFiles = dir(fullfile(inputDir, "*.mlx"));
if isempty(mlxFiles)
    fprintf("Nessun file .mlx trovato in: %s\n", inputDir);
    return;
end

fprintf("Trovati %d file .mlx. Avvio riesecuzione ed export...\n\n", numel(mlxFiles));

for k = 1:numel(mlxFiles)
    [~, baseName] = fileparts(mlxFiles(k).name);
    mlxPath = fullfile(mlxFiles(k).folder, mlxFiles(k).name);
    mdPath  = fullfile(outputDir, baseName + ".md");

    fprintf("[%d/%d] Elaborazione: %s\n", k, numel(mlxFiles), mlxFiles(k).name);

    try
        % Chiude eventuali figure lasciate aperte dal notebook precedente
        close all;

        % Se vuoi azzerare anche il workspace base tra un notebook e l'altro,
        % decommenta la riga seguente:
        % evalin('base', 'clear');

        % Se i notebook usano percorsi relativi rispetto a "Notebook Aggiornati"
        % invece che alla cartella radice, decommenta la riga seguente:
        % cd(inputDir);

        % Run=true ignora i vecchi output nel .mlx e riesegue il codice da zero.
        % EmbedImages=false salva i grafici come PNG in una cartella *_media/.
        export(mlxPath, mdPath, ...
            Format="markdown", ...
            Run=true, ...
            IncludeOutputs=true, ...
            EmbedImages=false, ...
            CatchError=true);

        fprintf("   -> Creato: %s\n", mdPath);
    catch ME
        warning("Errore durante l'elaborazione di %s:\n%s", mlxFiles(k).name, ME.message);
    end

    % Ripristina la cartella radice nel caso il notebook abbia usato cd()
    cd(origDir);
end

close all;
fprintf("\nEsportazione completata!\n");
end