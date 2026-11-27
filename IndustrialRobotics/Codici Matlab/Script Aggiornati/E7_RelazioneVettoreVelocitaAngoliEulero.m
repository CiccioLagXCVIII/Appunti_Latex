%[text] # Relazione Tra Velocità Angolare E Angoli Di Eulero RPY
%[text] L'orientamento di un corpo rigido viene spesso descritto tramite una sequenza di tre rotazioni elementari note come **angoli di Eulero**. La convenzione **Roll-Pitch-Yaw (RPY)** corrisponde a una sequenza di rotazioni *ZYX* (equivalente a rotazioni Roll-Pitch-Yaw rispetto agli assi fissi *X,Y,Z*).
%[text] La matrice di rotazione totale **R** che trasforma le coordinate da un sistema di riferimento solidale al corpo al sistema di riferimento fisso rappresenta una sequenza di rotazioni definite rispetto agli assi del sistema di riferimento fisso nell'ordine *X,Y,Z*, oppure per la cinematica del corpo, da una sequenza di rotazioni rispetto agli assi del sistema solidale (***intrinseche***) nell'ordine *Z,Y',X''*.
%[text] L'obiettivo è determinare la matrice di trasformazione $\\mathbf{M}(\\phi ,\\theta )$ che lega le derivate temporali degli angoli di Eulero ${\\bigl\\lbrack \\dot{\\phi} ,\\dot{\\theta} ,\\dot{\\psi} \\bigr\\rbrack }^T$, al vettore velocità angolare istantanea del corpo $\\mathbf{\\omega }={\\bigl\\lbrack \\omega_x ,\\omega_y ,\\omega_z \\bigr\\rbrack }^T$, espresso nel sistema di riferimento fisso (della base). Dove:
%[text] - Il **vettore velocità angolare** $\\omega$ è una *grandezza* *vettoriale* che descrive l'asse di rotazione istantaneo e il valore della velocità di rotazione del corpo rigido. Le sue componenti possono essere sommate vettorialmente.
%[text] - Il **vettore delle derivate degli angoli **di Eulero rappresenta la velocità di variazione dei parametri scelti per descrivere l'orientamento. Poiché ciascuna rotazione di Eulero avviene attorno a un asse che può essere differente dagli altri, le loro velocità ***non*** possono essere sommate direttamente per ottenere $\\omega$. \
%[text] La relazione che si deve derivare simbolicamente ha la forma:
%[text]{"align":"center"} $\\left(\\begin{array}{c} \\omega_x \\\\ \\omega_y \\\\ \\omega_z \\end{array}\\right)=\\mathbf{M}(\\phi ,\\theta )\\;\\cdot \\;\\left(\\begin{array}{c} \\dot{\\phi} \\\\ \\dot{\\theta} \\\\ \\dot{\\psi} \\end{array}\\right)$
%[text] dove **M** è la matrice $3\\times 3$ che dipende dalla configurazione angolare corrente del corpo.Analizzando il determinante di **M** si possono identificare le configurazioni singolari in cui questa rappresentazione perde di validità.
%[text] Si definiscono tutte le variabili simboliche che includono gli angoli di Eulero $(\\phi ,\\theta ,\\psi )$ e le loro derivate $(\\dot{\\phi} ,\\dot{\\theta} ,\\dot{\\psi} )$
clc; clear; close all;

% Definizioni Angoli Eulero
syms psi theta phi real;

% Definizioni Derivate Angoli Eulero
syms psi_dot theta_dot phi_dot real;
%[text] La convenzione **RPY** (*ZYX*) descrive una rotazione totale **R** equivalente a rotazioni Roll-Pitch-Yaw rispetto agli assi fissi ($X, Y, Z$). La matrice di rotazione totale $R_{RPY}$ è:
%[text]{"align":"center"} $R_{RPY} (\\phi ,\\theta ,\\psi )=R_z (\\phi )\\cdot R_y (\\theta )\\cdot R_x (\\psi )$
% Matrice Rotazione Attorno X (Roll)
Rx = [1, 0,        0;
      0, cos(psi), -sin(psi);
      0, sin(psi), cos(psi)];

% Matrice Rotazione Attorno Y (Pitch)
Ry = [cos(theta),  0, sin(theta);
      0,           1, 0;
      -sin(theta), 0, cos(theta)];

% Matrice Rotazione Attorno Z (Yaw)
Rz = [cos(phi), -sin(phi), 0;
      sin(phi), cos(phi),  0;
      0,        0,         1];

% Matrice Rotazione Finale
% L'Ordine È Importante: La Prima Rotazione Va Più A Destra
R_RPY = Rz * Ry * Rx;
R_RPY = simplify(R_RPY);

fprintf('Matrice Rx (Roll):');
disp(Rx);
fprintf('Matrice Ry (Pitch):');

disp(Ry);
fprintf('Matrice Rz (Yaw):');

disp(Rz);
fprintf('Matrice di rotazione totale R_RPY (ZYX):');

