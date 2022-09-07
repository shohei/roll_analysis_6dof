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

%注意：DATCOMではFeetがデフォルト. DIMコマンドで単位を変更できる.
b_feet = 5.355; %カナード(FINSET1)の最大スパン長[feet].
b = 0.3048 * b_feet;%m
U0 = 100;%飛行速度 100m/s
rho = 1.293;%kg/m3
%DATCOMのREF AREAからとった
S_feet = 11.046;%[feet2]翼面積?
S = 0.092903 * S_feet;%m2

%FROM DATCOM: 迎角ゼロの場合
%PAGE23: STATIC AERODYNAMICS FOR BODY-FIN SET 1 AND 2
C_yb = -0.1931;%CYB in DATCOM
C_lb = 0;%CLLB in DATCOM
C_nb = 0.4605;%CLNB in DATCOM
%PAGE27: BODY + 2 FIN SETS DYNAMIC DERIVATIVES
%FROM DATCOM: "DAMP DB14"カードを発行. DUMPではない（バグ?）。
C_yp = 0;%CYP in DATCOM
C_yr = 0.242;%CYR in DATCOM
C_lp = 0;%CLLP in DATCOM
C_nr = -0.929;%CLNR in DATCOM
C_np = 0;%CLNP in DATCOM

Y_b = rho*U0^2*S/(2*m)*C_yb;
L_b = rho*U0^2*S*b/(2*I_x)*C_lb;
N_b = rho*U0^2*S*b/(2*I_z)*C_nb;
Y_v = Y_b/U0;%横滑り角βと速度vの関係より
L_v = L_b/U0;%横滑り角βと速度vの関係より
N_v = N_b/U0;%横滑り角βと速度vの関係より

Y_p = rho*U0*S*b/(4*m)*C_yp;
Y_r = rho*U0*S*b/(4*m)*C_yr;
L_p = rho*U0*S*b^2/(4*I_x)*C_lp; 
L_r = rho*U0*S*b^2/(4*I_x)*C_nr;
N_p = rho*U0*S*b^2/(4*I_z)*C_np; 
N_r = rho*U0*S*b^2/(4*I_z)*C_nr;

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
