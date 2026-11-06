%[text] # Rappresentazione Asse-Angolo
%[text] La rappresentazione Asse-Angolo è un metodo per descrivere l'orientamento di un corpo rigido nello spazio. Utilizza quattro parametri:
%[text] - Un **versore** $\\mathbf{r}=\[r\_X ,r\_Y ,r\_Z \]$ che definisce l'asse attorno al quale avviene la rotazione.
%[text] - Un **angolo** $\\theta$, che indica l'ampiezza della rotazione attorno a tale asse. \
%%
%[text] ## Problema Diretto
%[text] Il problema diretto consiste nel determinare la matrice di rotazione $R\\bigl(\\theta ,\\mathbf{r}\\bigr)$ partendo da un asse $\\mathbf{r}$ e un angolo $\\theta$. La matrice di rotazione si ottiene tramite la *formula di Rodrigues*, derivata dalla composizione di rotazioni elementari:
%[text]{"align":"center"} $R(\\theta ,r)=rr^T +(I-rr^T )\\cos (\\theta )+S(r)\\sin (\\theta )$
%[text] Dove:
%[text] $I$ è la matrice identità 3x3.
%[text] $rr^T$ è il prodotto esterno del versore $\\mathbf{r}$.
%[text] $S(r)$ è la Skew-Symmetric Matrix associata a $\\mathbf{r}$, che rappresenta l'operatore prodotto vettoriale:
%[text]{"align":"center"} $S(r)=\\left(\\begin{array}{ccc} 0 & -r\_z & r\_y \\\\ r\_z & 0 & -r\_x \\\\ -r\_y & r\_x & 0 \\end{array}\\right)$
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
% Definizione variabili simboliche
syms rx ry rz theta real

% Definiamo il versore r come un vettore colonna
r = [rx; ry; rz];
[R] = Compute_Rotation_Matrix(r, theta);

disp("Matrice Di Rotazione R(theta, r):"); %[output:011634d1]
disp(R); %[output:9d0e0575]
%[text] ### Calcoli Numerici Problema Diretto
%[text] Si calcola la matrice di rotazione numerica e successivamente si verificano le proprietà fondamentali.
% Definizione del vettore r e dell'angolo theta numerici
rNum = [1; 2; 3];
thetaNum = 3*pi/5;

% Verifica se il vettore r ha 3 componenti
if numel(rNum) == 3 %[output:group:8e4ef011]
    disp("Il Vettore r Ha 3 Componenti!"); %[output:82e19747]
else
    % Uso 'error' per interrompere l'esecuzione in caso di errore
    error("Il Vettore r Deve Avere 3 Componenti!");
end %[output:group:8e4ef011]
% Verifica se theta è uno scalare
if isscalar(thetaNum) %[output:group:8f7cf566]
    disp("Theta È Uno Scalare"); %[output:1f51c29c]
else
    % Uso 'error' per interrompere l'esecuzione in caso di errore
    error("Theta Deve Essere Uno Scalare!");
end %[output:group:8f7cf566]
% Si controlla che r sia un vettore colonna 3x1
rNum = reshape(rNum, [3, 1]);

% Calcolo della norma di r
norm_rNum = norm(rNum);


if norm_rNum > 0 %[output:group:2af59879]
    % Il vettore r ha una direzione ben definita (non è il vettore nullo).
    % Normalizzo il vettore r per ottenere un vettore unitario che
    % rappresenta l'asse di rotazione.

    disp("Normalizzo Il Vettore r..."); %[output:307b4ae0]
    rNum = rNum / norm_rNum;

    disp("Vettore r Normalizzato:"); %[output:7e9d4b79]
    disp(rNum); %[output:22a05374]
else
    % Se la norma è nulla, il vettore r è il vettore nullo.
    % Non c'è alcuna direzione valida per l'asse di rotazione.
    % Imposto theta = 0 per indicare che non c'è rotazione (R = I).
    disp("Il Vettore r È Nullo. Imposto Theta = 0.");
    thetaNum = 0;
end %[output:group:2af59879]
[R] = Compute_Rotation_Matrix(rNum, thetaNum);

disp("Matrice Di Rotazione R(theta, r) Numerica:"); %[output:372fae49]
disp(R); %[output:52815ece]
%[text] Una matrice di rotazione **R** gode di importanti proprietà:
%[text] 1. **Ortogonalità:** La matrice è ortogonale, ovvero la sua inversa coincide con la sua trasposta $(R^T R=I)$.
%[text] 2. **Determinante Unitario:** $\\det (R)=1$
%[text] 3. \*\*Traccia: \*\*La traccia è legata all'angolo di rotazione dalla formula $\\textrm{trace}(R)=1+2\\cos (\\theta )$. \
checkOrt = R' * R;
disp('Verifica Ortogonalità (R'' * R):'); %[output:29fc68e1]
disp(checkOrt); %[output:878e78c7]
detR = det(R);
fprintf('Determinante Di R: %f\n\n', detR); %[output:56e699aa]
traceR = trace(R);
traceSim = 1 + 2*cos(thetaNum);
fprintf('Traccia Calcolata Di R: %f\n', traceR); %[output:6ab6139f]
fprintf('Valore Atteso (1 + 2*cos(theta)): %f\n', traceSim); %[output:761a9453]
%%
%[text] ## Problema Inverso
%[text] Il problema inverso consiste nel determinare l'asse \*\*r \*\*e l'angolo $\\theta$ a partire da una matrice di rotazione \*\*R \*\*nota.
%[text] Dalla relazione della traccia, si può isolare l'angolo $\\theta$:
%[text]{"align":"center"} $\\textrm{trace}(R)=1+2\\cos (\\theta )\~\~\\longrightarrow \~\~\\theta =\\arccos \\left(\\frac{\\textrm{trace}(R)-1}{2}\\right)$
%[text] Questa formula restituisce un angolo nell'intervallo $\[0,\\pi \]$.
%[text] Per trovare l'asse di rotazione **r**, si sfrutta la parte antisimmetrica della matrice **R:**
%[text]{"align":"center"} $R-R^T =2\\sin (\\theta )\\;S(\\mathbf{r})$
%[text] Da questa relazione, si possono estrarre le componenti di **r**:
%[text]{"align":"center"} $\\mathbf{r}=\\frac{1}{2\\sin (\\theta )}\\;\\left(\\begin{array}{c} r\_{32} -r\_{23} \\\\ r\_{13} -r\_{31} \\\\ r\_{21} -r\_{12} \\end{array}\\right)$
%[text] Questo metodo è valido solo se $\\sin (\\theta )\\not= 0$, ovvero per angoli di rotazione diversi da 0 e $k\\pi$
% Calcolo dell'angolo theta dalla traccia
cosTheta = (trace(R) - 1) / 2;
thetaCalc = acos(cosTheta);

% Calcolo dell'asse r
rCalc = [NaN; NaN; NaN];
sinTheta = sin(thetaCalc);

if abs(sinTheta) < 1e-9
    disp('Theta È 0 o pi. Asse Non È Definito Univocamente Con Questa Formula.');
else
    % Si estraggono le componenti dalla parte antisimmetrica di R
    rVec = [R(3,2) - R(2,3); R(1,3) - R(3,1); R(2,1) - R(1,2)];
    rCalc = (1 / (2 * sinTheta)) * rVec;
end

