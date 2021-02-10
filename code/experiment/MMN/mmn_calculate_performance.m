function [ money, perform, meanRT, errors, misses ] = mmn_calculate_performance( MMN )
%MMN_CALCULATE_PERFORMANCE Calculates performance score for visual task
%   Outputs the reward money (in CHF), the performance score (the higher,
%   the better, minimum is zero, maximum around 0.6), the mean RT, and how
%   many error presses and misses visual events a person had. 
% INPUT: MMN results structure

% settings
minRT = 100/1000; % in s
maxRT = 2000/1000; % in s
ansButtons = {1, 2};

minPerform = 0;
maxPerform = 0.7;
maxMoney = 6;

% initialize results
reactTime = [];
misses = 0;
errors = 0;
rts = [];

% on which trials actually happened something
idxVis = find(MMN.stimuli.visSequence);

% how many visual stimuli and button presses do we have
nVis = length(idxVis);
nButtons = length(MMN.responses.times);

% go through all stimuli except last one
for vis = 1: nVis
    % when and wich stimulus was presented
    presTime = MMN.stimuli.visTimes(idxVis(vis));
    presType = MMN.stimuli.visSequence(idxVis(vis));
    corrButton = ansButtons{presType};
    
    % determine acceptable range of RTs
    minTime = presTime + minRT;
    maxTimeRT = presTime + maxRT;
    if vis == nVis
        maxTime = maxTimeRT;
    else
        presRange = MMN.stimuli.visTimes(idxVis(vis + 1)) - presTime;
        maxTimeRange = presTime + presRange;
        maxTime = min(maxTimeRT, maxTimeRange);
    end
    
    % go through button presses
    potRTs = [];
    for butt = 1: nButtons
        pressTime = MMN.responses.times(butt);
        respButton = MMN.responses.dummy(butt);
        % save potential RTs
        if      pressTime > minTime && ...
                pressTime < maxTime && ...
                respButton == corrButton
            potRTs = [potRTs pressTime];
        end
    end
    
    % if there were none, this is a miss
    if isempty(potRTs)
        misses = misses + 1;
        reactTime(vis) = NaN;
        rts(vis) = NaN;
    else
        % choose first correct response
        reactTime(vis) = min(potRTs);
        rts(vis) = reactTime(vis) - presTime;
    end
end

% check which button presses have not been assigned
for butt = 1: nButtons
    pressTime = MMN.responses.times(butt);
    if ~ismember(pressTime, reactTime)
        errors = errors + 1;
    end
end

% evaluate performance
meanRT = mean(rts(~isnan(rts)));
faults = misses + errors;
perform = 1 - (meanRT + faults/nVis) + 0.2;
if perform < 0
    perform = 0;
end

% calculate payoff
rangePerform = maxPerform - minPerform;
moneyScale = maxMoney / rangePerform;

money = perform * moneyScale;
if money > maxMoney
    money = maxMoney;
end

end

