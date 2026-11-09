function [R] = Compute_Rotation_Matrix(r, theta)

% Costruzione della matrice antisimmetrica S associata al prodotto vettoriale
S = [
    0, -r(3), r(2); 
    r(3), 0, -r(1); 
    -r(2), r(1), 0
];

% Calcolo della matrice di rotazione R usando la formula:
% R = r*r^T + (I - r*r^T) * cos(theta) + S * sin(theta)
A = r * r';
R = A + (eye(3) - A) * cos(theta) + S * sin(theta);

end