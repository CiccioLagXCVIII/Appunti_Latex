%[text] # Calcolo E Analisi Dello Jacobiano Geometrico Manipolatore Planare RR
%[text] Il calcolo dello Jacobiano geometrico $J(q)$, uno strumento fondamentale nell'analisi cinematica dei manipolatori seriali. Lo **Jacobiano** lega le velocità dei giunti $\\dot{q}$ alle velocità cartesiane dell'end-effector (lineare $v_e$ e angolare $\\omega_e$) attraverso la relazione:
%[text]{"align":"center"} $\\left(\\begin{array}{c} v_e \\\\ \\omega_e \\end{array}\\right)=J(q)\\dot{q}$
%[text] Il metodo sistematico si basa sulla scomposizione dello Jacobiano in colonne $J_i$, dove ciascuna colonna descrive l'influenza del giunto i-esimo sulla velocità dell'end-effector. Per calcolare lo Jacobiano geometrico, è necessario conoscere:
%[text] - La **geometria del manipolatore**, descritta dai parametri di *Denavit-Hartenberg (DH)*.
%[text] - Il **tipo di giunto** (rotoidale o prismatico).
%[text] - Il **numero di giunti **del manipolatore \
%[text] Si definiscono i parametri del manipolatore RR planare. Le lunghezze dei bracci ($l_1 ,l_2$) e le variabili di giunto ($q_1 ,q_2$) sono dichiarate come variabili simboliche per consentire un calcolo analitico.
clc; clear; close all;
% Variabili Di Giunto
syms q1 q2 real;

% Lunghezza Bracci
syms l1 l2 real;
%[text] La cinematica del manipolatore si ottiene dalla tabella dei parametri di Denavit-Hartenberg:
% Definizione Tabelle DH Struttura
DH_Table = [q1, 0, 0, l1;
            q2, 0, 0, l2];
% q1 = pi/4;
% q2 = pi/2;
% l1 = 1;
% l2 = 0.8
%[text] Per calcolare lo Jacobiano, è necessario conoscere la posizione e l'orientamento di ogni terna rispetto alla terna base ($RF_0$). Queste informazioni sono contenute nelle matrici di trasformazione omogenea $^{i-1} T_i$, che lega la terna $i$ alla terna $i-1$, che è calcolata a partire dalla riga i-esima della tabella DH. Per convenzione la matrice $^0 T_0 =I_{4\\times 4}$.
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
% | *Rotoidale* | $z_{i-1} \times (p_{0,e} - p_{0,i-1})$ | $z_{i-1}$ |
%[text] - $z_{i-1}$ è il versore dell'asse di rotazione del giunto $i$ espresso nelle coordinate della terna base.
%[text] - $p_{0,i-1}$ è il vettore posizione dell'origine della terna $i-1$, espresso rispetto alla terna base.
%[text] - $p_{0,e}$ è il vettore posizione dell'end-effector, espresso rispetto alla terna base. \
% Estrazioni Matrici Singole
T00 = eye(4);
T01 = T(:,:,1);
%[text] Il vettore $z_{i-1}$ corrisponde alla **terza colonna** della matrice di rotazione 3x3 contenuta in $^0T_{i-1}$.
%[text] Il vettore $p_{0,i-1}$ corrisponde alla **quarta colonna** (il vettore di traslazione) della matrice $^0T_{i-1}$.
% Valori Per J1
z0 = T00(1:3,3);
fprintf('Vettore z0:');
disp(z0);
p00 = T00(1:3,4);
fprintf('Vettore p_{0,0}:');
disp(p00);
% Valori Per J2
z1 = T01(1:3,3);
fprintf('Vettore z1:');
disp(z1);
p01 = T01(1:3,4);
fprintf('Vettore p_{0,1}:');
disp(p01);
% Valori Per JE
z2 = T02(1:3,3);
fprintf('Vettore z2:');
disp(z2);
p0e = T02(1:3,4);
fprintf('Vettore p_{0,e}:');
disp(p0e);
p1e = p0e - p01;
% Contributi Angolari
J_A1 = z0;
J_A2 = z1;

% Contributi Lineari
J_L1 = cross(z0, p0e - p00);
J_L2 = cross(z1, p1e);

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
%[text] ## Analisi Delle Configurazioni Singolari Dello Jacobiano
%[text] Le singolarità cinematiche si verificano nelle configurazioni in cui il manipolatore perde la capacità di muoversi in una o più direzioni dello spazio operativo. Matematicamente, questo accade quando la matrice Jacobiana perde di rango. Per un manipolatore planare, si è interessati principalmente al movimento nel piano XY, quindi si analizza la sottomatrice di posizione dello Jacobiano ($2\\times 2$) che lega le velocità dei giunti alle velocità lineari planari dell'end-effector.
% Estrazione Jacobiano Di Posizione Planare (Prime Due Righe)
J_r = J_q(1:2,1:2);
fprintf('Jacobiano Di Posizione Manipolatore RR Planare Simbolico (J_r):');
disp(J_r);
%[text] Le configurazioni singolari si trovano cercando i valori delle variabili di giunto $q$ che annullano il determinante dello Jacobiano di posizione $J_r$.
% Calcolo Determinante Jacobiano Di Posizione
detJr = det(J_r);
detJr = simplify(detJr);

fprintf('Determinante Jacobiano Di Posizione:');
disp(detJr);
[solDetJr, params, conditions] = solve(detJr == 0, q2, 'ReturnConditions', true);
% Valori pari di k corrispondono al robot completamente esteso (q2 = 0).
% Valori dispari di k corrispondono al robot completamente ripiegato (q2 = $\pi$).
% Basta considerare k = 0 e k = 1
% params = k
solDetJr_1 = subs(solDetJr, params, 0);
solDetJr_2 = subs(solDetJr, params, 1);
fprintf('Valori Per Cui Determinante Jacobiano Nullo:');
disp(solDetJr_1);
disp(solDetJr_2);
%[text] Il risultato dell'equazione $det(J_r )=0$ fornisce le configurazioni di singolarità del manipolatore. Per il manipolatore RR planare, queste condizioni corrispondono fisicamente alle configurazioni in cui i due bracci sono allineati, ovvero quando il secondo giunto ha un angolo di 0 o $\\pi$ radianti. In queste pose, l'end-effector non può muoversi istantaneamente in direzione radiale.
%%
%[text] ## Valutazione Numerica Dello Jacobiano In Configurazione Specifica

% Definizione Valori Numerici
q1_val = pi/4;
q2_val = pi/2;
l1_val = 1;
l2_val = 0.8;

% Sostituzione
J_q_num = subs(J_q, {q1, q2, l1, l2}, {q1_val, q2_val, l1_val, l2_val});
J_r_num = subs(J_r, {q1, q2, l1, l2}, {q1_val, q2_val, l1_val, l2_val});
detJr_num = subs(detJr, {q1, q2, l1, l2}, {q1_val, q2_val, l1_val, l2_val});

fprintf('Jacobiano Geometrico Numerico J_q:');
disp(double(J_q_num));
fprintf('Jacobiano Di Posizione Numerico J_r:');
disp(double(J_r_num));
fprintf('Valore del Determinante dello Jacobiano Di Posizione:');
disp(double(detJr_num));
% Verifica Singolarità
if abs(double(detJr_num)) < 1e-10
    fprintf('Configurazione Singolare');
else
    fprintf('Configurazione NON Singolare.\n');
end
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---