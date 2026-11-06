%[text] # Relazione Tra Velocità Angolare E Angoli di Eulero RPY
%[text] L'orientamento di un corpo rigido, viene spesso descritto tramite una sequenza di tre rotazioni elementari note come **angoli di Eulero**. La convenzione **Roll-Pitch-Yaw (RPY)** corrisponde a una sequenza di rotazioni *ZYX*.
%[text] La matrice di rotazione totale **R** che trasforma le coordinate da un sistema di riferimento solidale al corpo al sistema di riferimento fisso rappresenta una sequenza di rotazioni definite rispetto agli assi del sistema di riferimento fisso nell'ordine *Z,Y,X*, oppure per la cinematica del corpo, da una sequenza di rotazioni rispetto agli assi del sistema solidale (***intrinseche***) nell'ordine inverso:
%[text] L'obiettivo è determinare la matrice di trasformazione, nota come **Jacobiano Analitico** o **Jacobiano Geometrico**, che lega le derivate temporali degli angoli di Eulero ${\\bigl\\lbrack \\dot{\\gamma} ,\\dot{\\beta} ,\\dot{\\alpha} \\bigr\\rbrack }^T$, al vettore velocità angolare istantanea del corpo $\\mathbf{\\omega }={\\bigl\\lbrack \\omega_x ,\\omega_y ,\\omega_z \\bigr\\rbrack }^T$, espresso nel sistema di riferimento fisso (della base). Dove:
%[text] - Il vettore** velocità angolare** $\\omega$ è una *grandezza* *vettoriale* che descrive l'asse di rotazione istantaneo e il valore della velocità di rotazione del corpo rigido. Le sue componenti possono essere sommate vettorialmente.
%[text] - Il **vettore delle derivate degli angoli **di Eulero rappresenta la velocità di variazione dei parametri scelti per descrivere l'orientamento. Poiché ciascuna rotazione di Eulero avviene attorno a un asse che può essere differente dagli altri, le loro velocità ***non*** possono essere sommate direttamente per ottenere $\\omega$. \
%[text] La relazione che si deve derivare simbolicamente ha la forma:
%[text]{"align":"center"} $\\left(\\begin{array}{c} \\omega_x \\\\ \\omega_y \\\\ \\omega_z \\end{array}\\right)=\\mathbf{M}(\\beta ,\\gamma )\\;\\cdot \\;\\left(\\begin{array}{c} \\dot{\\gamma} \\\\ \\dot{\\beta} \\\\ \\dot{\\alpha} \\end{array}\\right)$
%[text] dove **M** è la matrice $3\\times 3$ che dipende dalla configurazione angolare corrente del corpo.Analizzando il determinante di **M** si possono identificare le configurazioni singolari in cui questa rappresentazione perde di validità.
%[text] Si definiscono tutte le variabili simboliche che includono gli angoli di Eulero $(\\alpha ,\\beta ,\\gamma )$ e le loro derivate $(\\dot{\\alpha} ,\\dot{\\beta} ,\\dot{\\gamma} )$
% Definizioni Angoli Eulero
syms alpha beta gamma real;

% Definizioni Detivate Angoli Eulero
syms alpha_dot beta_dot gamma_dot real;
%[text] La convenzione **RPY** (*ZYX*) descrive una rotazione totale **R** come prodotto di tre rotazioni elementari attorno agli assi del sistema di riferimento corrente. La matrice di rotazione totale $R_{RPY}$ è:
%[text]{"align":"center"} $R_{RPY} (\\alpha ,\\beta ,\\gamma )=R_z (\\gamma )\\cdot R_y (\\beta )\\cdot R_x (\\alpha )$
% Matrice Rotazione Attorno X (Roll)
Rx = [1, 0,          0;
      0, cos(alpha), -sin(alpha);
      0, sin(alpha), cos(alpha)];

% Matrice Rotazione Attorno Y (Pitch)
Ry = [cos(beta),  0, sin(beta);
      0,          1, 0;
      -sin(beta), 0, cos(beta)];

% Matrice Rotazione Attorno Z (Yaw)
Rz = [cos(gamma), -sin(gamma), 0;
      sin(gamma), cos(gamma),  0;
      0,          0,           1];

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
%[text] Ricordando la regola della catena e che $\\alpha ,\\beta ,\\gamma$ dipendono da $t$ si avrà che, la derivata di una matrice di rotazione
%[text]{"align":"center"} ${\\dot{R} }_x (\\alpha )=\\frac{dR_x }{d\\alpha }\\;\\frac{d\\alpha }{dt}$
% Derivata Rx
dRx_dphi = diff(Rx, alpha);
alpha_dt = alpha_dot;
Rx_dot = dRx_dphi * alpha_dot;

