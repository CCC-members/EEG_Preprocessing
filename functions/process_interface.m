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

for i=1:length(subjects)
    subID = subjects(i).name;
    disp(strcat("-->> Processing subject: ", subID));
    disp('==========================================================================');

    %%
    %% step 1: loading data
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Importing EEG file");
    disp('--------------------------------------------------------------------------');
    try
        EEG = process_import_eeg(properties,subject);
    catch
         fprintf(2,'\n-->> Error Importing EEG file.\n');
         continue;
    end
    %%
    %% step 2: Import and edit channels
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Importing EEG channels");
    disp('--------------------------------------------------------------------------');
    EEG = process_import_channels(properties,EEG);

    %%
    %% step 3: Import and edit events
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Selecting data events");
    disp('--------------------------------------------------------------------------');
    if(properties.general_params.meeg_data.clean_data && ~isempty(properties.preproc_params.select_events.events))
        EEGs = process_import_events(properties, EEG);
    end

    %%
    %% step 4: cleaning data
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Correct continuous data using Artifact Subspace Reconstruction (ASR)");
    disp('--------------------------------------------------------------------------');
    if(properties.general_params.meeg_data.clean_data)
        EEGs = process_clean_data(properties, EEGs);
    end

    %%
    %% step 5:
    %%
    disp('--------------------------------------------------------------------------');
    disp("-->> Exporting EEG processsed files");
    disp('--------------------------------------------------------------------------');
    EEGs = process_export(properties, EEGs);
   
    disp('==========================================================================');
end
end

