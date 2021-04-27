function [ chandef ] = tayeeg_channel_definition( details )
%MNKET_CHANNEL_DEFINTION Channel definition for COMPI EEG data sets
%   IN:     paths       - struct that holds all general paths
%   OUT:    chandef     - struct with as many fields as channel types

chandef{1}.type = 'EOG';
chandef{1}.ind = [65 66];

save(details.eeg.channeldef, 'chandef');

end