% Derivata Ry
dRy_dbeta = diff(Ry, beta);
dbeta_dt = beta_dot;
Ry_dot = dRy_dbeta * beta_dot;

% Derivata Rz
dRz_dgamma = diff(Rz, gamma);
dgamma_dt = gamma_dot;
Rz_dot = dRz_dgamma * gamma_dot;

fprintf('Derivata Temporale Di Rx (Rx_dot):');

disp(Rx_dot);
fprintf('Derivata Temporale Di Ry (Ry_dot):');

disp(Ry_dot);
fprintf('Derivata Temporale Di Rz (Rz_dot):');

disp(Rz_dot);
%[text] Si nota che
%[text]{"align":"center"} $\\begin{array}{l} \\dot{R}_x (\\alpha ) =\\dot{\\alpha} \\;\\frac{dR_x}{d\\alpha} (\\alpha )\\\\ \\dot{R}_y (\\beta ) =\\dot{\\beta} \\;\\frac{dR_y}{d\\beta} (\\beta )\\\\ \\dot{R}_z (\\gamma ) =\\dot{\\gamma} \\;\\frac{dR_z}{d\\gamma} (\\gamma ) \\end{array}$
%[text] Ricordando la derivata del prodotto, la derivata di $R_{RPY}$ sarà:
%%
%[text] ## Derivazione della Matrice di Rotazione RPY
%[text]{"align":"center"} $\\dot{R}_{RPY} = \\dot{R}_z(\\gamma) \\cdot R_y(\\beta) \\cdot R_x(\\alpha) + R_z(\\gamma) \\cdot \\dot{R}_y(\\beta) \\cdot R_x(\\alpha) + R_z(\\gamma) \\cdot R_y(\\beta) \\cdot \\dot{R}_x(\\alpha)$
%[text] Sostituendo si ottiene
%[text]{"align":"center"} $\\dot{R}_{RPY} =\\dot{\\gamma} \\;\\frac{dR_z}{d\\gamma} (\\gamma )\\cdot R_y (\\beta )\\cdot R_x (\\alpha )+R_z (\\gamma )\\cdot \\dot{\\beta} \\;\\frac{dR_y}{d\\beta} (\\beta )\\cdot R_x (\\alpha )+R_z (\\gamma )\\cdot R_y (\\beta )\\cdot \\dot{\\alpha} \\;\\frac{dR_x}{d\\alpha} (\\alpha )$
%[text] L'obiettivo è calcolare la **matrice di velocità angolare**
%[text] ### $\\mathbf{S}(\\mathbf{\\omega })={\\dot{R} }_{RPY} \\;\\;R_{RPY}^T$
%[text] Ricordando che la trasposta di un prodotto di matrici è uguale al prodotto delle loro trasposte, **ma in ordine inverso**
%[text] ### $R_{RPY}^T =R_X^T (\\alpha )\\;R_Y^T (\\beta )\\;R_Z^T (\\gamma )$
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
%[text]{"align":"center"} $=\\dot{R_z } (\\gamma )R_z (\\gamma )^T +R_z (\\gamma ){\\dot{R} }_y (\\beta )R_y (\\beta )^T R_z (\\gamma )^T +R_z (\\gamma )R_y (\\beta ){\\dot{R} }_x (\\alpha )R_x (\\alpha )^T R_y (\\beta )^T R_z (\\gamma )^T$
%[text] Ponendo:
%[text] $T_z =\\dot{R_z } (\\gamma )R_z (\\gamma )^T \\\\ T_y =R_z (\\gamma ){\\dot{R} }_y (\\beta )R_y (\\beta )^T R_z (\\gamma )^T \\\\ T_x =R_z (\\gamma )R_y (\\beta ){\\dot{R} }_x (\\alpha )R_x (\\alpha )^T R_y (\\beta )^T R_z (\\gamma )^T$
Tz = Rz_dot * Rz_Trasp;
Ty = Rz * Ry_dot * Ry_Trasp * Rz_Trasp;
Tx = Rz * Ry * Rx_dot * Rx_Trasp * Ry_Trasp * Rz_Trasp;

fprintf('Matrice T_z:');

