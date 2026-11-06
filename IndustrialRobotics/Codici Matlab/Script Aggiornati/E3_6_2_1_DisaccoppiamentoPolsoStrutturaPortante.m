%[text] # Disaccoppiamento Polso - Struttura Portante
%%
%[text] ## CINEMATICA DIRETTA MANIPOLATORE SFERICO
%[text]{"align":"center"} ![Disaccoppiamento Cinematica Diretta 1](../../Esercitazioni Matlab/E3_6_2_DisaccoppiamentoPolsoStrutturaPortante/E3_6_2_Images/image_0.jpeg)
% Risoluzione percorso cartella funzioni ausiliarie Codici Matlab
if ~exist('Compute_DH_Transformations', 'file') || ~exist('Compute_Rotation_Matrix', 'file')
    candDirs = {pwd, fileparts(pwd)};
    try
        edFile = matlab.desktop.editor.getActiveFilename;
        candDirs = [candDirs, {fileparts(edFile), fileparts(fileparts(edFile))}];
    catch
    end
    for iCand = 1:numel(candDirs)
        cDir = candDirs{iCand};
        if isfolder(cDir) && (isfile(fullfile(cDir, 'Compute_DH_Transformations.m')) || isfile(fullfile(cDir, 'Compute_Rotation_Matrix.m')))
            addpath(cDir);
            break;
        end
    end
end
clc; clear; close all;
% Definizione Variabili Simboliche
syms q1 q2 q3 d1 d2 d3 alpha1 alpha2 alpha3 a1 a2 a3 real;

DH_table_Strut = [q1, 0, -pi/2, 0;
                  q2, d2, pi/2, 0;
                  0, q3, 0, 0];


% Numero Giunti Manipolatore
n = size(DH_table_Strut, 1);

% Calcolo Matrici Trasformazione Struttura
[T_matrices_Strut, R_matrices_Polso] = Compute_DH_Transformations(DH_table_Strut);
% Visualizzazione Matrici Trasformazione Struttura
j = 0;
for i = 1:n
    fprintf('Matrice Di Trasformazione Omogenea ^{%d}T_(%d):\n', j, j+1);
    disp(T_matrices_Strut(:,:,i));
    j = j+1;
end
% Calcolo Matrice Di Trasformazione Totale Dalla Base All'End Effector
T03 = T_matrices_Strut(:,:,1) * T_matrices_Strut(:,:,2) * T_matrices_Strut(:,:,3);
T03 = simplify(T03);

fprintf('Matrice Di Trasformazione Omogenea ^(0)T_(3):\n');

disp(T03);
%[text]{"align":"center"} $^{0}\\mathbf{T}_{3}(\\mathbf{q}) \\; = \\; ^{0}\\mathbf{A}_{1}(q_{1}) \\; \\cdot \\; ^{1}\\mathbf{A}_{2}(q_{2}) \\; \\cdot \\; ^{2}\\mathbf{A}_{3}(q_{3}) =$
%[text]{"align":"center"} $= \\begin{pmatrix} c(q_{1})c(q_{2}) & -s(q_{1}) & c(q_{1})s(q_{2}) & c(q_{1})s(q_{2})q_{3} - s(q_{1})d_{2} \\\\ s(q_{1})c(q_{2}) & c(q_{1}) & s(q_{1})s(q_{2}) & s(q_{1})s(q_{2})q_{3} + c(q_{1})d_{2}\\\\ -s(q_{2}) & 0 & c(q_{2}) & c(q_{2})q_{3}\\\\ 0 & 0 & 0 & 1 \\end{pmatrix}$
%%
%[text] ## CINEMATICA DIRETTA POLSO SFERICO
%[text]{"align":"center"} ![Disaccoppiamento Cinematica Diretta 2](../../Esercitazioni Matlab/E3_6_2_DisaccoppiamentoPolsoStrutturaPortante/E3_6_2_Images/image_1.jpeg)
% Definizione Variabili Simboliche
syms q4 q5 q6 d4 d5 d6 alpha4 alpha5 alpha6 a4 a5 a6 real;

% Tabella Parametri Denavit-Hartenberg (DH)
DH_table_Polso = [q4, 0, -pi/2, 0;
                  q5, 0, pi/2, 0;
                  q6, d6, 0, 0];


% Numero Giunti Manipolatore
n = size(DH_table_Polso, 1);

% Calcolo Matrici Trasformazione Polso
[T_matrices_Polso, R_matrices_Polso] = Compute_DH_Transformations(DH_table_Polso);

% Visualizzazione Matrici Trasformazione Polso
j = 3;
for i = 1:n
    fprintf('Matrice Di Trasformazione Omogenea ^(%d)A_(%d):\n', j, j+1);
    disp(T_matrices_Polso(:,:,i));

    j = j+1;
end
T36 = T_matrices_Polso(:,:,1) * T_matrices_Polso(:,:,2) * T_matrices_Polso(:,:,3);
T36 = simplify(T36);

fprintf('Matrice Di Trasformazione Omogenea ^{3}T_(6):\n');

