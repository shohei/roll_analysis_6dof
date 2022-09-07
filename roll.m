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
% b_feet = 5.355; %カナード(FINSET1)の最大スパン長[feet].
b = 0.056; %m
U0 = 100;%飛行速度 100m/s
rho = 1.293;%kg/m3
%DATCOMのREF AREAからとった
% S_feet = 11.046;%[feet2]翼面積?
S = 0.003; %m2

%FROM DATCOM: 迎角ゼロの場合
%PAGE23: STATIC AERODYNAMICS FOR BODY-FIN SET 1 AND 2
C_yb = -0.2828;%CYB in DATCOM
C_lb = 0;%CLLB in DATCOM
C_nb = 0.2091;%CLNB in DATCOM
%PAGE27: BODY + 2 FIN SETS DYNAMIC DERIVATIVES
%FROM DATCOM: "DAMP DB14"カードを発行. DUMPではない（バグ?）。
C_yp = 0;%CYP in DATCOM
C_yr = 1.554;%CYR in DATCOM
C_lp = -0.265;%CLLP in DATCOM
C_nr = -5.224;%CLNR in DATCOM
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

%エルロンは使わないのでゼロにする
C_y_aileron = 0;%記述なし？？
C_l_aileron = 0 ;%航空機力学入門 p.96, p.97
C_n_aileron = 0;%航空機力学入門 p.97, p.98 -> 風洞実験?

% Sf = ;
% S = ;
Sf_by_S = (3/5.6)^2;
%C_L_rudder_finが何を指すかわからない.
% とりあえず「C_yr = 1.554;%CYR in DATCOMを代入してみる
C_L_rudder_fin = C_yr;
z_f_delta = 0.03;%ロケット半径 [m]
%b = ;
lf = (74-51.3)*0.01;%重心と垂直尾翼空力中心の距離 [m]
V_fin_star = lf/b*Sf_by_S;

C_y_rudder = Sf_by_S*C_L_rudder_fin;%航空機力学入門 p.91
C_l_rudder = z_f_delta/b*Sf_by_S;%航空機力学入門 p.91
C_n_rudder = -V_fin_star*C_L_rudder_fin;%航空機力学入門 p.101, p.102

Y_xi = rho*U0^2*S/(2*m)*C_y_aileron; 
Y_zeta = rho*U0^2*S/(2*m)*C_y_rudder;
L_xi = rho*U0*S*b^2/(2*I_x)*C_l_aileron; 
L_zeta = rho*U0*S*b^2/(2*I_x)*C_l_rudder;
N_xi = rho*U0*S*b^2/(2*I_z)*C_n_aileron;
N_zeta = rho*U0*S*b^2/(2*I_z)*C_n_rudder;

Bprime = [Y_xi Y_zeta;
          L_xi L_zeta;
          N_xi N_zeta;
          0    0;
          0    0];

A = inv(M)*Aprime;
B = inv(M)*Bprime;

C = [0 1 0 0 0;
     0 0 1 0 0;
     0 0 0 1 0;
     0 0 0 0 1];
D = [0 0
     0 0
     0 0
     0 0];

x0 = [U0 0 0 0 0];

sys = ss(A,B,C,D);