Tz = simplify(Tz);
disp(Tz);
fprintf('Matrice T_y:');
Ty = simplify(Ty);
disp(Ty);
fprintf('Matrice T_x:');

Tx = simplify(Tx);
disp(Tx);
Sw = Tz + Ty + Tx;
Sw = simplify(Sw);
fprintf('Matrice Velocità Angolare Totale (Sw):');

disp(Sw);
%[text] La matrice di velocità angolare si può scrivere come
%[text] ### $\\mathbf{S}(\\mathbf{\\omega })=\\dot{\\gamma} \\;{\\bar{T} }_z +\\dot{\\beta} \\;{\\bar{T} }_y (\\gamma )+\\dot{\\alpha} \\;{\\bar{T} }_x (\\beta ,\\gamma )$
%[text] si nota, quindi, che è lineare nelle derivate degli angoli di Eulero.
Tz_bar = diff(Tz, gamma_dot);
Ty_bar = diff(Ty, beta_dot);
Tx_bar = diff(Tx, alpha_dot);

fprintf('Matrice Tz_bar:');

disp(Tz_bar);
fprintf('Matrice Ty_bar:');

disp(Ty_bar);
fprintf('Matrice Tx_bar:');
disp(Tx_bar);
%[text] La matrice di velocità angolare $S(\\omega )$ è una matrice antisimmetrica legata al vettore $\\omega ={\\bigl\\lbrack \\omega_x ,\\omega_y ,\\omega_z \\bigr\\rbrack }^T$ dalla relazione
%[text] $S(\\omega )=\\left(\\begin{array}{ccc} 0 & -\\omega_z & \\omega_y \\\\ \\omega_z & 0 & -\\omega_x \\\\ -\\omega_y & \\omega_x & 0 \\end{array}\\right)$
%[text] Quindi si possono estrarre i componenti di $\\omega$ dalla matrice $S(\\omega )$ calcolata, cioè
%[text]{"align":"center"} $\\begin{array}{l} \\omega_x =S(\\omega )_{3,2} \\\\ \\omega_y =S(\\omega )_{1,3} \\\\ \\omega_z =S(\\omega )_{2,1} \\end{array}$
%[text] Come si nota dal vettore $\\omega$ appena calcolato, ogni sua componente è una combinazione lineare delle derivate degli angoli di Eulero $\\bigl\\lbrack \\dot{\\alpha} ,\\dot{\\beta} ,\\dot{\\gamma} \\bigr\\rbrack$. L' obiettivo è ricavare la matrice **M** che lega il *vettore* *velocità angolare *$\\omega$ alle *derivate degli angoli*, secondo la relazione:
%[text]{"align":"center"} $\\omega =M(\\beta ,\\gamma )\\;\\;\\left(\\begin{array}{c} \\dot{\\gamma} \\\\ \\dot{\\beta} \\\\ \\dot{\\alpha} \\end{array}\\right)$
%[text] ### Calcolo $\\dot{\\gamma}$
%[text] Per trovare il contributo della velocità di Yaw $\\bigl(\\dot{\\gamma} \\bigr)$, si pongono le altre due velocità a zero: $\\dot{\\beta} =0$ e $\\dot{\\alpha} =0$.
Sw_gamma = subs(Sw, [beta_dot, alpha_dot], [0, 0]);
Sw_gamma = simplify(Sw_gamma);

% fprintf('Matrice Sw Solo Con Contributo gamma_dot:');
% disp(Sw_gamma);

% Estrazione Componenti Vettore omega
omega_x_gamma = Sw_gamma(3,2);
omega_y_gamma = Sw_gamma(1,3);
omega_z_gamma = Sw_gamma(2,1);

% Creazione Vettore Omega Simbolico
vett_omega_gamma = [omega_x_gamma; omega_y_gamma; omega_z_gamma];
vett_omega_gamma = simplify(vett_omega_gamma)/gamma_dot;

fprintf('Prima Colonna di M (Contributo Di gamma_dot):\n');

disp(vett_omega_gamma);
%[text] ### Calcolo $\\dot{\\beta}$
%[text] Per trovare il contributo della velocità di Pitch $\\bigl(\\dot{\\beta} \\bigr)$, si pongono le altre due velocità a zero: $\\dot{\\gamma} =0$ e $\\dot{\\alpha} =0$.
Sw_beta = subs(Sw, [gamma_dot, alpha_dot], [0, 0]);
Sw_beta = simplify(Sw_beta);