disp('Valori Input:'); %[output:4f122d76]
fprintf('Theta = %.4f rad\n', thetaNum); %[output:247da971]
disp('Vettore r ='); %[output:71499228]
disp(rNum); %[output:3d7806bd]
disp('Valori Calcolati Dal Problema Inverso:'); %[output:8ef72bf7]
fprintf('Theta Calcolato = %.4f rad\n', thetaCalc); %[output:99d096f0]
disp('Vettore r Calcolato ='); %[output:25cc662c]
disp(rCalc); %[output:0f209d1f]
% Calcolo dell'errore per verificare la correttezza
fprintf('Errore Su Theta: %e\n', abs(thetaNum - thetaCalc)); %[output:2066c78b]
fprintf('Errore Su r: %e\n', norm(rNum - rCalc)); %[output:28dca900]
%%
%[text] ## Visualizzazione Grafica
% Assi Sistema Riferimento
AsseX = [1, 0, 0];
AsseY = [0, 1, 0];
AsseZ = [0, 0, 1];

% Vettore Da Ruotare
v = [1; 0; 1];

% Calcolo Vettore Ruotato
vR = R * v;

% Impostazioni Figura
figure('Name', 'Rotazione Asse-Angolo (Formula di Rodrigues)', 'Color', 'w');
hold on;
grid on;
box on;
xlabel('X', 'FontWeight', 'bold');
ylabel('Y', 'FontWeight', 'bold');
zlabel('Z', 'FontWeight', 'bold');
axis equal;
view(50, 22);

% Disegno Assi Cartesiani di Riferimento
col_X = [0.85, 0.15, 0.15];
col_Y = [0.15, 0.65, 0.20];
col_Z = [0.15, 0.35, 0.85];

h_axX = quiver3(0, 0, 0, AsseX(1)*1.2, AsseX(2)*1.2, AsseX(3)*1.2, 0, 'Color', col_X, 'LineWidth', 1.5);
h_axY = quiver3(0, 0, 0, AsseY(1)*1.2, AsseY(2)*1.2, AsseY(3)*1.2, 0, 'Color', col_Y, 'LineWidth', 1.5);
h_axZ = quiver3(0, 0, 0, AsseZ(1)*1.2, AsseZ(2)*1.2, AsseZ(3)*1.2, 0, 'Color', col_Z, 'LineWidth', 1.5);

text(AsseX(1)*1.25, AsseX(2)*1.25, AsseX(3)*1.25, 'X_0', 'Color', col_X, 'FontWeight', 'bold');
text(AsseY(1)*1.25, AsseY(2)*1.25, AsseY(3)*1.25, 'Y_0', 'Color', col_Y, 'FontWeight', 'bold');
text(AsseZ(1)*1.25, AsseZ(2)*1.25, AsseZ(3)*1.25, 'Z_0', 'Color', col_Z, 'FontWeight', 'bold');

% Disegno Asse Rotazione r
r_scale = 1.6;
h_axis = plot3([-rNum(1)*0.4, rNum(1)*r_scale], ...
               [-rNum(2)*0.4, rNum(2)*r_scale], ...
               [-rNum(3)*0.4, rNum(3)*r_scale], ...
               '--', 'Color', [0.0 0.55 0.55], 'LineWidth', 2.2);
text(rNum(1)*r_scale, rNum(2)*r_scale, rNum(3)*r_scale, '  Asse r', ...
    'Color', [0.0 0.55 0.55], 'FontSize', 11, 'FontWeight', 'bold');

