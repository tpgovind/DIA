%% LOAD DATA AND SETUP

clc
clear all
close all

% Specify colors for summary figures

blue = [53/255 86/255 141/255]; % GCaMP
yellow = [237/255 145/255 19/255]; % Movement

% Specify thresholds (coefficients by which median absolute 
% deviation is multiplied)
outlierThreshold = 6;
movementThreshold = 4;

% Read data from separate Excel sheets

escapers = xlsread('sample_data.xlsx','escapers');
nonEscapers = xlsread('sample_data.xlsx','non-escapers');

% Pre-allocate working matrices

numFrames = size(escapers,1); % number of data rows
numEscapers = floor(size(escapers,2)/2) + 1; % number of data columns
numNonEscapers = floor(size(nonEscapers,2)/2) + 1; % number of data columns

% First column is time vector

escapers_Movement = zeros(numFrames,numEscapers);
    escapers_Movement(:,1) = escapers(:,1);
escapers_GCaMP = zeros(numFrames,numEscapers);
    escapers_GCaMP(:,1) = escapers(:,1);
nonEscapers_Movement = zeros(numFrames,numNonEscapers);
    nonEscapers_Movement(:,1) = nonEscapers(:,1);
nonEscapers_GCaMP = zeros(numFrames,numNonEscapers);
    nonEscapers_GCaMP(:,1) = nonEscapers(:,1);

% Replace zeros in working matrices with data
% (assumes data file has interleaved movement and GCaMP data)
    
for i = 2:2:size(escapers,2)
    escapers_Movement(: , 1 + i/2) = escapers(:,i);
end

for i = 3:2:size(escapers,2)
    escapers_GCaMP(: , ceil(i/2)) = escapers(:,i);
end

for i = 2:2:size(nonEscapers,2)
    nonEscapers_Movement(: , 1 + i/2) = nonEscapers(:,i);
end

for i = 3:2:size(nonEscapers,2)
    nonEscapers_GCaMP(: , ceil(i/2)) = nonEscapers(:,i);
end

clear i escapers nonEscapers numFrames numEscapers numNonEscapers

%% REMOVE RECORDING ARTIFACTS FROM BEHAVIOR DATA
% Sometimes there can be artifacts in the output of difference-image
% analysis, which arise from discontinuities in behavior recording,
% 'flash' artifacts etc. during camera recording. This usually manifests
% as spikes in movement traces, so we can filter them out using outlier
% detection, and instead replace their contribution to the trace with a
% suitable value (e.g. local median).

% Show raw traces