disp(R_RPY);
%[text] Ricordando la regola della catena e che $\\psi ,\\theta ,\\phi$ dipendono da $t$, si avrà che la derivata di una matrice di rotazione è:
%[text]{"align":"center"} ${\\dot{R} }_x (\\psi )=\\frac{dR_x }{d\\psi }\\;\\frac{d\\psi }{dt}$
% Derivata Rx
dRx_dpsi = diff(Rx, psi);
Rx_dot = dRx_dpsi * psi_dot;

% Derivata Ry
dRy_dtheta = diff(Ry, theta);
Ry_dot = dRy_dtheta * theta_dot;

% Derivata Rz
dRz_dphi = diff(Rz, phi);
Rz_dot = dRz_dphi * phi_dot;

fprintf('Derivata Temporale Di Rx (Rx_dot):');

disp(Rx_dot);
fprintf('Derivata Temporale Di Ry (Ry_dot):');

disp(Ry_dot);
fprintf('Derivata Temporale Di Rz (Rz_dot):');

disp(Rz_dot);
%[text] Si nota che
%[text]{"align":"center"} $\\begin{array}{l} \\dot{R}_x (\\psi ) =\\dot{\\psi} \\;\\frac{dR_x}{d\\psi} (\\psi )\\\\ \\dot{R}_y (\\theta ) =\\dot{\\theta} \\;\\frac{dR_y}{d\\theta} (\\theta )\\\\ \\dot{R}_z (\\phi ) =\\dot{\\phi} \\;\\frac{dR_z}{d\\phi} (\\phi ) \\end{array}$
%%
%[text] ## Derivazione Della Matrice Di Trasformazione Cinematica RPY
%[text] Ricordando la derivata del prodotto, la derivata di $R_{RPY}$ sarà:
%[text]{"align":"center"} $\\dot{R}_{RPY} = \\dot{R}_z(\\phi) \\cdot R_y(\\theta) \\cdot R_x(\\psi) + R_z(\\phi) \\cdot \\dot{R}_y(\\theta) \\cdot R_x(\\psi) + R_z(\\phi) \\cdot R_y(\\theta) \\cdot \\dot{R}_x(\\psi)$
%[text] Sostituendo si ottiene
%[text]{"align":"center"} $\\dot{R}_{RPY} =\\dot{\\phi} \\;\\frac{dR_z}{d\\phi} (\\phi )\\cdot R_y (\\theta )\\cdot R_x (\\psi )+R_z (\\phi )\\cdot \\dot{\\theta} \\;\\frac{dR_y}{d\\theta} (\\theta )\\cdot R_x (\\psi )+R_z (\\phi )\\cdot R_y (\\theta )\\cdot \\dot{\\psi} \\;\\frac{dR_x}{d\\psi} (\\psi )$
%[text] L'obiettivo è calcolare la **matrice di velocità angolare**
%[text] ### $\\mathbf{S}(\\mathbf{\\omega })={\\dot{R} }_{RPY} \\;\\;R_{RPY}^T$
%[text] Ricordando che la trasposta di un prodotto di matrici è uguale al prodotto delle loro trasposte, **ma in ordine inverso**
%[text] ### $R_{RPY}^T =R_X^T (\\psi )\\;R_Y^T (\\theta )\\;R_Z^T (\\phi )$
% Calcolo Trasposte
Rx_Trasp = Rx.';
Ry_Trasp = Ry.';
Rz_Trasp = Rz.';

% Calcolo Prodotto Trasposte
R_RPY_Trasp = Rx_Trasp * Ry_Trasp * Rz_Trasp;
fprintf('Trasposta Di R_RPY (R_RPY_Trasp):');

R_RPY_Trasp = simplify(R_RPY_Trasp);
disp(R_RPY_Trasp);
% Derivata Temporale Di R_RPY tramite regola di Leibniz:
R_RPY_dot = Rz_dot * Ry * Rx + Rz * Ry_dot * Rx + Rz * Ry * Rx_dot;
%[text] Andando a moltiplicare ogni membro di $\\dot{R_{RPY} }$ per $R_{RPY}^T$ e ricordando che $RR^T =R^T R=I$ si ottiene:
%[text]{"align":"center"} $\\mathbf{S}(\\omega)={\\dot{R} }_{RPY} \\;\\;R_{RPY}^T =$
%[text]{"align":"center"} $=\\dot{R_z } (\\phi )R_z (\\phi )^T +R_z (\\phi ){\\dot{R} }_y (\\theta )R_y (\\theta )^T R_z (\\phi )^T +R_z (\\phi )R_y (\\theta ){\\dot{R} }_x (\\psi )R_x (\\psi )^T R_y (\\theta )^T R_z (\\phi )^T$
%[text] Ponendo:
%[text] $\\text{Termine 1} =\\dot{R_z } (\\phi )R_z (\\phi )^T \\\\ \\text{Termine 2} =R_z (\\phi ){\\dot{R} }_y (\\theta )R_y (\\theta )^T R_z (\\phi )^T \\\\ \\text{Termine 3} =R_z (\\phi )R_y (\\theta ){\\dot{R} }_x (\\psi )R_x (\\psi )^T R_y (\\theta )^T R_z (\\phi )^T$
Termine1 = Rz_dot * Rz_Trasp;
Termine2 = Rz * Ry_dot * Ry_Trasp * Rz_Trasp;
Termine3 = Rz * Ry * Rx_dot * Rx_Trasp * Ry_Trasp * Rz_Trasp;

