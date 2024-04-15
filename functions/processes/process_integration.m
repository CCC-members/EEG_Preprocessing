function  CiftiStorm = process_integration(properties, CiftiStorm, MEEGs, subID)

general_params = properties.general_params;
modality = general_params.modality;
eeglab_path = fullfile(general_params.workspace.base_path,'eeglab');
EEG_path = fullfile(eeglab_path,subID);
EEG_file = dir(EEG_path);
EEG_file([EEG_file.isdir]==1) = [];

for i=1:length(EEG_file)
    MEEGs(i).EEG = load(fullfile(EEG_file(i).folder,EEG_file(i).name),'-mat');
    [~,filename,~] = fileparts(EEG_file(i).name);
    MEEGs(i).filename = filename;
end


MEEG                    = MEEGs(1).EEG;
%%
%% Filter Channels and LeadField by Preprocessed MEEG
%%
base_path               = fullfile(general_params.workspace.base_path);
if(general_params.workspace.anat_template.use_template)
    template_name       = general_params.workspace.anat_template.template_name;
    cfs_path            = fullfile(base_path,strcat("ciftistorm-",template_name),template_name);
else
    cfs_path            = fullfile(base_path,subID);
end
subject_info            = jsondecode(fileread(fullfile(cfs_path,strcat(template_name,'.json'))));
Cdata                   = load(fullfile(cfs_path,subject_info.channel_dir));
HeadModels              = load(fullfile(cfs_path,subject_info.leadfield_dir.leadfield));
if(isequal(modality,'EEG'))
    labels              = {MEEGs(i).EEG.chanlocs(:).labels};
elseif(isequal(modality,'MEG'))
    labels              = MEEG.labels;
else
    labels              = MEEG.dnames;
end
[Cdata, HeadModel]      = filter_structural_result_by_preproc_data(labels, Cdata, HeadModels.HeadModel);
HeadModels.HeadModel    = HeadModel;

%%
%% Exporting files
%%
if(general_params.workspace.anat_template.use_template)
    Shead               = load(fullfile(cfs_path,subject_info.headmodel_dir.scalp));
    Sout                = load(fullfile(cfs_path,subject_info.headmodel_dir.outerskull));
    Sinn                = load(fullfile(cfs_path,subject_info.headmodel_dir.innerskull));
    Scortex             = load(fullfile(cfs_path,subject_info.sourcemodel_dir));
    AQCI                = load(fullfile(cfs_path,subject_info.leadfield_dir.AQCI));
    action              = 'new';
    base_path           = fullfile(base_path,strcat("ciftistorm-",template_name));
    save_output_files(action, base_path, subject_info, subID, HeadModels, AQCI,Cdata, MEEGs, Shead, Sout, Sinn, Scortex);
else
    Shead               = load(fullfile(cfs_path,subject_info.scalp_dir));
    Sout                = load(fullfile(cfs_path,subject_info.outerskull_dir));
    Sinn                = load(fullfile(cfs_path,subject_info.innerskull_dir));
    Scortex             = load(fullfile(cfs_path,subject_info.surf_dir));
    action              = 'update';
    save_output_files(action, base_path, subject_info, HeadModels, Cdata, MEEGs(i));
end


end

