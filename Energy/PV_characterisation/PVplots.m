close all;
clear;

panel1 = readtable('Panel1Lamp2.CSV');
panel2 = readtable('Panel2Lamp.CSV');
panel3 = readtable('Panel3Lamp.CSV');
panel4 = readtable('Panel4Lamp.CSV');

panel1 = sortrows(panel1,3);
panel2 = sortrows(panel2,3);
panel3 = sortrows(panel3,3);
panel4 = sortrows(panel4,3);

x1 = smooth(panel1.Var3);
x2 = smooth(panel2.Var3);
x3 = smooth(panel3.Var3);
x4 = smooth(panel4.Var3);

y1 = smooth(panel1.Var2,10);
y2 = smooth(panel2.Var2,10);
y3 = smooth(panel3.Var2,10);
y4 = smooth(panel4.Var2,10);

[~,uidx] = unique(x1,'stable');
x1 = x1(uidx,:);
y1 = y1(uidx,:);

[~,uidx] = unique(x2,'stable');
x2 = x2(uidx,:);
y2 = y2(uidx,:);

[~,uidx] = unique(x3,'stable');
x3 = x3(uidx,:);
y3 = y3(uidx,:);

[~,uidx] = unique(x4,'stable');
x4 = x4(uidx,:);
y4 = y4(uidx,:);


% p1 = polyfit(x1,y1,6);
% py1 = polyval(p1,x1);
% 
% p2 = polyfit(x2,y2,8);
% py2 = polyval(p2,x2);
% 
% p3 = polyfit(x3,y3,8);
% py3= polyval(p3,x3);
% 
% p4 = polyfit(x4,y4,8);
% py4 = polyval(p4,x4);


figure
hold on;
xlabel('Panel Voltage [V]');
xlim([0,6]);
title('Characteristics - Panel 1','fontSize',14);
yyaxis left
ylabel('Panel Current [A]');
ylim([0,0.12]);
plot(x1, y1, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Panel Power [W]');
plot(x1, y1.*x1, 'r' ,'LineWidth',2)
grid

figure
hold on;
xlabel('Panel Voltage [V]');
title('Characteristics - Panel 2','fontSize',14);
yyaxis left
ylabel('Panel Current [A]');
ylim([0,0.12]);
plot(x2, y2, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Panel Power [W]');
plot(x2, y2.*x2, 'r' ,'LineWidth',2)
grid


figure
hold on;
xlabel('Panel Voltage [V]');
title('Characteristics - Panel 3','fontSize',14);
yyaxis left
ylabel('Panel Current [A]');
ylim([0,0.12]);
plot(x3, y3, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Panel Power [W]');
plot(x3, y3.*x3, 'r' ,'LineWidth',2)
grid


figure
hold on;
xlabel('Panel Voltage [V]');
title('Characteristics - Panel 4','fontSize',14);
yyaxis left
ylabel('Panel Current [A]');
ylim([0,0.12]);
plot(x4, y4, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Panel Power [W]');
plot(x4, y4.*x4, 'r' ,'LineWidth',2)
grid

x5 = linspace(0.1,5.5,100);

p1 = interp1(x1,y1,x5);
p2 = interp1(x2,y2,x5);
p3 = interp1(x3,y3,x5);
p4 = interp1(x4,y4,x5);

p5 = p1 + p2 + p3 + p4;


figure
hold on;
xlabel('Panel Voltage [V]');
title('Parallel configuration','fontSize',14);
yyaxis left
ylabel('Array Current [A]');
plot(x5, p5, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Array Power [W]');
plot(x5, x5.*p5, 'r' ,'LineWidth',2)
grid


%% Power and characteristics of a series connected PV array

panel1 = readtable('Panel1Lamp2.CSV');
panel2 = readtable('Panel2Lamp.CSV');
panel3 = readtable('Panel3Lamp.CSV');
panel4 = readtable('Panel4Lamp.CSV');

panel1 = sortrows(panel1,2);
panel2 = sortrows(panel2,2);
panel3 = sortrows(panel3,2);
panel4 = sortrows(panel4,2);

x1 = panel1.Var3;
x2 = panel2.Var3;
x3 = panel3.Var3;
x4 = panel4.Var3;


y1 = panel1.Var2;
y2 = panel2.Var2;
y3 = panel3.Var2;
y4 = panel4.Var2;


x=[1,2,4,6,8]';
y=[100,140,160,170,175].';


g = fittype('a-b*exp(-c*x)');
f0 = fit(x,y,g,'StartPoint',[[ones(size(x)), -exp(-x)]\y; 1]);
xx = linspace(1,8,50);
plot(x,y,'o',xx,f0(xx),'r-');



%y5 = linspace(0.0,0.11,100);


figure
hold on;
xlabel('Panel Voltage [V]');
title('Series configuration','fontSize',14);
yyaxis left
ylabel('Array Current [A]');
plot(x4,y4, 'b' ,'LineWidth',2)
yyaxis right
ylabel('Array Power [W]');
%plot(x5, x5.*p5, 'r' ,'LineWidth',2)
grid