fprintf('Termine 1:');

Termine1 = simplify(Termine1);
disp(Termine1);
fprintf('Termine 2:');
Termine2 = simplify(Termine2);
disp(Termine2);
fprintf('Termine 3:');

Termine3 = simplify(Termine3);
disp(Termine3);
S_omega = Termine1 + Termine2 + Termine3;
S_omega = simplify(S_omega);
fprintf('Matrice Velocità Angolare Totale S(omega):');

disp(S_omega);

% Verifica simbolica tramite R_RPY_dot * R_RPY_Trasp
verifica_S = isAlways(simplify(R_RPY_dot * R_RPY_Trasp - S_omega) == 0);
fprintf('Verifica simbolica (R_RPY_dot * R_RPY_Trasp - S_omega == 0):\n');
disp(verifica_S);
%[text] Quindi si possono estrarre le componenti di $\\omega$ direttamente dalla matrice $S(\\omega )$ calcolata, cioè:
%[text]{"align":"center"} $\\begin{array}{l} \\omega_x =S(\\omega )_{3,2} \\\\ \\omega_y =S(\\omega )_{1,3} \\\\ \\omega_z =S(\\omega )_{2,1} \\end{array}$
%[text] Come si nota dal vettore $\\omega$ appena calcolato, ogni sua componente è una combinazione lineare delle derivate degli angoli di Eulero $\\bigl\\lbrack \\dot{\\phi} ,\\dot{\\theta} ,\\dot{\\psi} \\bigr\\rbrack$. L'obiettivo è ricavare la matrice **M** che lega il *vettore* *velocità angolare* $\\omega$ alle *derivate degli angoli*, secondo la relazione:
%[text]{"align":"center"} $\\omega =M(\\phi ,\\theta )\\;\\;\\left(\\begin{array}{c} \\dot{\\phi} \\\\ \\dot{\\theta} \\\\ \\dot{\\psi} \\end{array}\\right)$
%[text] ### Costruzione Della Matrice Di Trasformazione M
syms wx wy wz real;

omega_vec = [S_omega(3,2); S_omega(1,3); S_omega(2,1)];
omega_vec = simplify(omega_vec);
fprintf('Vettore Velocità Angolare omega estratto da S(omega):');
disp(omega_vec);

vettVel = [wx; wy; wz];
vettDer = [phi_dot; theta_dot; psi_dot];
M = simplify(jacobian(omega_vec, vettDer));

fprintf('Matrice M Completa:\n');

disp(M);
eqSystem = vettVel == M * vettDer;

fprintf('Sistema Da Risolvere:');
disp(eqSystem);
detM = simplify(det(M));
fprintf('Determinante Matrice M:');
disp(detM);
[singTheta, ~, conds] = solve(detM == 0, theta, 'ReturnConditions', true);
fprintf('Configurazioni Singolari (det(M) = 0 -> theta =):\n');
disp(singTheta);
disp(conds);
%[text] Questa matrice fornisce la relazione tra $\\omega$ e gli angoli di Eulero. Se $\\det\\bigl(\\;M(\\phi ,\\theta )\\;\\bigr)\\not= 0$ allora a partire da $\\omega$ è possibile conoscere le derivate degli angoli $\\dot{\\phi} ,\\;\\dot{\\theta} ,\\;\\dot{\\psi}$ ed essendo esse integrabili si possono ricavare $\\phi ,\\;\\theta ,\\;\\psi$.
%%
%[text] ## Analisi E Interpretazione Delle Singolarità Di Rappresentazione RPY
%[text] Come calcolato, il determinante della matrice di trasformazione è $-\\cos (\\theta )$.
%[text] La relazione $\\omega =M(\\phi ,\\theta )\\;\\;\\left(\\begin{array}{c} \\dot{\\phi} \\\\ \\dot{\\theta} \\\\ \\dot{\\psi} \\end{array}\\right)$ non può essere invertita quando la matrice M è ***singolare***, ovvero quando il suo determinante è nullo.
%[text] Questa condizione si verifica quando l'angolo di *Pitch*, $\\theta$ , è uguale a $\\pm \\frac{\\pi }{2}$ radianti (ovvero $\\pm 90^{\\circ }$) ed è nota come **singolarità di rappresentazione (o gimbal lock)** e rappresenta un punto critico. Quando $\\theta =\\pm \\frac{\\pi }{2}$, due assi di rotazione (Roll attorno a $X$ e Yaw attorno a $Z$ nella sequenza RPY) si allineano, rendendo le rispettive rotazioni indistinguibili. *Il sistema perde un ****grado di libertà (DoF)***.
%[text] Di conseguenza, \underline{per una data velocità angolare }$\\omega$\underline{, non esiste una soluzione unica per le velocità degli angoli }$\\dot{\\phi}$\underline{ e }$\\dot{\\psi}$. Questo rende la rappresentazione RPY inadeguata e instabile in prossimità di queste configurazioni singolari.
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---