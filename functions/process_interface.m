function [process_error] = process_interface(properties)
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
process_error = [];
modality = properties.general_params.modality;
subjects_process_error  = [];
subjects_processed      = [];
report_output_path      = properties.general_params.reports.output_path;
general_params          = properties.general_params;
preprocessed_data       = properties.prep_data_params.process_type.type_list{2};

disp(strcat('-->> Data Source:  ', preprocessed_data.base_path ));
[base_path, name, ext]  = fileparts(preprocessed_data.base_path);
subjects = dir(base_path);
% load("templates/good_cases_wMRI_Usama.mat");
% subjects(~ismember( {subjects.name}, IDg)) = [];
subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
% subjects(~ismember( {subjects.name}, {'sub-CBM00034', 'sub-CBM00044'})) = [];  %remove . and ..
subjects_process_error = [];
subjects_processed =[];
Protocol_count = 0;
for j=1:length(subjects)
    subject_name = subjects(j).name;    
    subID = subject_name;    
    disp(strcat('-->> Processing subject: ', subID));
    disp('=================================================================');
    
    %%
    %% Genering MEG/EEG file
    %%
    if(isequal(properties.prep_data_params.process_type.type,1))
        preprocessed_data = properties.prep_data_params.process_type.type_list{1};
        filepath = strrep(preprocessed_data.file_location,'SubID',subID);
        base_path =  strrep(preprocessed_data.base_path,'SubID',subID);
        data_path = fullfile(base_path,filepath);
    elseif(isequal(properties.prep_data_params.process_type.type,2))
        preprocessed_data = properties.prep_data_params.process_type.type_list{2};
        if(~isequal(preprocessed_data.base_path,'none'))
            filepath = strrep(preprocessed_data.file_location,'SubID',subID);
            base_path =  strrep(preprocessed_data.base_path,'SubID',subID);
            data_path = fullfile(base_path,filepath);
        end
    end
    if(exist('data_path','var') && (isfile(data_path) || isfolder(data_path)))
        disp ("-->> Genering MEG/EEG file");
        preprocessed_data.general_params = properties.general_params;
        preprocessed_data.clean_data = properties.prep_data_params.clean_data;
        preprocessed_data.channel_label_file = properties.prep_data_params.channel_label_file;
        if(isequal(modality,'EEG'))
            MEEGs = import_eeg_format(subID, preprocessed_data, data_path);            
        else
            MEEGs = import_meg_format(subID, preprocessed_data, data_path);            
        end
    else
        export_error = "Missing preprocessed data";
        continue;
    end
    
    
end
end

