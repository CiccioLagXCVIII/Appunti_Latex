%[text] # Disaccoppiamento Polso-Struttura Portante Nel Manipolatore Di Stanford
%%
%[text] ## Cinematica Diretta Della Struttura Portante Sferica
%[text]{"align":"center"} ![Disaccoppiamento Cinematica Diretta 1](../../Esercitazioni Matlab/E3_6_2_DisaccoppiamentoPolsoStrutturaPortante/E3_6_2_Images/image_0.jpeg)
clc; clear; close all;
% Definizione Variabili Simboliche
syms q1 q2 q3 d2 real;

DH_table_Strut = [q1, 0, -pi/2, 0;
                  q2, d2, pi/2, 0;
                  0, q3, 0, 0];


% Numero Giunti Manipolatore
n = size(DH_table_Strut, 1);

% Calcolo Matrici Trasformazione Struttura
[A_matrices_Strut, R_matrices_Strut] = Compute_DH_Transformations(DH_table_Strut);
% Visualizzazione Matrici Trasformazione Struttura
j = 0;
for i = 1:n
    fprintf('Matrice Di Trasformazione Omogenea ^{%d}A_(%d):\n', j, j+1);
    disp(A_matrices_Strut(:,:,i));
    j = j+1;
end
% Calcolo Matrice Di Trasformazione Totale Dalla Base All'End Effector
T03 = A_matrices_Strut(:,:,1) * A_matrices_Strut(:,:,2) * A_matrices_Strut(:,:,3);
T03 = simplify(T03);

fprintf('Matrice Di Trasformazione Omogenea ^(0)T_(3):\n');

disp(T03);
%[text]{"align":"center"} $^{0}\\mathbf{T}_{3}(\\mathbf{q}) \\; = \\; ^{0}\\mathbf{A}_{1}(q_{1}) \\; \\cdot \\; ^{1}\\mathbf{A}_{2}(q_{2}) \\; \\cdot \\; ^{2}\\mathbf{A}_{3}(q_{3}) =$
%[text]{"align":"center"} $= \\begin{pmatrix} c(q_{1})c(q_{2}) & -s(q_{1}) & c(q_{1})s(q_{2}) & c(q_{1})s(q_{2})q_{3} - s(q_{1})d_{2} \\\\ s(q_{1})c(q_{2}) & c(q_{1}) & s(q_{1})s(q_{2}) & s(q_{1})s(q_{2})q_{3} + c(q_{1})d_{2}\\\\ -s(q_{2}) & 0 & c(q_{2}) & c(q_{2})q_{3}\\\\ 0 & 0 & 0 & 1 \\end{pmatrix}$
%%
%[text] ## Cinematica Diretta Del Polso Sferico
%[text]{"align":"center"} ![Disaccoppiamento Cinematica Diretta 2](../../Esercitazioni Matlab/E3_6_2_DisaccoppiamentoPolsoStrutturaPortante/E3_6_2_Images/image_1.jpeg)
% Definizione Variabili Simboliche
syms q4 q5 q6 d6 real;

% Tabella Parametri Denavit-Hartenberg (DH)
DH_table_Polso = [q4, 0, -pi/2, 0;
                  q5, 0, pi/2, 0;
                  q6, d6, 0, 0];


% Numero Giunti Manipolatore
n = size(DH_table_Polso, 1);

% Calcolo Matrici Trasformazione Polso
[A_matrices_Polso, R_matrices_Polso] = Compute_DH_Transformations(DH_table_Polso);

% Visualizzazione Matrici Trasformazione Polso
j = 3;
for i = 1:n
    fprintf('Matrice Di Trasformazione Omogenea ^(%d)A_(%d):\n', j, j+1);
    disp(A_matrices_Polso(:,:,i));

    j = j+1;
end
T36 = A_matrices_Polso(:,:,1) * A_matrices_Polso(:,:,2) * A_matrices_Polso(:,:,3);
T36 = simplify(T36);

fprintf('Matrice Di Trasformazione Omogenea ^{3}T_(6):\n');

disp(T36);
%[text]{"align":"center"} $^{3}\\mathbf{T}_{6}(\\mathbf{q}) \\; = \\; ^{3}\\mathbf{A}_{4}(q_{4}) \\; \\cdot \\; ^{4}\\mathbf{A}_{5}(q_{5}) \\; \\cdot \\; ^{5}\\mathbf{A}_{6}(q_{6}) =$
%[text]{"align":"center"} $= \\begin{pmatrix} c(q_{4})c(q_{5})c(q_{6}) - s(q_{4})s(q_{6}) & -c(q_{6})s(q_{4}) - c(q_{4})c(q_{5})s(q_{6}) & c(q_{4})s(q_{5}) & c(q_{4})s(q_{5})d_{6} \\\\ c(q_{4})s(q_{6}) + c(q_{5})c(q_{6})s(q_{4}) & c(q_{4})c(q_{6}) - c(q_{5})s(q_{4})s(q_{6}) & s(q_{4})s(q_{5}) & s(q_{4})s(q_{5})d_{6} \\\\ -c(q_{6})s(q_{5}) & s(q_{5})s(q_{6}) & c(q_{5}) & c(q_{5})d_{6} \\\\ 0 & 0 & 0 & 1 \\end{pmatrix}$
%%
%[text] ## Cinematica Diretta Completa Del Manipolatore Di Stanford
T06 = simplify(T03 * T36);
fprintf('Matrice Di Trasformazione Omogenea ^{0}T_{6}:\n');
disp(T06);
%%
%[text] ## Verifica Della Condizione Di Disaccoppiamento Cinematico
%[text]{"align":"center"} $\\exists \\;{\\mathbf{d}}_0 ,\\,{\\mathbf{d}}_1 \\in {\\mathbb{R}}^3 \\;\\;\\mid \\;\\;^3 {\\mathbf{d}}_6 =^3 {\\mathbf{R}}_6 {\\mathbf{d}}_1 +{\\mathbf{d}}_0$
% Estrazione Vettore Posizione
d36 = T36(1:3, 4);
d36 = simplify(d36);
fprintf('Vettore Posizione ^{3}d_{6}:\n');

