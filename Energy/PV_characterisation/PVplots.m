close all;
clear;

T = readtable('Panel1Lamp2.CSV');
%T = readtable('SynchronousTest.CSV');

%x = T.Var3(561:end);
%y = T.Var2(561:end);

%x = T.Var3;
%y = T.Var2;

%tmp = sort([x,y],1);

%x = tmp(:,1);
%y = tmp(:,2);

%y = smooth(x,y,0.5,'rloess');
y = smooth(y);
x = smooth(x);

p1 = polyfit(x,y,6);
y1 = polyval(p1,x);

% B = 1/10*ones(10,1);
% y = filter(B,1,y);
% x = filter(B,1,x);
% 
% x = x(10:end);
% y = y(10:end);

figure
hold on;
plot(x, y)
plot(x, y1)
grid




