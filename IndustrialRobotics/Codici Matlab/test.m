clc; clear; close all;
% Definizione variabili simboliche
syms rx ry rz theta real

% Definiamo il versore r come un vettore colonna
r = [rx; ry; rz];

disp(r * r.')

syms r11 r12 r13 r21 r22 r23 r31 r32 r33


% Matrice Rotazione Simbolica
R = [r11 r12 r13; r21 r22 r23; r31 r32 r33];

disp(R - R.')