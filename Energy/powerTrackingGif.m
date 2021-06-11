close all
clear

T = readtable('CSV-files/round10/BATCHARG.CSV');

%% Draw frames
fig = figure('Position', [10 10 650 960]);
for i = 1:(size(T.Var11)-100)
    yyaxis left
    plot(4*(i:(i+100)),T.Var11(i:(i+100))/1000000,"lineWidth",2);
    xticks(0:50:(4*1312))
    xlabel("Time [s]", "FontSize",16)
    ylabel("Maximum Output Power [W]", "FontSize",16)
    xlim(4*[i,i+100])
    ylim([0,4.7])
    yyaxis right
    plot(4*(i:(i+100)),T.Var2(i:(i+100)),"lineWidth",2);
    ylim([0,250]);
    ylabel("Charge current [mA]", "FontSize",16)
    grid
    drawnow
    frame = getframe(fig);
    im{i} = frame2im(frame);
end

%% Make into gif

filename = 'testAnimated650.gif'; % Specify the output file name
for idx = 1:size(im,2)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end