% fprintf('Matrice Sw Solo Con Contributo beta_dot:');
% disp(Sw_beta);

% Estrazione Componenti Vettore beta
omega_x_beta = Sw_beta(3,2);
omega_y_beta = Sw_beta(1,3);
omega_z_beta = Sw_beta(2,1);

% Creazione Vettore Omega Simbolico
vett_omega_beta = [omega_x_beta; omega_y_beta; omega_z_beta];
vett_omega_beta = simplify(vett_omega_beta)/beta_dot;

fprintf('Seconda Colonna di M (Contributo Di beta_dot):\n');

disp(vett_omega_beta);
%[text] ### Calcolo $\\dot{\\alpha}$
%[text] Per trovare il contributo della velocità di Roll $\\bigl(\\dot{\\alpha} \\bigr)$, si pongono le altre due velocità a zero: $\\dot{\\gamma} =0$ e $\\dot{\\beta} =0$.
Sw_alpha = subs(Sw, [gamma_dot, beta_dot], [0, 0]);
Sw_alpha = simplify(Sw_alpha);

% Estrazione Componenti Vettore alpha
omega_x_alpha = Sw_alpha(3,2);
omega_y_alpha = Sw_alpha(1,3);
omega_z_alpha = Sw_alpha(2,1);

% Creazione Vettore Omega Simbolico
vett_omega_alpha = [omega_x_alpha; omega_y_alpha; omega_z_alpha];
vett_omega_alpha = simplify(vett_omega_alpha)/alpha_dot;

fprintf('Terza Colonna di M (Contributo Di alpha_dot):\n');

disp(vett_omega_alpha);
%[text] ### Calcolo Matrice M
syms wx wy wz real;

M = [vett_omega_gamma, vett_omega_beta, vett_omega_alpha];
M = simplify(M);

fprintf('Matrice M Completa:\n');

disp(M);
vettVel = [wx; wy; wz];
vettDer = [gamma_dot; beta_dot; alpha_dot];
eqSystem = vettVel == M * vettDer;

fprintf('Sistema Da Risolvere:');
disp(eqSystem);
detM = simplify(det(M));
fprintf('Determinante Matrice M:');
disp(detM);
if detM == 0
    fprintf('Determinante Nullo. Matrice M Non Invertibile');
else
    fprintf('Matrice M Invertibile!');
end
%[text] Questa matrice fornisce la relazione tra $\\omega$ e gli angoli di Eulero. Se $det\\bigl(\\;M(\\beta ,\\gamma )\\;\\bigr)\\not= 0$ allora a partire da $\\omega$ è possibile conoscere la derivata degli angoli di Eulero $\\dot{\\alpha} ,\\;\\dot{\\beta} ,\\;\\dot{\\gamma}$ ed essendo essi integrabili si possono ricavare $\\alpha ,\\;\\beta ,\\;\\gamma$
%%
%[text] ## Interpretazione Delle Singolarità
%[text] Come calcolato, il determinante della matrice di trasformazione è $-\\cos (\\beta )$.
%[text] La relazione $\\omega =M(\\beta ,\\gamma )\\;\\;\\left(\\begin{array}{c} \\dot{\\gamma} \\\\ \\dot{\\beta} \\\\ \\dot{\\alpha} \\end{array}\\right)$ non può essere invertita quando la matrice M è ***singolare***, ovvero quando il suo determinante è nullo.
%[text] Questa condizione si verifica quando l'angolo di *Pitch*, $\\beta$ , è uguale a $\\pm \\frac{\\pi }{2}$ radianti (ovvero $\\pm 90^{\\circ }$) ed è nota come **singolarità di polso **e rappresenta un punto critico. Quando $\\beta =\\pm \\frac{\\pi }{2}$, l'asse di rotazione del *Roll* (asse x del riferimento solidale) si allinea con l'asse di rotazione dello *Yaw* (asse z del sistema di base). Quindi, una rotazione attorno all'asse di *Roll* o una rotazione attorno all'asse di *Yaw* producono lo stesso effetto sul corpo, rendendole indistinguibili. *Il sistema perde un ****grado di libertà (DoF)***.
%[text] Di conseguenza, \underline{per una data velocità angolare }$\\omega$\underline{, non esiste una soluzione unica per le velocità angolari }$\\dot{\\alpha}$\underline{ e }$\\dot{\\gamma}$. Questo rende la rappresentazione RPY inadeguata e instabile in prossimità di queste configurazioni singolari.
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---