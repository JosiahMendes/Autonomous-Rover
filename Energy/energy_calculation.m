clear
close all

p1 = readtable('CSV-files/round5/ENERGYLU.CSV','ReadVariableNames',false);
p2 = readtable('CSV-files/round6/ENERGYLU.CSV','ReadVariableNames',false);


A1 = table2array(p1);
A2 = table2array(p2);

A1 = cellfun(@str2num,A1(1:end-1));
A2 = cellfun(@str2num,A2(1:end-1));

A_sum = 100*(A1 + (A2 - 0.99*A1));

%linefit = polyfit(1:600, A_sum, 1);

A_sum = A_sum(1:568);

A_sum = fliplr(A_sum);

figure
set(gca,'FontSize',14)
hold on
grid
plot((1:568)/5.68,A_sum/(10^6),"r","lineWidth",2);
xlim([0,100])
xlabel("SOC [%]", "fontSize",16);
ylabel("Energy in battery [kJ]");
title("Energy as function of SoC");
%plot(1:600, polyval(linefit,1:600));


%writematrix(A_sum,'CSV-files/round7/ENERGYLU.CSV')
