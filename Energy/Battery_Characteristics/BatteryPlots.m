close all;
clear;

%Plot a single charge cycle

cell1 = readtable('Cell1.CSV');
x1 = 1:size(cell1.Var1);

figure('Position', [10 10 900 400]);
hold on;
plot(x1 - 3000, cell1.Var2, "lineWidth",1)
set(gca,'FontSize',14)
title('Discharge/Charge Cycle for LiFePO_4 Battery Cell', 'fontSize', 16);
xlabel('Time [s]','fontSize', 16);
ylabel('Cell voltage [mV]',  'fontSize', 16);
xlim([0,15876]);
grid




%% Find the capacity of each of the cells

cell1 = readtable('Cell1.CSV');
cell2 = readtable('Cell2.CSV');
cell3 = readtable('Cell3.CSV');
cell4 = readtable('Cell4.CSV');
cell5 = readtable('Cell5.CSV');

x1 = 1:size(cell1.Var1);
x2 = 1:size(cell2.Var1);
x3 = 1:size(cell3.Var1);
x4 = 1:size(cell4.Var1);
x5 = 1:size(cell5.Var1);

intg1 = zeros(size(cell1.Var4));
intg2 = zeros(size(cell2.Var4));
intg3 = zeros(size(cell3.Var4));
intg4 = zeros(size(cell4.Var4));
intg5 = zeros(size(cell5.Var4));


for i = 1:size(cell1.Var4)
    intg1(i) = sum(cell1.Var4(1:i));
end

for i = 1:size(cell2.Var4)
    intg2(i) = sum(cell2.Var4(1:i));
end

for i = 1:size(cell3.Var4)
    intg3(i) = sum(cell3.Var4(1:i));
end

for i = 1:size(cell4.Var4)
    intg4(i) = sum(cell4.Var4(1:i));
end

for i = 1:size(cell5.Var4)
    intg5(i) = sum(cell5.Var4(1:i));
end

%Find capacity in mC
cap1 = max(intg1) - min(intg1);
cap2 = max(intg2) - min(intg2);
cap3 = max(intg3) - min(intg3);
cap4 = max(intg4) - min(intg4);
cap5 = max(intg5) - min(intg5);

%Convert capacity to mAh
cap1 = cap1/3600;
cap2 = cap2/3600;
cap3 = cap3/3600;
cap4 = cap4/3600;
cap5 = cap5/3600;


figure
hold on
plot(x1, intg1)
plot(x2, intg2)
plot(x3, intg3)
plot(x4, intg4)
plot(x5, intg5)
grid

%figure
%plot(x, integral)
%grid


%% Pulse charging results

pulsed_cell3 = readtable('QuickerTest.CSV');
x1 = (1:size(pulsed_cell3.Var1));

figure('Position', [10 10 900 400]);
hold on;
plot(x1,pulsed_cell3.Var2)
title('Pulsed charge cycle of cell3', 'fontSize', 16);
xlabel('Time [s]','fontSize', 14);
ylabel('Cell voltage [mV]',  'fontSize', 14);
ylim([2400,3700]);
%xlim([3000,18876]);
grid


pulsed_intg = zeros(size(pulsed_cell3.Var4));

for i = 2:size(pulsed_cell3.Var4)
    pulsed_intg(i) = pulsed_intg(i-1) + pulsed_cell3.Var4(i);
end


figure
hold on
plot(x1, pulsed_intg)
grid on

%Calculate capacity in mC
pulsed_cap = max(pulsed_intg) - min(pulsed_intg);

%Convert capacity to mAh
pulsed_cap = pulsed_cap/3600;


