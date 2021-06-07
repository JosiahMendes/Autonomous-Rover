clear
close all

T = readtable('../CSV-files/round8/BATCHARG.CSV');

figure
hold on
plot(1:2619,T.Var7);
plot(1:2619,T.Var8);
plot(1:2619,T.Var9);
plot(1:2619,T.Var10);
ylim([2500,3700]);
xlim([1800,2619]);

figure
hold on
plot(1:2619,T.Var6);


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








