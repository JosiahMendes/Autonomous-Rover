clear
close all

data = readtable('CURRENTS.CSV');

voltage = data.Var2;
current = data.Var3;

p = polyfit(voltage,current,1);
calc_I = polyval(p,voltage);


figure
hold on
plot(voltage,current);
%plot(voltage,calc_I);
grid