disp(d36);

% Verifica vettori costanti d_0 e d_1 (Condizione di Pieper)
d0 = [0; 0; 0];
R36_polso = simplify(T36(1:3, 1:3));
d1 = simplify(transpose(R36_polso) * d36);
fprintf('Vettore d_{0}:\n');
disp(d0);
fprintf('Vettore d_{1} = (^{3}R_{6})^{T} ^{3}d_{6}:\n');
disp(d1);
%%
%[text] ## Cinematica Inversa Di Posizione Della Struttura Portante
%[text]{"align":"center"} $^0 {\\mathbf{d}}_6 =^0 {\\mathbf{d}}_3 +^0 {\\mathbf{R}}_3 \\,^3 {\\mathbf{d}}_6$
% Estrazione Vettore Posizione
d03 = T03(1:3, 4);
d03 = simplify(d03);
fprintf('Vettore Posizione ^{0}d_{3}:\n');

disp(d03);

% Isolamento posizione desiderata del centro polso e risoluzione (q3, q2, q1)
syms dx dy dz d03HatNormSq real;
d06_des = [dx; dy; dz];
R06_des = sym('r06_', [3, 3], 'real');
d03_hat = simplify(d06_des - R06_des * d1);
fprintf('Vettore Desiderato Centro Del Polso \\hat{^{0}d_{3}} = ^{0}d_{6} - ^{0}R_{6} d_{1}:\n');
disp(d03_hat);

q3_sol_pos = sqrt(d03HatNormSq - d2^2);
q3_sol_neg = -sqrt(d03HatNormSq - d2^2);
cos_q2 = d03_hat(3) / q3;
q2_sol_pos = atan2(sqrt(1 - cos_q2^2), cos_q2);
q2_sol_neg = atan2(-sqrt(1 - cos_q2^2), cos_q2);

A_q1 = [q3*sin(q2), -d2; d2, q3*sin(q2)];
cs_q1 = simplify(inv(A_q1) * [d03_hat(1); d03_hat(2)]);
q1_sol = atan2(cs_q1(2), cs_q1(1));

fprintf('Soluzioni simboliche (q3, q2, q1):\n');
fprintf('q3 (+):\n'); disp(q3_sol_pos);
fprintf('q3 (-):\n'); disp(q3_sol_neg);
fprintf('q2 (+):\n'); disp(q2_sol_pos);
fprintf('q2 (-):\n'); disp(q2_sol_neg);
fprintf('q1:\n'); disp(q1_sol);
%%
%[text] ## Cinematica Inversa Di Orientamento Del Polso Sferico
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

% Matrice nota \bar{R} = (^{0}R_{3})^T \hat{^{0}R_{6}} e soluzioni (q5, q4, q6)
R03_K = sym('r03_', [3, 3], 'real');
R_bar_calc = transpose(R03_K) * R06_des;
R_bar = sym('r_bar', [3, 3], 'real');
cos_q5 = R_bar(3,3);
q5_sol_pos = atan2(sqrt(1 - cos_q5^2), cos_q5);
q5_sol_neg = atan2(-sqrt(1 - cos_q5^2), cos_q5);
q4_sol = atan2(R_bar(2,3) / sin(q5), R_bar(1,3) / sin(q5));
q6_sol = atan2(R_bar(3,2) / sin(q5), -R_bar(3,1) / sin(q5));

fprintf('Soluzioni simboliche (q5, q4, q6):\n');
fprintf('q5 (+):\n'); disp(q5_sol_pos);
fprintf('q5 (-):\n'); disp(q5_sol_neg);
fprintf('q4:\n'); disp(q4_sol);
fprintf('q6:\n'); disp(q6_sol);
%%
%[text] ## Analisi Del Caso Singolare Del Polso $\\sin (q_5 )=0$
%[text] ### Configurazione Singolare Con $q_5 =0$
% Sostituzione q5 = 0
R36_Zero = subs(R36, q5, 0);
R36_Zero = simplify(R36_Zero);

fprintf('Matrice Di Rotazione R36 Calcolata Con q5 = 0:\n');

disp(R36_Zero);
q4_plus_q6 = atan2(R_bar(2,1), R_bar(1,1));
fprintf('In singolarità q5 = 0, q4 + q6 =\n');
disp(q4_plus_q6);
%[text] ### Configurazione Singolare Con $q_5 =\\pi$
% Sostituzione q5 = Pi
R36_Pi = subs(R36, q5, pi);
R36_Pi = simplify(R36_Pi);

fprintf('Matrice Di Rotazione R36 Calcolata Con q5 = Pi:\n');

disp(R36_Pi);
q4_minus_q6 = atan2(-R_bar(2,1), R_bar(2,2));
fprintf('In singolarità q5 = Pi, q4 - q6 =\n');
disp(q4_minus_q6);
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---