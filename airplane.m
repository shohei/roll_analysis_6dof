clear;cla
global A; global U0;

%有次元安定微係数
Xu = -0.01; Zu = -0.1; Mu = 0.001;
Xa = 30;    Za = -200; Ma = -4;
Xq = 0.3;   Zq = -5;   Mq = -1;
Yb = -45;   Lb_= -2;   Nb_= 1;
Yp = 0.5;   Lp_= -1;   Np_= -0.1;
Yr = 3;     Lr_= 0.2;  Nr_=-0.2;

%その他のパラメタ
W0 = 0;     U0 = 100;  theta0 = 0.05;
g  = 9.8; %重力加速度

%縦のシステム
A_lat =[Xu,       Xa,          -W0,    -g*cos(theta0);
        Zu/U0, Za/U0,	(U0+Zq)/U0, -g*sin(theta0)/U0;
        Mu,	  Ma,           Mq,	            0;
        0,	   0,            1,                 0];

%横・方向のシステム
A_lon = [Yb, (W0+Yp),    -(U0-Yr), g*cos(theta0),    0;
         Lb_,    Lp_,         Lr_,             0,    0;
         Nb_,    Np_,         Nr_,             0,    0;
         0,        1, tan(theta0),             0,    0;
         0,        0, sec(theta0),             0,    0];

%対角ブロックとしてシステムを結合する
A = blkdiag(A_lat,A_lon);

%さらに飛行軌道分のスペースを確保しておく
A = blkdiag(A,zeros(3));

%計算条件の設定
endurance	= 100;%飛行時間[sec]
step		= 10;%1.0[sec]あたりの時間ステップ数
t = linspace(0,endurance,endurance*step);

%初期値 x0 = [u,alpha,q,theta, beta,p,r,phi,psi]
x0_lat		= [10;0.1;0.4;0.2]; %縦の初期値
x0_lon		= [0.0;0.6;0.4;0.2;0.2]; %横・方向の初期値
x0_pos		= [0,0,-1000]';%飛行機の初期位置
x0 = vertcat(x0_lat,x0_lon,x0_pos);

%運動方程式を解く
[t,x]=ode45(@dynamical_system,t,x0);

%描画
figure(); hold on; box('off')
axis equal; set(gca,'YDir','rev','ZDir','rev'); %飛行機でよく使われる右手系にする
xlabel('x');ylabel('y');zlabel('z');
grid on;view (3)

%見やすくなるように適宜調整する
interval = step*5; %飛行機の表示間隔 
scale = 50; %飛行機のサイズ

for i=1:interval:endurance*step
	aircraft_figure(x(i,10),x(i,11),x(i,12),x(i,9),x(i,4),x(i,8),scale);
	stem3(x(1:interval:i,10),x(1:interval:i,11),x(1:interval:i,12),'MarkerSize',1);
	plot3(x(1:1:i,10),x(1:1:i,11),x(1:1:i,12));
	refresh;
end




function dx = dynamical_system(t,x)
% x = [u,alpha,q,theta,beta,p,r,phi,psi,x,y,z]
	global A; global U0;
	dx = A*x;

	u = x(1)+U0;%速度
	UVW = [u;u*x(5);u*x(2)];%速度ベクトル[U,V,W]
	dX = (Rotation_X(-x(9)) * Rotation_Y(-x(4)) * Rotation_Z(-x(8))) * UVW;
	dx(10) = dX(1);
	dx(11) = dX(2);
	dx(12) = dX(3);
end

function R_x = Rotation_X(Psi)
	R_x = [ cos(Psi), sin(Psi), 0;
               -sin(Psi), cos(Psi), 0;
                       0,        0, 1 ];
end

%y軸回転
function R_y = Rotation_Y(Theta)
	R_y = [ cos(Theta), 0, -sin(Theta);
                         0, 1,           0;
                sin(Theta), 0,   cos(Theta) ];
end

%z軸回転
function R_z = Rotation_Z(Phi)
	R_z = [1,         0,        0;
               0,  cos(Phi), sin(Phi);
               0, -sin(Phi), cos(Phi) ];
end

function [] = aircraft_figure(x,y,z,Psi,Theta,Phi,scale)
	%飛行機の3Dグラフィックを描画する関数
	%引数は重心座標，ロールピッチヨー角，飛行機のサイズ
	%ポリゴンの頂点を定義して，lineオブジェクトで繋ぐ

	%xz平面に対する鏡像ベクトルを作るための写像行列
	mirror = [1,0,0;0,-1,0;0,0,1];

	%主翼オブジェクト
	p1 = [0+3,0 ,-0];
	p2 = [-4+3,1 ,-0];
	p3 = [-4+3,-1,-0];
	p4 = [-3+3,0,-0.2];
	w1 = vertcat(p1,p2,p3,p1);%主翼
	w2 = vertcat(p1,p2,p4,p1);%右舷
	w3 = (mirror * w2')';%左舷

	%尾翼オブジェクト
	p1 = [-3.0+3,0.3,-0];
	p2 = [-3.8+3,0.5,-0.6];
	p3 = [-4.2+3,0.5,-0.6];
	p4 = [-4.0+3,0.3,-0];
	tail_r = vertcat(p1,p2,p3,p4,p1);%右尾翼
	tail_l = (mirror * tail_r')';%左尾翼

	%オブジェクトのスケールを変更する
	w1 = w1 * scale;
	w2 = w2 * scale;
	w3 = w3 * scale;
	tail_r = tail_r * scale;
	tail_l = tail_l * scale;

	%オブジェクトを回転させる
	DCM = Rotation_X(-Psi) * Rotation_Y(-Theta) * Rotation_Z(-Phi);
	w1 = (DCM * w1')';
	w2 = (DCM * w2')';
	w3 = (DCM * w3')';
	tail_r = (DCM * tail_r')';
	tail_l = (DCM * tail_l')';

	%オブジェクトを平行移動させる
	w1     = translational_shift(w1,x,y,z);
	w2     = translational_shift(w2,x,y,z);
	w3     = translational_shift(w3,x,y,z);
	tail_r = translational_shift(tail_r,x,y,z);
	tail_l = translational_shift(tail_l,x,y,z);

	%描画する
	line(w1(:,1),w1(:,2),w1(:,3));
	line(w2(:,1),w2(:,2),w2(:,3));
	line(w3(:,1),w3(:,2),w3(:,3));
	line(tail_r(:,1),tail_r(:,2),tail_r(:,3));
	line(tail_l(:,1),tail_l(:,2),tail_l(:,3));

end

function result = translational_shift(object,x,y,z)
	%頂点群objectを[x,y,z]だけ平行移動させる
	shift_x = x*ones(size(object,1),1);
	shift_y = y*ones(size(object,1),1);
	shift_z = z*ones(size(object,1),1);
	shift   = horzcat(shift_x,shift_y,shift_z);

	result = object + shift;
end