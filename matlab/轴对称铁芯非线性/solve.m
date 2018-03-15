%ţ�ٵ�����������Գ���оBH�����Բ�����2D���ų���ʸλ�ֲ���comsol�Ľ��
%By Yuchen Yang
%3/13/2018
%���ÿ����Ԫ
clear all
close all
fname = ['mesh.mphtxt'];

[xy,TR,DM] = readComsol(fname);

num_elements = length(TR);
num_nodes = length(xy);

S = zeros(num_nodes,num_nodes);
F = zeros(num_nodes,1);
D = zeros(3,3);%Jacob matrix


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

area = 0.5 * (Q(:,1).*R(:,2) - Q(:,2).*R(:,1));%���������

%�������3��4Ϊ��о����5Ϊ��Ȧ
J = zeros(num_elements,1);%��������ܶȾ���
coildomain = find(DM == 5);%Ѱ����Ȧ����ĵ�Ԫ
J(coildomain) = 8e5;%������Ȧ����ĵ����ܶȣ���������Ϊ0

%u
u0 = 4*pi*1e-7;%�����ŵ���
u = u0 * ones(num_elements,1);%��ÿ����Ԫ�Ĵŵ��ʳ�ʼ��Ϊ�����ŵ���

%ydot
ydot = zeros(num_elements,1);
for i = 1:num_elements
    if ((x(i,1)<1e-9 & x(i,2)<1e-9)||(x(i,3)<1e-9 & x(i,2)<1e-9)||(x(i,1)<1e-9 & x(i,3)<1e-9))
        ydot(i) = mean(x(i,:));
    else
        ydot(i) = 1.5 / ((1/(x(i,1)+ x(i,2)) + ( 1/(x(i,1)+ x(i,3)) )+ ( 1/( x(i,2)+x(i,3)) )));
    end
end

%�������
A = zeros(num_nodes,1);%ÿ���ڵ�Ĵ���
B = zeros(num_elements,1);

DM3 = find(DM==3);
DM4 = find(DM==4);

%����ϳ�
steps = 25;
for count = 1:steps
    for i = 1:num_elements
        if DM(i)==3 || DM(i)==4
            dvdb = getDvdb(B(i));
        else
            dvdb = 0;
    end
    
        for column = 1:3
            for row = 1:3
                D(row,column) = dvdb / ydot(i) / ydot(i) / ydot(i) /area(i);
                D(row,column) = D(row,column) * sum((R(i,row)*R(i,:) + Q(i,row)*Q(i,:)).* A(TR(i,:))') /4/area(i);
                D(row,column) = D(row,column) * sum((R(i,column)*R(i,:) + Q(i,column)*Q(i,:)).* A(TR(i,:))') /4/area(i);
            
                S1(row,column) = D(row,column) + (R(i,row).*R(i,column) + Q(i,row).*Q(i,column))/4/area(i)/u(i)/ydot(i);
                S(TR(i,row),TR(i,column)) = S(TR(i,row),TR(i,column)) + S1(row,column);
                F(TR(i,row)) = F(TR(i,row))+ D(row,column).*A(TR(i,column));
            end
            F(TR(i,row)) = F(TR(i,row)) + J(i,:).*area(i)/3;
        end
end

%���ҷǱ߽��
A = zeros(num_nodes,1);
freenodes = find(abs(z1)>1e-6 & sqrt(z1.^2 + z2.^2)<0.05-1e-6);
A(freenodes) = S(freenodes,freenodes)\F(freenodes);

%���µ���
S = S - S;
F = F - F;

%����B
Bx = sum(R.*A(TR),2)./area./ydot/2;
By = sum(Q.*A(TR),2)./area./ydot/2;
B = sqrt(Bx.^2 + By.^2);

%����u

u(DM3) = B(DM3)./arrayfun(@getH,B(DM3));
u(DM4) = B(DM4)./arrayfun(@getH,B(DM4));

%�ж�����

end

A(freenodes) = A(freenodes) ./ z1(freenodes);


%matlab��ͼ

Z = scatteredInterpolant(z1,z2,A);
tx = 0:1e-3:0.025;
ty = -0.012:1e-3:0.012;
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
tx = 0:1e-3:0.025;
ty = -0.012:1e-3:0.012;
[qx,qy] = meshgrid(tx,ty);
qz = Z(qx,qy);
subplot(1,2,1);
contourf(qx,qy,qz,20);colorbar
title('COMSOL');
hold on
axis equal
