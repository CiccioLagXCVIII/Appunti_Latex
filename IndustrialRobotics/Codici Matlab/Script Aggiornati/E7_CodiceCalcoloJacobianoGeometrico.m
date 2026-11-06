%[text] # Calcolo E Analisi Dello Jacobiano Geometrico
%[text] Il calcolo dello Jacobiano geometrico $J(q)$, uno strumento fondamentale nell'analisi cinematica dei manipolatori seriali. Lo **Jacobiano** lega le velocità dei giunti $\\dot{q}$ alle velocità cartesiane dell'end-effector (lineare $v_E$ e angolare $\\omega_E$) attraverso la relazione:
%[text]{"align":"center"} $\\left(\\begin{array}{c} v_E \\\\ \\omega_E \\end{array}\\right)=J(q)\\dot{q}$
%[text] Il metodo sistematico si basa sulla scomposizione dello Jacobiano in colonne $J_i$, dove ciascuna colonna descrive l'influenza del giunto i-esimo sulla velocità dell'end-effector. Per calcolare lo Jacobiano geometrico, è necessario conoscere:
%[text] - La **geometria del manipolatore**, descritta dai parametri di *Denavit-Hartenberg (DH)*.
%[text] - Il **tipo di giunto** (rotoidale o prismatico).
%[text] - Il **numero di giunti **del manipolatore \
%[text] Si definiscono i parametri del manipolatore RR planare. Le lunghezze dei bracci ($l_1 ,l_2$) e le variabili di giunto ($q_1 ,q_2$) sono dichiarate come variabili simboliche per consentire un calcolo analitico.
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
% Variabili Di Giunto
syms q1 q2 real;

% Lunghezza Bracci
syms a1 a2 real;
%[text] La cinematica del manipolatore si ottiene dalla tabella dei parametri di Denavit-Hartenberg:
% Definizione Tabelle DH Struttura
DH_Table = [q1, 0, 0, a1;
            q2, 0, 0, a2];
% q1 = pi/4;
% q2 = pi/2;
% a1 = 1;
% a2 = 0.8
%[text] Per calcolare lo Jacobiano, è necessario conoscere la posizione e l'orientamento di ogni terna rispetto alla terna base ($RF_0$). Queste informazioni sono contenute nelle matrici di trasformazione omogenea $^{i-1} T_i$, che lega la terna $i$ alla terna $i-1$, che è calcolata a partire dalla riga i-esima della tabella DH. Per convenzione la matrice $^0 T_0 =I$.
% Calcolo Matrici Trasformazione E Rotazione Struttura
[T, R] = Compute_DH_Transformations(DH_Table);
%[text] La matrice di trasformazione cumulativa $^0 T_2$, descrive la posa (posizione e orientamento) della terna $2$ rispetto alla terna base $0$.
T02 = simplify(T(:,:,1) * T(:,:,2));
fprintf('Matrice Di Trasformazione Omogenea ^{0}T_(2)');
disp(T02);
%[text] Lo Jacobiano geometrico $J$ è una matrice 6xn le cui colonne $J_i$ sono calcolate secondo le specifiche formule, a seconda del tipo di giunto:
%[text:table]
% | Tipo Di Giunto | Contributo Lineare $J_{L_{i}}$ | Contributo Angolare $J_{A_{i}}$ |
% | :---: | :---: | :---: |
% | *Prismatico* | $z_{i-1}$ | Vettore Nullo $3 \times 1$ |
% | *Rotoidale* | $z_{i-1} \times (p_E - p_{i-1})$ | $z_{i-1}$ |
%[text] - $z_{i-1}$ è il versore dell'asse di rotazione del giunto $i$ espresso nelle coordinate della terna base.
%[text] - $p_{i-1}$ è il vettore posizione dell'origine della terna $i-1$, espresso rispetto alla terna base.
%[text] - $p_E$ è il vettore posizione dell'end-effector, espresso rispetto alla terna base. \
% Estrazioni Matrici Singole
T0 = eye(4);
T1 = T(:,:,1);
T2 = T02;
%[text] Il vettore $z_{i-1}$ corrisponde alla **terza colonna** della matrice di rotazione 3x3 contenuta in $T_{i-1}$.
%[text] Il vettore $p_{i-1}$ corrisponde alla **quarta colonna** (il vettore di traslazione) della matrice $T_{i-1}$.
% Valori Per J1
z0 = T0(1:3,3);
fprintf('Vettore z0:');
disp(z0);
p0 = T0(1:3,4);
fprintf('Vettore p0:');
disp(p0);
% Valori Per J2
z1 = T1(1:3,3);
fprintf('Vettore z1');
disp(z1);
p1 = T1(1:3,4);
fprintf('Vettore p1:');
disp(p1);
% Valori Per JE
zE = T2(1:3,3);
fprintf('Vettore z2:');
disp(zE);
pE = T2(1:3,4);
fprintf('Vettore p2:');
disp(pE);
% Contributi Angolari
J_A1 = z0;
J_A2 = z1;

