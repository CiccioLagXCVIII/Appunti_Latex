function [T_matrices, R_matrices] = Compute_DH_Transformations(DH_table)
    % COMPUTE_DH_TRANSFORMATIONS Calcola le matrici di trasformazione omogenea e rotazione
    % per una tabella dei parametri Denavit-Hartenberg.
    %
    % Input:
    %   DH_table: Matrice (n x 4) contenente i parametri DH per ogni giunto.
    %             Le colonne rappresentano [theta, d, alpha, a].
    %
    % Output:
    %   T_matrices: Array 3D (4x4xn) contenente le matrici di trasformazione omogenea.
    %   R_matrices: Array 3D (3x3xn) contenente le matrici di rotazione estratte da T_matrices.

    % Determinazione del numero di giunti
    n = size(DH_table, 1);

    % Inizializzazione delle matrici di trasformazione e rotazione
    T_matrices = sym(zeros(4, 4, n));
    R_matrices = sym(zeros(3, 3, n));

    % Ciclo per calcolare le matrici di trasformazione e rotazione per ogni giunto
    for i = 1:n
        % Estrazione dei parametri DH per il giunto corrente
        theta = DH_table(i, 1);
        d = DH_table(i, 2);
        alpha = DH_table(i, 3);
        a = DH_table(i, 4);

        % Calcolo della matrice di trasformazione omogenea 4x4
        T_matrices(:,:,i) = [
            cos(theta), -sin(theta)*cos(alpha), sin(theta)*sin(alpha), a*cos(theta);
            sin(theta), cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
            0, sin(alpha), cos(alpha), d;
            0, 0, 0, 1
        ];

        % Estrazione della matrice di rotazione 3x3 dalla matrice di trasformazione omogenea
        R_matrices(:,:,i) = T_matrices(1:3, 1:3, i);
    end
end