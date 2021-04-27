function biConditions = mmn_binary_trialDef(D, details)
% mmn_binary_trialDef Specifies trial type for each tone in a sequence
%based on duration deviant defined by values
%   IN:     D             - data structure
%   OUT:    conditions    - a cell array of condition labels of length nTones

% Get data structure and access values (S1, S2)
D = struct(D);
biConditions = zeros(1, length(D.trials));

for i = 1: length(D.trials)
    if D.trials(i).events(1).value == 2
        biConditions(i) = 0;
    else
        biConditions(i) = 1;
    end
end

save(details.model.binnedConditions, 'biConditions');

end