% Contributi Lineari
J_L1 = cross(z0, pE - p0);
J_L2 = cross(z1, pE - p1);

% Colonne
J1 = [J_L1; J_A1];
J2 = [J_L2; J_A2];

fprintf('Vettore J1:');
disp(J1);
fprintf('Vettore J2:');
disp(J2);
%[text] A questo punto concatenando i due vettori si ottiene lo **Jacobiano Geometrico:**
% Costruzione Jacobiano Geometrico
J_q = [J1, J2];
J_q = simplify(J_q);

fprintf('Jacobiano Geometrico Manipolatore RR Planare Simbolico');
disp(J_q);
%%
%[text] ## Analisi Singolarità
%[text] Le singolarità cinematiche si verificano nelle configurazioni in cui il manipolatore perde la capacità di muoversi in una o più direzioni dello spazio operativo. Matematicamente, questo accade quando la matrice Jacobiana perde di rango. Per un manipolatore planare, si è interessati principalmente al movimento nel piano XY, quindi si analizza la sottomatrice dello Jacobiano che lega le velocità dei giunti alle velocità lineari dell'end-effector.
% Estrazione Jacobiano Lineare (Prime Due Righe)
J_L = J_q(1:2,1:2);
fprintf('Jacobiano Lineare Manipolatore RR Planare Simbolico:');
disp(J_L);
%[text] Le configurazioni singolari si trovano cercando i valori delle variabili di giunto $q$ che annullano il determinante della Jacobiana Lineare.
% Calcolo Determinante Jacobiano Lineare
detJL = det(J_L);
detJL = simplify(detJL);

fprintf('Determinante Jacobiano Lineare:');
disp(detJL);
[solDetJL, params, conditions] = solve(detJL == 0, q2, 'ReturnConditions', true);
% Valori pari di k corrispondono al robot completamente esteso (q2 = 0).
% Valori dispari di k corrispondono al robot completamente ripiegato (q2 = $\pi$).
% Basta considerare k = 0 e k = 1
% params = k
solDetJL_1 = subs(solDetJL, params, 0);
solDetJL_2 = subs(solDetJL, params, 1);
fprintf('Valori Per Cui Determinante Jacobiano Nullo:');
disp(solDetJL_1);
disp(solDetJL_2);
%[text] Il risultato dell'equazione $det(J_L )=0$ fornisce le configurazioni di singolarità del manipolatore. Per il manipolatore RR planare, queste condizioni corrispondono fisicamente alle configurazioni in cui i due bracci sono allineati, ovvero quando il secondo giunto ha un angolo di 0 o $\\pi$ radianti. In queste pose, l'end-effector non può muoversi istantaneamente in direzione radiale.
%%
%[text] ## Calcolo Numerico
%% Calcolo Numerico Configurazione Specifica

% Definizione Valori Numerici
q1_val = pi/4;
q2_val = pi/2;
a1_val = 1;
a2_val = 0.8;

% Sostituzione
J_q_num = subs(J_q, {q1, q2, a1, a2}, {q1_val, q2_val, a1_val, a2_val});
J_L_num = subs(J_L, {q1, q2, a1, a2}, {q1_val, q2_val, a1_val, a2_val});
detJL_num = subs(detJL, {q1, q2, a1, a2}, {q1_val, q2_val, a1_val, a2_val});

fprintf('Jacobiano Geometrico Numerico J_q:');
disp(double(J_q_num));
fprintf('Jacobiano Lineare Numerico J_L:');
disp(double(J_L_num));
fprintf('Valore del Determinante dello Jacobiano Lineare:');
disp(double(detJL_num));
% Verifica Singolarità
if abs(double(detJL_num)) < 1e-10
    fprintf('Configurazione Singolare');
else
    fprintf('Configurazione NON Singolare.\n');
end
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---