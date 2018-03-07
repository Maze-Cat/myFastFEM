%ţ�ٵ�����������Ȧ������2D���ų���ʸλ�ֲ���comsol�Ľ��
%By Yuchen Yang
%3/6/2018
%���ÿ����Ԫ
clear all
close all
fname = ['coilmesh.mphtxt'];

[xy,TR,DM] = readComsol(fname);

num_elements = length(TR);
num_nodes = length(xy);

S = zeros(num_nodes,num_nodes);
F = zeros(num_nodes,1);


%����������Ԫ��ʵ������
z1 = xy(:,1);
x = z1(TR);
z2 = xy(:,2);
y = z2(TR);

P = zeros(num_elements,3);
Q = zeros(num_elements,3);
R = zeros(num_elements,3);

Q(:,1) = y(:,2) - y(:,3);
Q(:,2) = y(:,3) - y(:,1);
Q(:,3) = y(:,1) - y(:,2);

R(:,1) = x(:,3) - x(:,2);
R(:,2) = x(:,1) - x(:,3);
R(:,3) = x(:,2) - x(:,1);

P(:,1) = x(:,2).*y(:,3) - x(:,3).*y(:,2);
P(:,2) = x(:,3).*y(:,1) - x(:,1).*y(:,3);
P(:,3) = x(:,1).*y(:,2) - x(:,2).*y(:,1);

AREA = 0.5 * (Q(:,1).*R(:,2) - Q(:,2).*R(:,1));%���������

%ֻ����������1Ϊ��������2Ϊ��Ȧ
u0 = 4*pi*1e-7;%�����ŵ���
J = zeros(num_elements,1);%��������ܶȾ���
coildomain = find(DM == 2);%Ѱ����Ȧ����ĵ�Ԫ
J(coildomain) = 8e5;%������Ȧ����ĵ����ܶȣ���������Ϊ0

%����ϳ�
for i = 1:num_elements
    for column = 1:3
        for row = 1:3
            S1(row,column) = (R(i,row).*R(i,column) + Q(i,row).*Q(i,column))/4/AREA(i)/u0;
            S(TR(i,row),TR(i,column)) = S(TR(i,row),TR(i,column)) + S1(row,column);
        end
        F(TR(i,row)) = F(TR(i,row)) + J(i,:).*AREA(i)/3;
    end
end
%���ҷǱ߽��
A = zeros(num_nodes,1);
freenodes = find(abs(z1)~=1 & abs(z2)~=1)
A(freenodes) = S(freenodes,freenodes)\F(freenodes);

%matlab��ͼ

Z = scatteredInterpolant(z1,z2,A);
tx = -1:1e-3:1;
ty = -1:1e-3:1;
[qx,qy] = meshgrid(tx,ty);
qz = Z(qx,qy); 
figure
subplot(1,2,2);
hold on
title('MATLAB');
contourf(qx,qy,qz,20);colorbar
axis equal

%COMSOL��ͼ

fp = fopen('comsoldata.txt','r');

for i=1:9
    fgets(fp);
end

data = fscanf(fp,'%lf %lf %lf\n',[3,num_nodes]);
data = data';
fclose(fp);

Z = scatteredInterpolant(data(:,1),data(:,2),data(:,3));
tx = -1:1e-3:1;
ty = -1:1e-3:1;
[qx,qy] = meshgrid(tx,ty);
qz = Z(qx,qy);
subplot(1,2,1);
contourf(qx,qy,qz,20);colorbar
title('COMSOL');
hold on
axis equal
