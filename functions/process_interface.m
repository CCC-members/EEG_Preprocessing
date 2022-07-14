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
preprocessed_data       = properties.prep_data_params.data_config;

disp(strcat('-->> Data Source:  ', preprocessed_data.base_path ));
[bcv_path, name, ext]  = fileparts(preprocessed_data.base_path);
subjects = dir(bcv_path);
subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..

for i=1:length(subjects)
    subject_name = subjects(i).name;    
    subID = subject_name;    
    disp(strcat('-->> Processing subject: ', subID));
    disp('=================================================================');
   
    %%
    %% Processing MEG/EEG file
    %%    
    filepath = strrep(preprocessed_data.file_location,'SubID',subID);
    base_path =  strrep(preprocessed_data.base_path,'SubID',subID);
    data_path = fullfile(base_path,filepath);
   
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
    
    %%
    %% Exporting files
    %%
    for j=1:length(MEEGs)
        MEEG                    = MEEGs(j);
        base_path               = fullfile(general_params.bcv_config.export_path);   
        bcv_path                = fullfile(base_path,subID);
        if(isfile(fullfile(bcv_path,'subject.mat')))
            subject_info        = load(fullfile(bcv_path,'subject.mat'));
            Cdata               = load(fullfile(bcv_path,subject_info.channel_dir));
            HeadModel           = load(fullfile(bcv_path,subject_info.leadfield_dir));
            [Cdata, HeadModel]  = filter_structural_result_by_preproc_data(MEEG.labels, Cdata, HeadModel);            
            if(~isfield(MEEG,'event'))                
                action          = 'update';
                save_output_files(action, base_path, subject_info, HeadModel, Cdata, MEEG);               
            else
                Shead = load(fullfile(bcv_path,subject_info.scalp_dir));
                Sout = load(fullfile(bcv_path,subject_info.outerskull_dir)); 
                Sinn = load(fullfile(bcv_path,subject_info.innerskull_dir));
                Scortex = load(fullfile(bcv_path,subject_info.surf_dir));
                action = 'event';
                save_output_files(action, base_path, subject_info, HeadModel, Cdata, MEEG, Shead, Sout, Sinn, Scortex);
            end            
        else            
                action = 'new';
                save_output_files(action, base_path, modality, MEEG);            
        end        
        disp("---------------------------------------------------------------------");
    end
    if(isfield(MEEG,'event_name') && isfolder(fullfile(base_path,subID)))
       rmdir(fullfile(base_path,subID), 's');
    end
    
end
end

