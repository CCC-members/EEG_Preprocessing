function [process_error] = process_interface(properties, reject_subjects)
% Description here
%
%
%
% Author:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%

%%
%% Preparing selected protocol
%%
process_error           = [];
general_params      = properties.general_params;

disp(strcat('-->> Data Source:  ', general_params.meeg_data.base_path ));
subjects = dir(general_params.meeg_data.base_path);
subjects(ismember( {subjects.name}, {'.', '..','derivatives'})) = [];  %remove . and ..
subjects([subjects.isdir] == 0) = [];  %remove . and ..
subjects(ismember( {subjects.name}, reject_subjects)) = [];

if(~isfolder(fullfile(properties.general_params.workspace.base_path,'eeglab')))
    mkdir(fullfile(properties.general_params.workspace.base_path,'eeglab'));
end

for i=1:length(subjects)
    subject = subjects(i);
    subID = subject.name;

    disp(strcat("-->> Processing subject: ", subID));
    disp('==========================================================================');

    %%
    %% step 1: loading data
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Importing EEG file");
    disp('--------------------------------------------------------------------------');
    try
        EEGs = process_import_eeg(properties,subject);
    catch Ex
        disp('--------------------------------------------------------------------------');
        disp("-->> ERROR");
        disp(Ex.message);
        disp('--------------------------------------------------------------------------');
        continue;
    end
    %%
    %% step 2: Import and edit channels
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Importing EEG channels");
    disp('--------------------------------------------------------------------------');
    EEGs = process_import_channels(properties,EEGs);

    %%
    %%  step 3: Import events
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Importing EEG events");
    disp('--------------------------------------------------------------------------');
    EEGs = process_import_events(properties, EEGs);

    %%
    %% step 3: cleaning data
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Correct continuous data using Artifact Subspace Reconstruction (ASR)");
    disp('--------------------------------------------------------------------------');
    EEGs = process_clean_data(properties, EEGs);

    %%
    %% step 4: Export and edit events
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Selecting data events");
    disp('--------------------------------------------------------------------------');
    EEGs = process_select_events(properties, EEGs);
    

    %%
    %% step 5:
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Exporting EEG processsed files");
    disp('--------------------------------------------------------------------------');
    EEGs = process_export(properties, EEGs);

    disp('==========================================================================');
end
participants = jsondecode(fileread(fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json')));
writetable(struct2table(participants),fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.xlsx'));
end

