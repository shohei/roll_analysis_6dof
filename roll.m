clear; close all;

m = 2.0;%kg
I_x = 0.000192;%openrocket
I_xz = 0;%
I_z = 0.001048;%

M = [m     0    0 0 0;
     0  I_x -I_xz 0 0;
     0 -I_xz I_z  0 0;
     0     0    0 1 0;
     0     0    0 0 1];

b = %スパン長
U0 = 100;%飛行速度 100m/s
rho = 1.293;%kg/m3
S = ;%翼面積

%FROM DATCOM
C_yb = ;%CYB in DATCOM
C_lb = ;%CLLB in DATCOM
C_nb = ;%CLNB in DATCOM
C_yp = ;%CYP in DATCOM
C_yr = ;%CYR in DATCOM
C_lp = ;%CLLP in DATCOM
C_nr = ;%CLNR in DATCOM
C_np = ;%CLNP in DATCOM
C_nr = ;%CLNR in DATCOM

Y_b = rho*U0^2*S/(2*m)*C_yb;
L_b = rho*U0^2*S*b/(2*Ix)*C_lb;
N_b = rho*U0^2*S*b/(2*Iz)*C_nb;
Y_v = Y_b/U0;%横滑り角βと速度vの関係より
L_v = L_b/U0;%横滑り角βと速度vの関係より
N_v = N_b/U0;%横滑り角βと速度vの関係より

Y_p = rho*U0*S*b/(4*m)*C_yp;
Y_r = rho*U0*S*b/(4*m)*C_yr;
L_p = rho*U0*S*b^2/(4*Ix)*C_lp; 
L_r = rho*U0*S*b^2/(4*Ix)*C_nr;
N_p = rho*U0*S*b^2/(4*Iz)*C_np; 
N_r = rho*U0*S*b^2/(4*Iz)*C_nr;

We = 1;
Ue = 1;
g = 9.8;

theta_e = 0;
Aprime = [Y_v Y_p+m*We Y_r - m*Ue m*g*cos(theta_e) m*g*sin(theta_e);
          L_v -L_p     L_r        0                0;
          N_v N_p      N_r        0                0;
          0   1        0          0                0;
          0   0        1          0                0];

Y_xi = 1; Y_zeta = 1;
L_xi = 1; L_zeta = 1;
N_xi = 1; N_zeta = 1;

Bprime = [Y_xi Y_zeta;
          L_xi L_zeta;
          N_xi N_zeta;
          0    0;
          0    0];

A = inv(M)*Aprime;
B = inv(M)*Bprime;

C = [0 1 1 1 1];
D = 0;