figure(1)
rowscols_escapers = ceil(sqrt(size(escapers_Movement,2)-1));
for i  = 2:size(escapers_Movement,2)
    subplot(rowscols_escapers,rowscols_escapers,i-1)
    plot(escapers_Movement(:,1),escapers_Movement(:,i),...
        'Color',yellow)
    hold on
    plot(escapers_GCaMP(:,1),escapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('ESCAPERS (RAW)')

figure(2)
rowscols_nonEscapers = ceil(sqrt(size(nonEscapers_Movement,2)-1));
for i  = 2:size(nonEscapers_Movement,2)
    subplot(rowscols_nonEscapers,rowscols_nonEscapers,i-1)
    plot(nonEscapers_Movement(:,1),nonEscapers_Movement(:,i),...
        'Color',yellow)
    hold on
    plot(nonEscapers_GCaMP(:,1),nonEscapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('NON-ESCAPERS (RAW)')


% Remove distortions/artifacts using a specific threshold
% Here, any values exceeding 6 * Mean Absolute Deviation
% are replaced with median of trace

for i = 2:size(escapers_Movement,2)
    temp = escapers_Movement(:,i);
    thr1 = outlierThreshold*mad(temp);
    temp(temp >= thr1) = median(temp);
    temp(temp <= -1*thr1) = median(temp);
    escapers_Movement(:,i) = temp;
end

for i = 2:size(nonEscapers_Movement,2)
    temp = nonEscapers_Movement(:,i);
    thr1 = outlierThreshold*mad(temp);
    temp(temp >= thr1) = median(temp);
    temp(temp <= -1*thr1) = median(temp);
    nonEscapers_Movement(:,i) = temp;
end

% Show artifact-corrected traces

figure(3)
rowscols_escapers = ceil(sqrt(size(escapers_Movement,2)-1));
for i  = 2:size(escapers_Movement,2)
    subplot(rowscols_escapers,rowscols_escapers,i-1)
    plot(escapers_Movement(:,1),escapers_Movement(:,i),...
        'Color',yellow)
    hold on
    plot(escapers_GCaMP(:,1),escapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('ESCAPERS (ARTIFACT-CORRECTED)')

figure(4)
rowscols_nonEscapers = ceil(sqrt(size(nonEscapers_Movement,2)-1));
for i  = 2:size(nonEscapers_Movement,2)
    subplot(rowscols_nonEscapers,rowscols_nonEscapers,i-1)
    plot(nonEscapers_Movement(:,1),nonEscapers_Movement(:,i),...
        'Color',yellow)
    hold on
    plot(nonEscapers_GCaMP(:,1),nonEscapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('NON-ESCAPERS (ARTIFACT-CORRECTED)')


%% DETECT MOVEMENT

% Detect onset and offset of movement using a specific criterion.
% Here, the movement trace is binarized as:
% IF value > movementThreshold * Median Absolute Deviation,
% OR value < -1 * movementThreshold * Median Absolute Deviation
% THEN value = 1.
% Specifically, onset and offset are defined as the first and last
% instances where threshold is exceeded, respectively.
% All values between onset and offset are set to one, and all other
% values are set to zero.

Results_Escapers = zeros(size(escapers_Movement,2)-1,2);

for i = 2:size(escapers_Movement,2)
    
    % Detect
    
    temp = escapers_Movement(:,i);
    temp(temp >= movementThreshold*mad(temp)) = 1;
    temp(temp <= -1*movementThreshold*mad(temp)) = 1;
    temp(temp ~= 1) = 0;
    
    onset = find(temp,1,'first');
    offset = find(temp,1,'last');
    
    % Replace
    
    for j = 1:onset-1
        temp(j) = 0;
    end
    
    for j = onset:offset
        temp(j) = 1;
    end
    
    for j = offset+1:length(temp)
        temp(j) = 0;
    end
    
    % Save
    
    escapers_Movement(:,i) = temp;
    Results_Escapers(i-1,1) = onset; Results_Escapers(i-1,2) = offset;
end

Results_NonEscapers = zeros(size(nonEscapers_Movement,2)-1,2);

for i = 2:size(nonEscapers_Movement,2)
    
    % Detect
    
    temp = nonEscapers_Movement(:,i);
    temp(temp >= movementThreshold*mad(temp)) = 1;
    temp(temp <= -1*movementThreshold*mad(temp)) = 1;
    temp(temp ~= 1) = 0;
    
    onset = find(temp,1,'first');
    offset = find(temp,1,'last');
    
    % Replace
    
    for j = 1:onset-1
        temp(j) = 0;
    end
    
    for j = onset:offset
        temp(j) = 1;
    end
    
    for j = offset+1:length(temp)
        temp(j) = 0;
    end
    
    % Save
    
    nonEscapers_Movement(:,i) = temp;
    Results_NonEscapers(i-1,1) = onset; Results_NonEscapers(i-1,2) = offset;
end

% Show binarized movement trace overlaid on raw GCaMP trace

figure(5)
rowscols_Escapers = ceil(sqrt(size(escapers_Movement,2)-1));
for i  = 2:size(escapers_Movement,2)
    subplot(rowscols_Escapers,rowscols_Escapers,i-1)
    plot(escapers_Movement(:,1),escapers_Movement(:,i),'Color',yellow)
    hold on
    plot(escapers_GCaMP(:,1),escapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('ESCAPERS (BINARIZED)')

figure(6)
rowscols_NonEscapers = ceil(sqrt(size(nonEscapers_Movement,2)-1));
for i  = 2:size(nonEscapers_Movement,2)
    subplot(rowscols_NonEscapers,rowscols_NonEscapers,i-1)
    plot(nonEscapers_Movement(:,1),nonEscapers_Movement(:,i),'Color',yellow)
    hold on
    plot(nonEscapers_GCaMP(:,1),nonEscapers_GCaMP(:,i),'Color',blue)
    hold off
    title(int2str(i-1))
end
suptitle('NON-ESCAPERS (BINARIZED)')


% Tabulate results

Results_Escapers = array2table([(1:size(Results_Escapers,1))' Results_Escapers]);
Results_Escapers.Properties.VariableNames = {'Animal',...
    'MovementOnset_sec','MovementOffset_sec'};
Results_NonEscapers = array2table([(1:size(Results_NonEscapers,1))' Results_NonEscapers]);
Results_NonEscapers.Properties.VariableNames = {'Animal',...
    'MovementOnset_sec','MovementOffset_sec'};

% Comment out the following line to keep intermediate variables
clearvars -except Results_Escapers Results_NonEscapers
