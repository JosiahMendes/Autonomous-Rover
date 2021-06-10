clear
close all

T = readtable('CSV-files/round4/BATCHARG.CSV');

figure
hold on
title("Balancing of cell voltages", "FontSize", 16)
plot((1:size(T.Var6)) - 1900 ,T.Var7);
plot((1:size(T.Var6)) - 1900,T.Var8);
plot((1:size(T.Var6)) - 1900,T.Var9);
plot((1:size(T.Var6)) - 1900,T.Var10);
xlabel("Time [s]","FontSize", 16)
ylabel("Cell Voltage [mV]","FontSize", 16)
legend("Cell 1" , "Cell 2", "Cell 3", "Cell 4")
ylim([3300,3700]);
xlim([0,1100]);

figure
hold on
plot(1:size(T.Var6),T.Var6);


%%

T = readtable('../CSV-files/round5/BATDISCH.CSV');

figure
plot(43:2530,T.Var4(43:2530));
ylim([12000,14500]);

figure
hold on
plot(43:2530,smooth(T.Var5(43:2530),20));
plot(43:2530,smooth(T.Var6(43:2530),20));
plot(43:2530,smooth(T.Var7(43:2530),20));
plot(43:2530,smooth(T.Var8(43:2530),20));
%plot(43:2530,T.Var6(43:2530));
%plot(43:2530,T.Var7(43:2530));
%plot(43:2530,T.Var8(43:2530));








