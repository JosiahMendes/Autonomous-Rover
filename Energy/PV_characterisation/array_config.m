close all

%% Parallel
v_parallel = [0.201,0.925,3.96,4.12,4.25,4.39,4.74,4.92,5.04,5.21,5.30];
i_parallel = [0.097,0.097,0.098,0.093,0.095,0.093,0.093,0.090,0.076,0.050,0.014];


figure
hold on
xlabel('Array Voltage [V]','fontSize',14);
title('Parallel configuration','fontSize',14);
yyaxis left
ylim([0,0.1]);
plot(v_parallel,i_parallel,"-o","lineWidth",2);
ylabel('Array Current [A]','fontSize',14);
yyaxis right
ylabel('Array Power [W]','fontSize',14);
plot(v_parallel,i_parallel.*v_parallel,"-x","lineWidth",2);
grid

%% Series
v_series = [1.30,2.07,3.83,4.85,6.05,7.03,8.11,8.48,13.88];
i_series = [0.015,0.016,0.015,0.015,0.016,0.015,0.015,0.015,0.013];

%Had open circuit voltage 21.18 V

figure
hold on
xlabel('Array Voltage [V]','fontSize',14);
title('Series configuration','fontSize',14);
yyaxis left
ylim([0,0.02]);
plot(v_series,i_series,"-o","lineWidth",2);
ylabel('Array Current [A]','fontSize',14);
yyaxis right
ylabel('Array Power [W]','fontSize',14);
plot(v_series,i_series.*v_series,"-x","lineWidth",2);
grid