% Disegno Vettore Iniziale v e Ruotato vR
h_v  = quiver3(0, 0, 0, v(1), v(2), v(3), 0, 'Color', 'k', 'LineWidth', 2.2);
h_vR = quiver3(0, 0, 0, vR(1), vR(2), vR(3), 0, 'Color', [0.85 0.1 0.6], 'LineWidth', 2.2);
text(v(1), v(2), v(3), '  v (Iniziale)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
text(vR(1), vR(2), vR(3), '  v_R (Ruotato)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.85 0.1 0.6]);

% Arco 3D di Rotazione Spazzato tra 0 e theta
th_samples = linspace(0, thetaNum, 60);
arc_pts = zeros(3, length(th_samples));
for k = 1:length(th_samples)
    R_k = Compute_Rotation_Matrix(rNum, th_samples(k));
    arc_pts(:, k) = R_k * v;
end
h_arc = plot3(arc_pts(1,:), arc_pts(2,:), arc_pts(3,:), ':', ...
    'Color', [0.85 0.1 0.6], 'LineWidth', 2.0);

% Legenda e Titolo
legend([h_axis, h_v, h_vR, h_arc], ...
    {'Asse di Rotazione r', 'Vettore Iniziale v', 'Vettore Ruotato v_R', sprintf('Arco Rotazione \\theta = %.1f°', rad2deg(thetaNum))}, ...
    'Location', 'bestoutside');
title(sprintf('Rotazione Asse-Angolo: \\theta = %.1f° attorno a r = [%.2f, %.2f, %.2f]^T', ...
    rad2deg(thetaNum), rNum(1), rNum(2), rNum(3)), 'FontSize', 11, 'FontWeight', 'bold');
hold off;

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:011634d1]
%   data: {"dataType":"text","outputData":{"text":"Matrice Di Rotazione R(theta, r):\n","truncated":false}}
%---
%[output:9d0e0575]
%   data: {"dataType":"symbolic","outputData":{"name":"","value":"\\begin{array}{l}\n\\left(\\begin{array}{ccc}\n{\\mathrm{rx}}^2 -\\cos \\left(\\theta \\right)\\,{\\left({\\mathrm{rx}}^2 -1\\right)} & \\mathrm{rx}\\,\\mathrm{ry}-\\mathrm{rz}\\,\\sin \\left(\\theta \\right)-\\sigma_3  & \\mathrm{rx}\\,\\mathrm{rz}+\\mathrm{ry}\\,\\sin \\left(\\theta \\right)-\\sigma_2 \\\\\n\\mathrm{rx}\\,\\mathrm{ry}+\\mathrm{rz}\\,\\sin \\left(\\theta \\right)-\\sigma_3  & {\\mathrm{ry}}^2 -\\cos \\left(\\theta \\right)\\,{\\left({\\mathrm{ry}}^2 -1\\right)} & \\mathrm{ry}\\,\\mathrm{rz}-\\mathrm{rx}\\,\\sin \\left(\\theta \\right)-\\sigma_1 \\\\\n\\mathrm{rx}\\,\\mathrm{rz}-\\mathrm{ry}\\,\\sin \\left(\\theta \\right)-\\sigma_2  & \\mathrm{ry}\\,\\mathrm{rz}+\\mathrm{rx}\\,\\sin \\left(\\theta \\right)-\\sigma_1  & {\\mathrm{rz}}^2 -\\cos \\left(\\theta \\right)\\,{\\left({\\mathrm{rz}}^2 -1\\right)}\n\\end{array}\\right)\\\\\n\\mathrm{}\\\\\n\\textrm{where}\\\\\n\\mathrm{}\\\\\n\\;\\;\\sigma_1 =\\mathrm{ry}\\,\\mathrm{rz}\\,\\cos \\left(\\theta \\right)\\\\\n\\mathrm{}\\\\\n\\;\\;\\sigma_2 =\\mathrm{rx}\\,\\mathrm{rz}\\,\\cos \\left(\\theta \\right)\\\\\n\\mathrm{}\\\\\n\\;\\;\\sigma_3 =\\mathrm{rx}\\,\\mathrm{ry}\\,\\cos \\left(\\theta \\right)\n\\end{array}"}}
%---
%[output:82e19747]
%   data: {"dataType":"text","outputData":{"text":"Il Vettore r Ha 3 Componenti!\n","truncated":false}}
%---
%[output:1f51c29c]
%   data: {"dataType":"text","outputData":{"text":"Theta È Uno Scalare\n","truncated":false}}
%---
%[output:307b4ae0]
%   data: {"dataType":"text","outputData":{"text":"Normalizzo Il Vettore r...\n","truncated":false}}
%---
%[output:7e9d4b79]
%   data: {"dataType":"text","outputData":{"text":"Vettore r Normalizzato:\n","truncated":false}}
%---
%[output:22a05374]
%   data: {"dataType":"text","outputData":{"text":"    0.2673\n    0.5345\n    0.8018\n\n","truncated":false}}
%---
%[output:372fae49]
%   data: {"dataType":"text","outputData":{"text":"Matrice Di Rotazione R(theta, r) Numerica:\n","truncated":false}}
%---
%[output:52815ece]
%   data: {"dataType":"text","outputData":{"text":"   -0.2155   -0.5755    0.7889\n    0.9495    0.0650    0.3068\n   -0.2279    0.8152    0.5325\n\n","truncated":false}}
%---
%[output:29fc68e1]
%   data: {"dataType":"text","outputData":{"text":"Verifica Ortogonalità (R' * R):\n","truncated":false}}
%---
%[output:878e78c7]
%   data: {"dataType":"text","outputData":{"text":"    1.0000    0.0000   -0.0000\n    0.0000    1.0000   -0.0000\n   -0.0000   -0.0000    1.0000\n\n","truncated":false}}
%---
%[output:56e699aa]
%   data: {"dataType":"text","outputData":{"text":"Determinante Di R: 1.000000\n\n","truncated":false}}
%---
%[output:6ab6139f]
%   data: {"dataType":"text","outputData":{"text":"Traccia Calcolata Di R: 0.381966\n","truncated":false}}
%---
%[output:761a9453]
%   data: {"dataType":"text","outputData":{"text":"Valore Atteso (1 + 2*cos(theta)): 0.381966\n","truncated":false}}
%---
%[output:4f122d76]
%   data: {"dataType":"text","outputData":{"text":"Valori Input:\n","truncated":false}}
%---
%[output:247da971]
%   data: {"dataType":"text","outputData":{"text":"Theta = 1.8850 rad\n","truncated":false}}
%---
%[output:71499228]
%   data: {"dataType":"text","outputData":{"text":"Vettore r =\n","truncated":false}}
%---
%[output:3d7806bd]
%   data: {"dataType":"text","outputData":{"text":"    0.2673\n    0.5345\n    0.8018\n\n","truncated":false}}
%---
%[output:8ef72bf7]
%   data: {"dataType":"text","outputData":{"text":"Valori Calcolati Dal Problema Inverso:\n","truncated":false}}
%---
%[output:99d096f0]
%   data: {"dataType":"text","outputData":{"text":"Theta Calcolato = 1.8850 rad\n","truncated":false}}
%---
%[output:25cc662c]
%   data: {"dataType":"text","outputData":{"text":"Vettore r Calcolato =\n","truncated":false}}
%---
%[output:0f209d1f]
%   data: {"dataType":"text","outputData":{"text":"    0.2673\n    0.5345\n    0.8018\n\n","truncated":false}}
%---
%[output:2066c78b]
%   data: {"dataType":"text","outputData":{"text":"Errore Su Theta: 0.000000e+00\n","truncated":false}}
%---
%[output:28dca900]
%   data: {"dataType":"text","outputData":{"text":"Errore Su r: 0.000000e+00\n","truncated":false}}
%---
%[output:9e43a007]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGmCAYAAACeH1cjAAAAAXNSR0IArs4c6QAAIABJREFUeF7t3X2MJGl9H\/DfKiIWCeDDVoKNHTFrEP7L5lAMSQ7hnQ0GE0NYQBbRBd\/tLC+xcYLPrwqgk2cGESCIYM5CyE7O2Zm7IGScwC0yGIzNzGKBI0jCmkgmRsGzRLw4lmyvAwo4TrTZp2dqrra2uru6p6urup5PIbR3O9VPPc\/nV3P73WeeeurU9evXr4eDAAECBAgQIECAwEAFTgm8A62sYREgQIAAAQIECIwEBF43AgECBAgQIECAwKAFBN5Bl9fgCBAgQIAAAQIEBF73AAECBAgQIECAwKAFBN5Bl9fgCBAgQIAAAQIEBF73AAECBAgQIECAwKAFBN5Bl9fgCBAgQIAAAQIEBF73AAECBAgQIECAwKAFBN5Bl9fgCBAgQIAAAQIEBF73AAECBAgQIECAwKAFBN5Bl9fgCBAgQIAAAQIEBF73AIETCnzta1+LV7ziFfHJT35ybEtPf\/rT4\/77749HPepRc1\/tj\/7oj+IlL3lJ3HvvvfGc5zxn7nbGffD3fu\/34u67746vfvWr8Uu\/9EutXGPhna40WDeGecf1m7\/5m\/FjP\/Zj8Z3f+Z3xnve8J77t277tpqsV9fjiF784+v2m56VzX\/jCF8bb3va2RhzvfOc7461vfevxuT\/7sz8bP\/7jP97os304aVE1qX6fTbtHk9vHPvaxW77vUl3f8IY31Na0D176QIBAOwICbzuuWs1IoEngnRSImlDNG9qatF2cs4xrzNKfec5dVLgqt1MXZMtfL\/ezeu6485qG3p\/+6Z+Ohx566BaKVQq9bdRkml\/hVv2LZvGXh3F\/OZnnnvMZAgRWQ0DgXY066WWPBZoG3jSEeYPKEMLoMkq4CKfqjGpdOKoGqnQPpNn3NNtbnr0t2nr0ox8dDzzwQDzlKU+Jut+rs6kbS9PPLsO66TUWUZN0rSZ1Kfok8DatjvMI5CMg8OZTayNtSaAceOt+VF3+0Xfd16uzeONmpcrdLweoulnEahvjZgpTm8W5n\/\/858cuaagL9ZPGktr8iZ\/4iXjVq141WiIxbkau2vdZZt6qfapes\/iR9yyBq86p2qdyPct\/gSkCWdm+Lng17U\/dbGT52tN+pJ\/Mi2UZ6Z+Le2Z3d3c0a1z0sxzWf\/RHfzQ+\/elPj5bn1IX08j1Y95e3NmqSrlke97Oe9axR\/9J9Ve1DdZlJ0d\/nP\/\/58cd\/\/Me3LDua9n1StxSpXNOnPvWp8cu\/\/Mujy6S+POMZz7jpe+hDH\/rQ8Qx92bPsWPf926S2RRvVvwg0\/Yv1pHGs0pKZlv6zrtkBCgi8AyyqIS1XYN7AO+4P53I4Kc8I1gXe9HvFutvqqOuCV53MtMA76cfy1TA4KVhXQ285jI0L8+MqOcmu+MxJAm8KL+lIa2cnLVMoB5O6Nb+TZninhfu6sFy+16b9tKAuCJU96wJv3dfTzHR5DfG40NtWTcrBfVxoL9bGzxt4y6G\/es9Vg2rdPV6cM+n7sfp9nf59Uo2arPOe9Plp98ekcaT\/7jgIDE1A4B1aRY1n6QKzLGkoB6TiD5zyH6jlP7DLgXXcrGDRxrQfo5dRqv0t\/mCsu0b53HJAK59bvnb5D9Gi3fKYijZSf6pLAKb9xaE8hvIf9IVpNezME3g3NzfjxS9+8U1LD2YNvE0CUhrLtFm8aYF3UiAadx+V3eoCb7XvdTPK5TqV79G2apKsqhaf+MQnRg8Ujps1nXVJwyzfi3X3eHFvjlv7Xbap+36r+\/6ddo\/MUpu6\/yhOGsfS\/yPqggSWICDwLgHZJYYt0DTwlv9QG\/dj8brZrDTb0uTH4NXANy0MpGuV+zTrw0V1P3Iv\/hCthsTquZ\/5zGdqA8u0nRFSn8cFrrJdOSw0sau7Q8c94DSuvaLvVfe6WbhxtSn34ySBtzx7Xg7WdXbj1h\/XmVRn5YvAm84tdiqpLgOo68ssNan7Xmm6TKjJQ2uzfi+Ou8eTQXlc5RnWumuMu79m+YtfuUbjajNuZ5hJ4xj2f7GNLlcBgTfXyhv3wgSmBd66Hy1O+gN\/luDZdFlEMdjyH4pNZi7HhbhxwbzpzNp73\/vesT8mT21PCoSTAsEsdtNugEUE3ro2mj54tojAW+c46YG7unt13NKT5FcXeKszzyetybSlGU0eKixCX109Zv1eHHePVwNv+S8adYF3UjuTvjYp5Ja\/Nm0rxKbXmPZ94usEVkVA4F2VSulnbwXqAti4ZQPFIGb9Q3bacoPybO24QFVuoy4I1V1D4J1\/DW8KWcWsZ9PZ\/VlmeCet0ZxUt1kCb3X9dgpxd9xxxy2zueUZ3kUG3ml\/mSy8qstDmv7FK+2tPOv3Yl8Cb9PaTJvhnRaMe\/sfXh0jMKOAwDsjmNMJVAXGzThO2ih\/1h+j1v2hPO6J\/brAOy2Aj5udmhQGJi1pmPaj5HFLGprcXV0vaWi6S8O4EDip9uXxn2SXhnmXNFRDdN0Skzr\/8lgXuaRh0gOTk2YzZwm8s34vLirwnnRJQ9PaCLxN\/qvinBwEBN4cqmyMrQpM+hF73QNbxRu7ZnlQZlrgLWbVytcrz+KWH1AZ97DTtFnkWR5amxZ4U0Hq9q1t+mPWuoeAFvHQ2rTAWXx90ixp3UN847b4KmYm62Zk6+rRdDnEvA+tjQu8adzVvqbfG\/fQWt0Di+U2mq7hnTbecV+fJfCmfs3yvbiowDvuwc+6h\/\/q\/gNW95ea8u9Nm7lt+r3W6n88NU5giQIC7xKxXWqYAtMeMin\/ITTuR9tVmUl7v6Zzq9sz1ckW5zzucY87DpeTzktfq3u18KRZtnH7mE4LvCn0T1qbOW0Hgza3wCqMxs3Apa+PM5nlTWtlo3FLEMp\/USnXbtqWU+nccQ\/LPeYxj4kvfelLtfvwNt3XtuhLeQyLrsm40F52aBIa0\/nF9924B7smbUs2buu9ukA5LshP+6lA3ffltBpP8xZ4h\/nnjVHNLyDwzm\/nkwRGAtMCb3kGqTzLVfBVQ824P6iqAaa6njK1lz77xje+MTY2NkZv\/Up\/aKZttorZ1HkCb3WMRRvTXjxx\/\/33x6SHheqCY5PdC4rrV5dppGBy7733xs\/93M+NXkowz7ZkZZ9JgTedVw0c4\/bVrQsmVbtJa26rdZ8WhMpjqHtI8S1vecvYF09Me8AytZ3OedKTnlS7y8Yia1Lu+7gxj9s2r2pe93BdGsu0faSnvXiifI9X7+dpD60Vdar7y9O0v\/CN++yk2lS\/983w+gMsNwGBN7eKGy8BAlkLCDpZl9\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\/4\/OcjzPAujd2FCBAgQGCFBQTeFS6erucn8NWvRpw7F7G3F\/Et3xLxoQ9FPO1p+TkYMQECBAgQmEVA4J1Fy7kEOhQQdjvEd2kCBAgQWGkBgXely6fzuQiUw24a80MPHc70OggQIECAAIHpAgLvdCNnEOhc4O67Ix588LAbwm7n5dABAgQIEFgxAYF3xQqmu\/kJlMPum94U8ZrX5GdgxAQIECBA4CQCAu9J9HyWQMsCb35zxGtfe3gRYbdlbM0TIECAwGAFBN7BltbAVl1A2F31Cuo\/AQIECPRFQODtSyX0g0BJoLzX7iSYs2cjPvpRdAQIECBAgMAkAYHX\/UGghwICbw+LoksECBAgsLICAu\/Klk7HCRAgQIAAAQIEmggIvE2UnEOAAAECBAgQILCyAgLvypZOxwkQIECAAAECBJoICLxNlJxDgAABAgQIECCwsgIC78qWTscJECBAgAABAgSaCAi8TZScQ4AAAQIECBAgsLICAu\/Klk7HCRAgQIAAAQIEmggIvE2UnEOAAAECBAgQILCyAgLvypZOx4cgcPVqxP5+xNpaxPr6EEZkDAQIECBAoH8CAm\/\/aqJHGQmkVwOnwJuOvT2hN6PSGyoBAgQILFFA4F0itksRqAqcPh2RZnnTcfFixMYGIwIECBAgQGDRAgLvokW1R2AGgVOnHj55aytic3OGDzu1U4F\/95nPxF3ve9+oD3\/72789fvv8+fjmb\/qmTvvk4gQIECBQLyDwujMIdCgg8HaIf8JLn3v3u+P9n\/vcqJVHPeIR8YGXvjS+\/wlPOGGrPk6AAAECbQgIvG2oapNAQwGBtyFUz077wp\/\/efy9+++Pr3zta8c9++fPeEa8+Qd+oGc91R0CBAgQSAICr\/uAQIcC5cCb1u+mdbyO\/gu85rd+K\/7lxz8e3\/6oR8XjH\/3o+M9f+cron3\/3Fa+IJ3zzN98ygOL88hfqAnJ5mURx7gue\/OS4dOedt7RZPbfJsopyUH\/V931ffPJLXxr13Qx1\/+85PSRA4GQCAu\/J\/HyawNwC6WG19NBacQi8c1Mu9YN\/\/hd\/Ec\/a3R0FxRRGf+aOO+J573pXfO0v\/zIefNGL4ke+93tv6k9d2C1OKIfeurA7LvSOa3NS6E5t1c1Mp99vEpaXiuxiBAgQWLCAwLtgUM0RaCog8DaV6td5H\/vCF24KuP\/wu7\/7pgBcno2thuPia8X633JALX6vHD6LYFuegS1fvwjM5SA7aWlF+Tyzuv26r\/SGAIF2BQTedn21TmCsgMC7mjdHeTlDsYShLpim0ZUDb\/r3SWG0\/BDcuGUMqY2665d\/f9JsbTnwTrrGalZGrwkQIDBeQOB1dxDoSEDg7Qh+zGV3rlyJjdtvn9ipcUsCyh+qhtq6pQp1Sw\/KM7dFe3WzsOVgXNfZScsams4E96syekOAAIGTCwi8JzfUAoG5BKqB14sn5mJcyIeuXrsWp++7b9TW9QmbIU9aZ1t0ZNwMa92627pzpwVkgXchJdcIAQKZCQi8mRXccPsjkF4pnF4tXBwCbze1SWH3wqVLsV+88i699e7cudrZ3mlhsxhB3cNr5dGVQ+2kc+vW645b0tBEzwxvEyXnECAwRAGBd4hVNaaVEfBq4e5LtX3jbx5bly8fdyQta0iBt3pMW\/9a9\/Vxn6kG2dc+85nHD76VZ33rPl8Xgsc9HDdpDPYN7v7e0wMCBJYnIPAuz9qVCNwiIPB2e1OUlzKknqzddlsc3HNPbafKSxLGzcoWM8DltbeTtiUrr7edtFyiupZ33EzztJ0XzPB2e7+5OgEC3QkIvN3ZuzKB0T68xU\/SLWlY7g2Rwu7Z3d1IvxZhN83srq+t3dKR8gzqpIfCyqG1PINa90Ba3frduofixl2vGpCn7cGbBiXwLvceczUCBPojIPD2pxZ6kqGAwNtd0dO63bQzQ3FsnTkTm+vr3XXIlQkQIECgNQGBtzVaDROYLiDwTjdq44wUdFPgLY40q7t3\/nwbl9ImAQIECPRAQODtQRF0IV8BgXf5ta9bt5vCblq\/6yBAgACBYQoIvMOsq1GtiIDAu9xC1W1BlsJu3brd5fbM1QgQIECgTQGBt01dbROYIiDwLvcWaboF2XJ75WoECBAg0LaAwNu2sPYJTBAQeJd7e5za3j6+4KQtyJbbK1cjQIAAgbYFBN62hbVPQODt3T2QXiM8bguy3nVWhwgQIEDgxAIC74kJNUBgfgEzvPPb+SQBAgQIEGgqIPA2lXIegRYEBN4WUDVJgAABAgQqAgKvW4JAhwICb4f4Lk2AAAEC2QgIvNmU2kD7KCDw9rEq+kSAAAECQxMQeIdWUeNZKQGBd6XK1bizr371q+PSpUuxt7cXT3ziE48\/98UvfjHOnj0bz3nOc+Id73hHnDp1qnGbTiRAgACB+QUE3vntfJLAiQUE3hMT9rKBj33sY\/G85z0v3vnOd8Zdd9113MeHHnooXvrSl8b73ve+Ueh1ECBAgMByBATe5Ti7CoFaAYF3mDfGtWvX4od+6Ifi8Y9\/fLz73e+ORzziEXH9+vW4cOFCfPazn40PfehD8djHPnaYgzcqAgQI9FBA4O1hUXQpHwGBd3Vrvb+\/Pwqwa2tro6UL1ePnf\/7nY2dn53hZQ7Gc4c4774zXv\/71qztwPSdAgMAKCgi8K1g0XR6OgMC72FqmVwdvrq8vttGa1rZvvLFta2tr9JUUeA8ODm4561Of+lQ897nPjbe\/\/e2jZQ1pOcPLXvay+PVf\/\/W44447Wu+jCxAgQIDAwwICr7uBQIcCAu\/i8PevXo2zu7ujBq9vbi6u4VJLV69ejd0b1yjCbvpS+ufNmut9\/etfjxe\/+MVx2223xQMPPBCvfOUr43Of+1x88IMfHP2egwABAgSWJyDwLs\/alQjcIiDwLuamuHrt2ijspl9Hs6633RYH99yzmMaPWklhN+2wkH4tjnGzu8XXf\/EXf3E0w5uWNrz85S8f\/f81r3nNQvulMQIECBCYLiDwTjdyBoHWBATexdBeuHQpdq5cOW5s68yZhS5tqAu76WJp7e76hCUUv\/\/7vx\/PfvazR+ekcz\/84Q\/H93zP9yxm0FohQIAAgcYCAm9jKicSWLyAwHty0xR0U+Atjo3bb4+L586dvOGjFtLsbHo4rXpsbGzExYsXJ17nG9\/4RvzwD\/9wfOADHxit533ve98bj3zkIxfWNw0RIECAQDMBgbeZk7MItCIg8J6MNS1hOH3ffceNpKUMe+fPj5Y0LOJIM7unU5FKR7F+93y6ztra1Ms8+OCDcffdd4\/25H3Vq1419XwnECBAgMDiBQTexZtqkUBjAYG3MdUtJ6awm2Z208Nq6UghN83srjcIoU2vmgJvmt1NW5ClY9wDak3bcx4BAgQIdCMg8Hbj7qoERgIC7\/w3QtqCbOvy5eMG2li3Ww67TZYwzD8anyRAgACBNgUE3jZ1tU1gioDAO98tUl23u+hdGdLMbtprN63fTYewO1+dfIoAAQJ9ERB4+1IJ\/chSQOCdvex1W5Atet1uea\/daVuPzT4CnyBAgACBZQsIvMsWdz0CJQGBd7bbobpuN306rdtNOzMs6mjyFrVFXUs7BAgQILAcAYF3Oc6uQqBWQOCd7caorttd9BZkwu5s9XA2AQIEVkVA4F2VSunnIAUE3tnLemp7e\/ShRa\/brYbd9KKIJtuOzT4CnyBAgACBZQsIvMsWdz0CJQGBd\/7bIW1HtqgtyITd+evgkwQIEFgFAYF3Faqkj4MVEHi7L62w230N9IAAAQJtCwi8bQtrn8AEAYG329uj\/NrgtHzBMoZu6+HqBAgQaEtA4G1LVrsEGggIvA2QWjqlGnYvXrwY6+vrLV1NswQIECDQpYDA26W+a2cvIPB2cwukVwWfPXt2dPE0syvsdlMHVyVAgMCyBATeZUm7DoEaAYF3+bdFeova6QQv7C4f3xUJECDQkYDA2xG8yxJIAgLvcu+DathNrwze3NxcbidcjQABAgSWLiDwLp3cBQk8LCDwLu9uSGE3LWNIv6Zja2tL2F0evysRIECgUwGBt1N+F89dQOBdzh0g7C7H2VUIECDQVwGBt6+V0a8sBATem8u8c+VKXLh0afSb1xe01EDYzeJbySAJECAwUUDgdYMQ6FBA4H0Y\/+q1a3H6vvuOf2MRrw4Wdju8uV2aAAECPRIQeHtUDF3JT0DgPax5Crtnd3dHv6Yjhd2L586d6NXBKexeuHAh0hZk6bBmN7\/vLyMmQIBAISDwuhcIdCgg8B7ib98IpVuXLx9XYuvMmdg8wUsgqmE37caQ9tp1ECBAgECeAgJvnnU36p4ICLwR5XW7xezuwT33zF0hYXduOh8kQIDAYAUE3sGW1sBWQSD3wFu3bnfv\/PnRkoZ5jhR2d3d3R8sX0mFmdx5FnyFAgMDwBATe4dXUiFZIIOfAm8Ju2pFh\/2hf3FS2tG534\/bb56pgNeymVwYfHBzM1ZYPESBAgMCwBATeYdXTaFZMIOfAW123m4JuCrzzHtvb28czu8LuvIo+R4AAgWEKCLzDrKtRrYhAroE3zeqmXRmK46RbkFXD7t7eXqTQ6yBAgAABAklA4HUfEOhQIMfAu+gtyITdDm9glyZAgMCKCAi8K1Io3RymQI6Bd\/Q37RvLD4rjJFuQCbvD\/L4wKgIECCxaQOBdtKj2CMwgkGvgLULv+tpapF0Z5jl2dnZGL5ZIR1q+YBnDPIo+Q4AAgTwEBN486myUPRXIOfCmkqTlDfNsQSbs9vSG1i0CBAj0VEDg7WlhdCsPgdwD7zxVrobd9Aa19RO8lW2ePvgMAQIECKyWgMC7WvXS24EJCLyzFTTttXs6oR0tYxB2Z\/NzNgECBHIVEHhzrbxx90JA4G1ehmrY3dzcHL1JzUGAAAECBKYJCLzThHydQIsCAm8z3GrYTUE3BV4HAQIECBBoIiDwNlFyDoGWBATe6bAp7J49ezbSr+nY2toSdqezOaNNgddHxLi\/b\/21iHhGRLw1Ir630on\/FRH\/ICL+WUTc2WYHtU2AQFVA4HVPEOhQQOCdjC\/sdnhzuvR4gRR43xwRr4mIJ5ZO+78R8dsR8R8i4q\/fCL4fiYinRMSfRcQ\/iojvi4hPHv3elYj4uxHxL0ATILAMAYF3GcquQWCMgMA7\/tYQdn3b9FYgBd5\/FREfPgqt1Y4+EBGviIhXH513PSL+61FI\/vcR8a1HX3tlRPyN3o5SxwgMSkDgHVQ5DWbVBIYYeOfdW7dcO2F31e7kzPo7LfD+j6NlDXdExK8e2fzviPgnEfHfIuJ\/RsRbjpY1pCD89yPi7qNwXKZM17nvaNb49syMDZfAggUE3gWDao7ALAJDDLwXLl2KnStX4vqcD5WlsJveoLa\/vz+itGZ3ljvKuUsRmBZ4PxoRz4+IH4mIf33Uo89GxM9ExDsiIt3a\/yki3hYRfyUiXnxjRviLEfFbR7O\/6SPFet+0Jvj9EfHIpYzMRQgMVkDgHWxpDWwVBIYWeFPQTYG3OGZ9dXA17KbdGNJeuw4CrQukZyLT\/9ciYvvoobT0z3XHuMD7\/yLiv0TEy2\/M2P5hRKRvhWc16PluRPzTo2CbZnvT8R8j4gc5EfPwAAAeOUlEQVQj4hci4mUN2nAKAQITBQReNwiBDgWGFHjTUobT96Wfvx4e6ZXBe+fPN351sLDb4Y2Y66V3IuLyUdA9\/IHC4ZHW3KavjdvmedIuDenzf\/PG\/995NHN7qgHuf7\/Rj7MR8ZLSsoZ0jX8TEXsR8aQGbTiFAAGB1z1AoK8CQwm8Keymmd39o63DkncKu2mGt8mRwu7u7u5o+UI60quC9\/bSn\/QOAgsQSDO3KdCmcJt+YFD8+4UxbafAm7427ocL1V0a0u4MHziaoU2zu2kHh0fP0O90vX98tL43LWt4xNH2ZY87WgOc\/t1BgMCJBMzwnojPhwmcTGAogXf7xnrbrcspTRweG7ffHhfPnWuMs729fRx219bW4uDgoPFnnUhgokCTGdZxDaTbsO7vbHVLGlJofcONhtLf2V4aEfdHxF+doTZpne75o2UQ6XNpv963H\/3eDM04lQCBegGB151BoEOBIQTeNKt79sbsbHGkpQwH99zTWFXYbUzlxFkEijW5aab28J0lzY8UclPYLdb0Vj85bg3v\/znajuxdR8H33hvrgZsG7q+kH21ExItu7OCQHlT7tzfW\/\/5ORPyt5t12JgEC4wUEXncHgQ4FVj3wpqUMKeymX9ORwm6a2W26lKEadtMyhjTD6yBwYoGmQXN045bCbVq3O+2t1ZN2aUgPq6WHzf40In4jIp4+w0jStmW\/e3T+3zlawzvLOGa4lFMJ5CYg8OZWcePtlcCqB94UdsvrdrfOnInN9TRNNf0QdqcbOaOBQHV9bvGRJkExhdszRw+npTW+zW7diGnbkhUvnkj78KalCo9pMI50ygcj4oVH56YXVLyg4eecRoDAVAGBdyqREwi0J7DKgbe6Bdks63aF3fbuqWxaTrsopJU01d0VygCTQm+xbGEesGmBNy1tSOtx33O0127TFT5\/EhE\/cOOVxd84esAu7fbgIEBgIQIC70IYNUJgPoFVDbx1W5A1Xbe7s7MzerFEOtLyBcsY5rt3svtUdT1tXZhND45VA28KtsX2YumBsuLfpy1byA7YgAkMW0DgHXZ9ja7nAqsYeE+ybrcadtNLJdIWZA4CtQJp9raYxU2Btxxox83els+phuRZli0oCQECgxIQeAdVToNZNYFVDLyF8akbW4mlo+m63fSq4LNn0+76hzO7wu6q3a0d9HfaLG7x9TRrm\/7eVKzH7aCrLkmAQL8FBN5+10fvBi6wyoE3lSa9Wa3JUob0YonTabDC7sDv6DmGVzx0VszkTpvFLX89rYxJa2X9kGAOeB8hkJeAwJtXvY22ZwKrHnibcFbD7sbGRmxuWkDZxG7w56QJ\/\/JDZ2nAdetwC4iTPGg2eEwDJEBgkoDA6\/4g0KHA0ANvCrtpGUP6NS1jEHY7vNm6vHTxEoj0Mr7y33WmLVkY\/Rjh6KGztFzBTG6XVXRtAistIPCudPl0ftUFhhx4y2E31Wlra8vM7qrfsLP2P20dlkJu+rU4pi1ZMIs7q7LzCRBoICDwNkByCoG2BIYaeIXdtu6Ynrdb9yre6izuuK3DPHTW8+LqHoHVFhB4V7t+er\/iAkMMvMLuit+Us3Z\/0kNnqa1pyxZsFTaruPMJEJhDQOCdA81HCCxKYGiBV9hd1J2xIu3UPXSWuj5u2YKXPqxIYXWTwPAEBN7h1dSIVkhgSIE3hd30BrW032460gNqaa9dxwAEiofOiq3DDkpjmjaDm05Na3jTkoUUeB0ECBDoQEDg7QDdJQkUAn0NvOltamu33da4UMJuY6rVOzHtdVt+6GzSDG76mofOVq\/GekwgAwGBN4MiG2J\/BfoYeFPYvXDpUuxfvRrXG+yXm8Lu7u7uaBcGM7v9vdca9axYj7tROXvSg2fpa8WbzrwEohGzkwgQWL6AwLt8c1ckcCzQx8C7fWNJwtbltJfU4TEp9FbDbtpr9+Cg\/PNuxe69QAq5xVKF4iUQk17+cHxj9H5kOkiAAIFjAYHXzUCgQ4G+Bd6dK1dGs7vFkZY1THp18Pb29vHMrrDb4Y00y6WrW4fVrcEd\/U2n1GhxTvHQmZdAzCLuXAIEeiAg8PagCLqQr0CfAm9aynB2dzfSr+lIYXfv\/Pmxa3mF3RW6b4ulCsVLIGadwU1reKvLHFZo+LpKgAABgdc9QKBDgb4E3vK63YLj4rlzsXH77bU61bC7t7c3enWwo6cC03ZSKH+9WI9rg42eFlO3CBCYR0DgnUfNZwgsSKAvgbe6bjcF3RR46w5hd0HFb6OZ8ksg9koXmBZ4Tx9tG+ahszaqok0CBHogIPD2oAi6kK9AHwJvmt09fd99x0WYtG5X2O3pvbp9I7CmB86Kh85SN6ctW6h+vadD0y0CBAgsQkDgXYSiNgjMKdB14K1bt5tmdtdrlifs7OyMXiyRjrR8wTKGOYt+0o8VL4FIL3IojmkzuOm8NItb3j7MCpSTVsLnCRBYIQGBd4WKpavDE+g68KYdGdLODMWxdeZMbK6Xk9ThV6phN71Bbb3mvOFVqEcjSg+OFQ+dpW6Ne31vuctmcXtUQF0hQKBLAYG3S33Xzl6gy8Bb3YIszeqmXRmqR9pr93Tq6NHMrrDb0W07bRa3vHVY+juL9bgdFcplCRDoo4DA28eq6FM2Al0G3lM39tAtjnFbkAm7S74Vyy+BKD109qX4UnzHqe+4tTNHM7ifjk\/HR7Y\/Er9x5jfiy+tfjj+IP1hyx12OAAEC\/RYQePtdH70buECXgTfRFqE3zexW1+1Ww+7GxkZsNnjV8MBL1t7wzlYeOktXmrRsIa3BPXqp3TPiGfGJ+EQ8Mh4ZvxK\/EnfGne31U8sECBBYQQGBdwWLpsvDEeg68I6TTGH37NmzkX5Nx9bWlrC7qNuu\/BKI8l6305YsRMQHL3wwfu3Mr8WvbvzqcbB9d7w7Xh4vj6\/H1+OuuCseiAcW1VPtECBAYDACAu9gSmkgqyjQx8Ar7LZ0J1UfOps2g1v9ekSkpQvPjmfHn8SfxB1xR3w8Ph7F7O6T48nx0fhofEfULH1oaUiaJUCAwKoICLyrUin9HKRA3wKvsLvA2yzN5Fa3\/qrO4tYtWShvHXbrhhnxpnhTvC5eN+poCr2WMiywZpoiQGCwAgLvYEtrYKsg0KfAK+wu4I4pP3SWXgIx7eUP1Vnc9JmakFvtWTGrW\/x+Mdu7gBFoggABAoMUEHgHWVaDWhWBvgTeFHbTSyX29w9f1WXN7hx3UNq57XDJ883HuFncYiZ3c\/ZrlZc2fGt8a3wkPhJPjafO3pBPECBAIBMBgTeTQhtmPwX6EHirYTftxpD22nWMESg\/dJbW5U55AcTV61djrby2IX1m4+S6xSyv2d2TW2qBAIHhCwi8w6+xEfZYoOvAK+zOeHPUbB2WAm3xv41TNyfZq2tX4\/TB6diLvVhvslZhhu4IvDNgOZUAgewFBN7sbwEAXQp0GXhT2N3d3R0tX0hHelXw3l7pbQddwvTh2sV63PKSg5qtw05df\/g3r5+6Hink7q\/vx+753dGv6diKrdiMOdYuTHAQePtwk+gDAQKrIiDwrkql9HOQAl0G3u0bb1orwu7a2locHBy9xWCQ0g0HVX3oLH1syoNn5cBbd5W0nCHN8N60rKFhdyadJvAuAFETBAhkIyDwZlNqA+2jQFuB9+q1a3H6vvtGQ75e83Y0YffobqhuHVYzg1ssWbgcl2M\/9mPv1N5oFjf9P83i7mykRbm3HingplndjUUs2K1pX+Dt43e0PhEg0FcBgbevldGvLATaCLwp7F64dCn2j96SVg291bCbljGkGd5sjhkfOksu5VncjZ2NW0JuCrdpHW862g662dTJQAkQILBAAYF3gZiaIjCrQBuBd\/vG1mJbly8fd2Xj9tvj4rlzo3\/PPuyO0uutVSrP4m6eenitbbEe98LFCzd9qFiekGZvz8SZ0QNp27F9\/M+z3gfOJ0CAAIF2BQTedn21TmCiwKIDb5rVPXvjQbTiWLvttji45548w255PW75WbwpD54dnD6I3Y3d2D+zf\/zQWTFzm4JtCrhtLVPw7UKAAAEC7QgIvO24apVAI4FFBt60lCGF3fTrKKDddttoZnd9bS12dnZGL5YY\/f7a2mg3hsEuY0jDTJsjlF8CcT396+Fv7MZuVGdx09ZhdUeayS3P4jYqqpMIECBAoHcCAm\/vSqJDOQksMvCmdbs7V64c822dOROb6+vDDrvFetzy9rc1M7gXrl+InXj44bI0i5u2DLt85vJN63FTwDWLm9N3oLESIJCLgMCbS6WNs5cCiwq8KeimwFscaVZ37\/z5W8JueoNa2m93pY8i5KaVG4fb3B5vHZZmcddO1T+AN277MLO4K3036DwBAgQaCQi8jZicRKAdgUUE3vIWZKmXaSlDCruRtiZLFzhaxjCIsFuUoTKLu3N9J9K2YcUsbnoBRDrqXgJhFrede1mrBAgQ6LOAwNvn6ujb4AVOGnjrtiBLYTfNcZbD7sbGRmzW7Mfba+BxD52lTk958Gxre+umh87M4va60jpHgACB1gUE3taJXYDAeIGTBt7qFmRp3e75tbXVDrvpobOadzmUZ3GLGdxiFjfN5J7dO3sMbRbXdx0BAgQIlAUEXvcDgQ4FThJ4q+t2R0sZzp2Ls2fPxtWjl06kVwf3ema3\/BKIi6VCTJnBTWdevHDxpofOipB7Ps6PHjxzECBAgACBQkDgdS8Q6FDgJIE3dfvU9vao96MtyM6ciQsvetFqhN00g1t+6Cytt71+dfTq3rQW9+Kpcvo9LFD1obPyLG4KuMXLIDosp0sTIECAQE8FBN6eFka38hA4aeAtQu\/WU54SOz\/1U\/0Nu2kmt7p5QmUWtxxoyw+dlV8CYRY3j+8LoyRAgMCiBQTeRYtqj8AMAosIvGn5Qu+WMaSAW37oLP3z0csfms7iru+vx9X1q8f74hZhdwZepxIgQIAAgaOfEl6\/frh\/j4MAgaULnDTwprCb3qC2v3+4IW1v1uzWrME9e\/3saMlCcVS3DiteAmEWd+m3oQsSIEBg8AJmeAdfYgPss8BJAm817Katx9Jeu0s9yi+B2Du8cnr5Qwq2G6fKrz87\/Fp52ULx0Nn+xv5o\/W162Mws7lKr52IECBDIRkDgzabUBtpHgXkDbwq729vbozeppaOTsJt2AXt4wnbUj\/IsbnnrsFEQXrsapw+OXoRx9ApfOyr08a7UJwIECAxPQOAdXk2NaIUE5gm8Kezu7u6Oli+kY21tLQ4ODtoddbEed\/PhWdy6V\/hWHzxLITc9dHb1zNXRelyzuO2WSesECBAgUC8g8LozCHQoME\/gTTO7Swm7afL48s0vgUgvf9iN3eO1uNVZ3HLgXb+6PgrjZ+JMbMStyxs6ZHdpAgQIEMhMQODNrOCG2y+BWQNvq2G3unVYg5c\/pMCbZnH31\/fjC2e+EGk9btoTN4VcL3\/o172mNwQIEMhZQODNufrG3rnALIG3Gnb39vZGM6gnOsoPne1Pf\/lDulZ5FndjfyPSS83M4p6oCj5MgAABAi0LCLwtA2uewCSBSYF3P+2vu7sb1zc3Rw+olZcxLCTsjtLrrb2rewFEOms0k7uxH7ubu2Zx3dYECBAgsFICAu9KlUtnhyYwLvBevXZtFHbTr5H22D3aZzfN6M4cdouXQKT1uJsPbxvW5BW+B6cPRiE3ztzYkWE9rMUd2g1oPAQIEMhEQODNpNCG2U+BcYE3hd00wxtXrkQ89NCo83OF3Qs3P3Q2mtS9\/vC0bt3WYWcP0n5jh+HWWtx+3jd6RYAAAQKzCQi8s3k5m8BCBeoC786VK3Hh0qVbwm56qcT6+vr46xfrcTeav\/whNZZmcdOWYWkW9+rGVbO4C62wxggQIECgDwICbx+qoA\/ZClQD7\/oLr8Xp++67kTyvRhy9VCLN7I4Nu8X+uOkFEEcvgZj08ofyDG96q5lZ3GxvPQMnQIBAVgICb1blNti+CZQD79YvXIv9x16K\/bSM4e1vH3V1Utgd9wrfsUsW1g5ncNNM7tr6CXd36Buk\/hAgQIAAgQkCAq\/bg0CHAuXAu\/6TV2I\/dm8Ku+mVwZvnNw9nb49eArF9fXv04of0v3RU1+FWZ3H3dvZGD5ydeAuzDp1cmgABAgQInERA4D2Jns8SOKFAOfDG+m7ElZ+MSDsz3DjSNmSbVzcj0hvPKsekWdwUbncu7liLe8La+DgBAgQIDEdA4B1OLY1kBQUeDrxpMW7aHSH9mtJuxPrm+mgWd9IMbjo1rcU9uHAQcf5w6zAHAQIECBAgcLOAwOuOINChwGHgvTnsbt1Iu1vXt457VRd4L1y\/4O1mHdbNpQkQIEBgtQQE3tWql94OTOAw8KaZ3cP1uBu3\/WRcvPYLt+6VWzxjthHHL4EYGIXhECBAgACB1gQE3tZoNUxgusCNNwbH1f2dWNu\/EE8YvexhFHvjwsWdiI2HX\/yQli04CBAgQIAAgfkEBN753HyKwOIELlw43nP3pkbXbuwjtrERsbm5uGtpiQABAgQIZCgg8GZYdEPumUBaw5umeo9eNFHbu62tiPPn095iPeu87hAgQIAAgf4LCLz9r5Ee5iKQgu\/ubtqPbPyIzfrmcjcYJwECBAgsUEDgXSCmpggsTCDN+O7vH\/6\/7iiCr1nfhZFriAABAgSGKyDwDre2RjYEAbO+Q6iiMRAgQIBAxwICb8cFcHkCjQWKdb6jfXtrDrO+jSmdSIAAAQJ5CQi8edXbaIcg0HTWN+3ukHZ5cBAgQIAAgcwFBN7MbwDDX2GBIvim3R2mzfra2myFC63rBAgQIHBSAYH3pII+T6APAk1mfdNs75kzZn37UC99IECAAIGlCgi8S+V2MQItC5j1bRlY8wQIECCwigIC7ypWTZ8JNBHwQosmSs4hQIAAgQwEBN4MimyImQs0We7ghRaZ3ySGT4AAgWELCLzDrq\/REbhZID3gdvny+NcY29rMHUOAAAECAxQQeAdYVEMiMFXArO9UIicQIECAwHAEBN7h1NJICMwn4IUW87n5FAECBAisjIDAuzKl0lECLQs0nfX1QouWC6F5AgQIEFi0gMC7aFHtEVh1AVubrXoF9Z8AAQIEKgICr1uCAIHxAk1mfdfXI86f90IL9xEBAgQI9FZA4O1taXSMQI8EzPr2qBi6QoAAAQKzCgi8s4o5n0DuAl5okfsdYPwECBBYOQGBd+VKpsMEeiLQZLmDF1r0pFi6QYAAgbwFBN6862\/0BBYj4IUWi3HUCgECBAi0IiDwtsKqUQKZCpj1zbTwhk2AAIF+Cwi8\/a6P3hFYXQEvtFjd2uk5AQIEBiYg8A6soIZDoHcCTWd9vdCid6XTIQIECAxFQOAdSiWNg0DfBWxt1vcK6R8BAgQGKyDwDra0BkagxwJmfXtcHF0jQIDA8AQE3uHV1IgIrI6AWd\/VqZWeEiBAYIUFBN4VLp6uExiUQNMXWpw5E5FeZ+wgQIAAAQINBQTehlBOI0BgSQJNlztsbESkB90cBAgQIEBgioDA6xYhQKC\/Ak1nfc+fj0hvdXMQIECAAIEaAYHXbUGAQP8FzPr2v0Z6SIAAgR4LCLw9Lo6uESBQI+CFFm4LAgQIEJhRQOCdEczpBAj0RMCsb08KoRsECBDov4DA2\/8a6SEBAtMEzPpOE\/J1AgQIZC0g8GZdfoMnMDCBprO+XmM8sMIbDgECBCYLCLzuEAIEhicwywstnvCEiDRDfPGi\/X2HdycYEQECBEYCAq8bgQCBYQs0mfUtBLa27O077LvB6AgQyFRA4M208IZNIDuBpsE3vcVtby87HgMmQIDAkAUE3iFX19gIELhZIIXe06enq6SXWKTQO+\/LLC5dinjhCw+v88Y3Rrz2tQ9f801vinjd6w7\/\/aGHIs6dm94fZxAgQIDAiQQE3hPx+TABAisnUMz0po6nJQzjjhR402zvvMfdd0c8+GDEYx8b8eEPRzztaRGf+lTED\/5gxJ\/9WcRdd0U88MC8rfscAQIECMwgIPDOgOVUAgQGKJAC8P5+xBe+ELGzE5H+Pc3sHhycbLBf\/nLEM58Z8Yd\/eBic3\/WuiJe+9PBa3\/VdEb\/zOxGPf\/zJruHTBAgQINBIQOBtxOQkAgQIzCFQXtpQ\/rilDHNg+ggBAgTmFxB457fzSQIECEwXKJY2FGdayjDdzBkECBBYsIDAu2BQzREgQOAmgfK6XUsZ3BwECBDoREDg7YTdRQkQyEagvCtDGnR114ZsIAyUAAEC3QkIvN3ZuzIBAkMXKM\/uFmMt79ow9PEbHwECBHoiIPD2pBC6QYDAwAS++tWIF7zgcFeGFHLf8IaIe+893JIs7drw\/vdHPPrRAxu04RAgQKCfAgJvP+uiVwQIrLpAeSlDsYyh7vdWfZz6T4AAgRUQEHhXoEi6SIDAigmUlzKUZ3Ors77FCylWbHi6S4AAgVUTEHhXrWL6S4BAvwWmhdpqGE5vdHMQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KiDwtsqrcQIECBAgQIAAga4FBN6uK+D6BAgQIECAAAECrQoIvK3yapwAAQIECBAgQKBrAYG36wq4PgECBAgQIECAQKsCAm+rvBonQIAAAQIECBDoWkDg7boCrk+AAAECBAgQINCqgMDbKq\/GCRAgQIAAAQIEuhYQeLuugOsTIECAAAECBAi0KvD\/AaLemg2\/JSj\/AAAAAElFTkSuQmCC","height":337,"width":560}}
%---
