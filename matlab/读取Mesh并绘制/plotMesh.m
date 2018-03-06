clear all
close all

fname=['D:\Staff\-��ҵ���\fastFEM\fastFEM\model\model_normal.mphtxt'];

[xy,tri,DM] = readComsol(fname);

% ���Ƶ�Ԫ
 for i=1:length(tri)
plot(xy(tri(i,[1 2 3 1]),1),xy(tri(i,[1 2 3 1]),2));
     hold on;
 end
  axis equal
%  ������Ƶ�Ԫ
figure
minDM = min(DM);
maxDM = max(DM);
for i=minDM:maxDM
    p = find(DM == i);
    for j=1:length(p)
        fill(xy(tri(p(j),:),1),xy(tri(p(j),:),2),[i/maxDM i*0/maxDM i*0/maxDM]);
        hold on
    end
end
 axis equal