disp(T36);
%[text]{"align":"center"} $^{3}\\mathbf{T}_{6}(\\mathbf{q}) \\; = \\; ^{3}\\mathbf{A}_{4}(q_{4}) \\; \\cdot \\; ^{4}\\mathbf{A}_{5}(q_{5}) \\; \\cdot \\; ^{5}\\mathbf{A}_{6}(q_{6}) =$
%[text]{"align":"center"} $= \\begin{pmatrix} c(q_{4})c(q_{5})c(q_{6}) - s(q_{4})s(q_{6}) & -c(q_{6})s(q_{4}) - c(q_{4})c(q_{5})s(q_{6}) & c(q_{4})s(q_{5}) & c(q_{4})s(q_{5})d_{6} \\\\ c(q_{4})s(q_{6}) + c(q_{5})c(q_{6})s(q_{4}) & c(q_{4})c(q_{6}) - c(q_{5})s(q_{4})s(q_{6}) & s(q_{4})s(q_{5}) & s(q_{4})s(q_{5})d_{6} \\\\ -c(q_{6})s(q_{5}) & s(q_{5})s(q_{6}) & c(q_{5}) & c(q_{5})d_{6} \\\\ 0 & 0 & 0 & 1 \\end{pmatrix}$
%%
%[text] ## Cinematica Diretta Manipolatore Stanford
T06 = simplify(T03 * T36);
fprintf('Matrice Di Trasformazione Omogenea ^{0}T_{6}:\n');
disp(T06);
%%
%[text] ## VERIFICA CONDIZIONE DI DISACCOPPIAMENTO
%[text]{"align":"center"} $\\exists \\;{\\mathbf{d}}_0 ,\\,{\\mathbf{d}}_1 \\in {\\mathbb{R}}^3 \\;\\;\\mid \\;\\;^3 {\\mathbf{d}}_6 =^3 {\\mathbf{R}}_6 {\\mathbf{d}}_1 +{\\mathbf{d}}_0$
% Estrazione Vettore Posizione
d36 = T36(1:3, 4);
d36 = simplify(d36);
fprintf('Vettore Posizione d_{36}:\n');

disp(d36);
%%
%[text] ## CINEMATICA INVERSA POSIZIONE
%[text]{"align":"center"} $^0 {\\mathbf{d}}_6 =^0 {\\mathbf{R}}_3 \\,^3 {\\mathbf{d}}_6 +^0 {\\mathbf{d}}_3$
% Estrazione Vettore Posizione
d03 = T03(1:3, 4);
d03 = simplify(d03);
fprintf('Vettore Posizione d_{03}:\n');

disp(d03);
%%
%[text] ## CINEMATICA INVERSA ORIENTAMENTO
%[text]{"align":"center"} ${}^{0}\\mathbf{R}_6 = {}^{0}\\mathbf{R}_3 \\cdot {}^{3}\\mathbf{R}_{6}$
% Matrice Di Rotazione R06
% T06 calcolato precedentemente nella sezione Cinematica Diretta Manipolatore Stanford
R06 = T06(1:3, 1:3);
R06 = simplify(R06);

% Matrice Di Rotazione R03 Trasposta
R03 = T03(1:3, 1:3);
R03 = simplify(R03);
R03_T = transpose(R03);

% Matrice Di Rotazione R36 Calcolata
R36 = R03_T * R06;
R36 = simplify(R36);
fprintf('Matrice Di Rotazione R36 = (R03)^{T} R06 =:\n');
disp(R36);
%[text]{"align":"center"} $\\begin{pmatrix} \\cos \\left(q_4 \\right)\\,\\cos \\left(q_5 \\right)\\,\\cos \\left(q_6 \\right)-\\sin \\left(q_4 \\right)\\,\\sin \\left(q_6 \\right) & -\\cos \\left(q_6 \\right)\\,\\sin \\left(q_4 \\right)-\\cos \\left(q_4 \\right)\\,\\cos \\left(q_5 \\right)\\,\\sin \\left(q_6 \\right) & \\cos \\left(q_4 \\right)\\,\\sin \\left(q_5 \\right)\\\\ \\cos \\left(q_4 \\right)\\,\\sin \\left(q_6 \\right)+\\cos \\left(q_5 \\right)\\,\\cos \\left(q_6 \\right)\\,\\sin \\left(q_4 \\right) & \\cos \\left(q_4 \\right)\\,\\cos \\left(q_6 \\right)-\\cos \\left(q_5 \\right)\\,\\sin \\left(q_4 \\right)\\,\\sin \\left(q_6 \\right) & \\sin \\left(q_4 \\right)\\,\\sin \\left(q_5 \\right)\\\\ -\\cos \\left(q_6 \\right)\\,\\sin \\left(q_5 \\right) & \\sin \\left(q_5 \\right)\\,\\sin \\left(q_6 \\right) & \\cos \\left(q_5 \\right) \\end{pmatrix}$
%%
%[text] ## Caso Singolare $\\sin (q_5 )=0$
%%
%[text] ## Caso Singolare $q_5 =0$
% Sostituzione q5 = 0
R36_Zero = subs(R36, q5, 0);
R36_Zero = simplify(R36_Zero);

fprintf('Matrice Di Rotazione R36 Calcolata Con q5 = 0:\n');

disp(R36_Zero);
%%
%[text] ## Caso Singolare $q_5 =\\pi$
% Sostituzione q5 = Pi
R36_Pi = subs(R36, q5, pi);
R36_Pi = simplify(R36_Pi);

fprintf('Matrice Di Rotazione R36 Calcolata Con q5 = Pi:\n');

disp(R36_Pi);
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---