function mmn_visualize_performance


% Get visual stimuli
vis_times = MMN.stimuli.visTimes(MMN.stimuli.visSequence > 0);
resp_times = MMN.responses.times;

% Prepare line plot
y  = [ones(size(vis_times)).*-1; ones(size(vis_times))];
x = [vis_times; vis_times];


hold on 
figure
plot(resp_times,zeros(size(resp_times)),'kx')
line(x,y,'Color','r') % plot right opening
xlim([0 max([resp_times vis_times(end)+10])])


figure
subplot(2,1,1)





