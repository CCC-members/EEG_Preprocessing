function processing_interface(properties)
%% PURPOSE: Este codigo esta basado en los siguientes pasos:
%    1. Cargar los datos EEG utilizando una función de EEGLab como pop_loadset(),
% pop_loadbv(), etc, en función de la base de datos. Esto permitirá obtener la variable
% EEG con la estructura adecuada.
%    2. De ser requerido, ajustar la configuración de los electrodos (EEG.chanlocs)
% al sistema 10/20 (Fp1, Fp2, O1, etc.).
%    3. Seleccionar segmentos de en reposo con ojos abiertos
% dentro del dato de EEG y remover el resto.
%    4. Limpiar los datos empleando el pipeline establecido.
%    5. Estimar medidas de actividad y conectividad empleando el pipeline
% establecido.
%    6. Salvar los resultados.
%
%-------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Author: Eduardo Gonzalez-Moreira
% Updater: Ariosky Areces Gonzalez
%--------------------------------------------------------------------------

% Getting parameters
eeglab_path = properties.general.eeglab_path;
dataset_path = properties.dataset.root_path;
participants = properties.dataset.participants;
[~,dt_name,~] = fileparts(dataset_path);
ref_file    = properties.dataset.ref_file;
[~,ref_file,~]    = fileparts(ref_file);
output_path = properties.general.output_path;
output_path = fullfile(output_path,dt_name);
if(~isfolder(output_path))
    mkdir(output_path)
end

% Starting EEGLAB
addpath(eeglab_path);
eeglab nogui;

% Getting Subjects and reject
subjects = dir(dataset_path);
subjects(ismember({subjects.name},{'.','..','derivatives'})) = [];
subjects(~[subjects.isdir]) = [];
if(~isempty(participants))
    subjects(~ismember({subjects.name},participants)) = [];
end
rejected_subs = {};
reject_indx = 1;

% Processing Dataset
if(isfile(fullfile(output_path,strcat(dt_name,'.mat'))))
    Dataset_info = load(fullfile(output_path,strcat(dt_name,'.mat')));
    count = length(Dataset_info.Participants) + 1;
else
    Dataset_info.Name = dt_name;
    count = 1;
end
for i=1:length(subjects)
    subject = subjects(i);
    subID = subject.name;
    Dataset_info.Participants(count).SubID = subID;
    disp(strcat("-->> Processing subject: ", subID));
    disp('==========================================================================');
    preproc_file = fullfile(output_path,strcat(subID,strrep(ref_file,'SubID',subID),'_preproc.set'));
    if(~isfile(preproc_file))
        try
            %%
            %% step 1: loading data
            %%
            EEG = import_eeg_process(properties,subject);

            %%
            %% step 3: Import and edit channels
            %%
            EEG = import_channels_process(properties,EEG);

            %%
            %% step 2: Import and edit eventes (Open_eyes)
            %%
            if(properties.dataset.events.Select)
                EEG = import_events_process(properties,EEG);
            end

            %%
            %% step 4: cleaning data
            %%
            EEG = clean_data_process(properties,EEG);

            %%
            %% step 5: computing activity and connectivity at sensor and source levels
            %%
            EEG = tf_estimation_process(properties,EEG);
            fig =  figure(1);
            clf;
            plot(EEG.sen.freqs,squeeze(mean(EEG.sen.tf,3)))
            % Save the figure
            saveas(gcf, fullfile(EEG.filepath,'PSD.jpg'));
            delete(fig);
            disp("-->> Saving the Preproc EEG on disk.");
            preproc_file = fullfile(output_path,strcat(EEG.filename,'_preproc.set'));
            save(preproc_file,"-struct",'EEG','-mat','-v7.3');

            %%          
            %% Step 6: Create report
            %%
            Dataset_info = report_process(properties,Dataset_info,preproc_file);

        catch
            rejected_subs{reject_indx} = subID;
            reject_indx = reject_indx + 1;
        end
    end
end

%% Saving reports files
excel_name = fullfile(output_path,strcat('NIM_EEG_preproc.xlsx'));
if(length(Dataset_info.Name)>30)
    sheet_name = strcat(extractBefore(Dataset_info.Name,31));
else
    sheet_name = strcat(Dataset_info.Name);
end
table =struct2table(Dataset_info.Participants);
writetable(table, excel_name, 'Sheet', sheet_name,'WriteVariableNames', true);
writetable(table, fullfile(output_path,strcat(Dataset_info.Name,'.xlsx')));
save(fullfile(output_path,strcat(Dataset_info.Name,".mat")),'-Struct','Dataset_info');

[~,dt_name,~] = fileparts(dataset_path);
save(fullfile(output_path,strcat('rejected_subs.mat')),'rejected_subs','dt_name');

disp('--------------------------Process finished.-------------------------------');
end

