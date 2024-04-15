function save_error = save_output_files(varargin)

save_error = [];
%%
%% Creating structure 
%%

for i=1:length(varargin)
   eval([inputname(i) '= varargin{i};']); 
end

if(isequal(action,'new'))
    disp(strcat("-->> Creating subject output structure"));
    action = 'all';
    [output_subject_dir]                    = create_data_structure(base_path,subID,action); 
    subject_info                            = struct;
    subject_info.name                       = subID;
    for i=1:length(MEEGs)
        MEEG = MEEGs(i);
        subject_info.meeg_dir{i}            = replace(fullfile('meeg',strcat(MEEG.filename,'.mat')),'\','/');
    end
    subject_info.leadfield_dir.leadfield    = replace(fullfile('leadfield','leadfield.mat'),'\','/');
    subject_info.leadfield_dir.AQCI         = replace(fullfile('leadfield','AQCI.mat'),'\','/');
    subject_info.sourcemodel_dir            = replace(fullfile('sourcemodel','cortex.mat'),'\','/');
    subject_info.channel_dir                = replace(fullfile('channel','channel.mat'),'\','/');
    subject_info.headmodel_dir.scalp        = replace(fullfile('headmodel','scalp.mat'),'\','/');
    subject_info.headmodel_dir.innerskull   = replace(fullfile('headmodel','innerskull.mat'),'\','/');
    subject_info.headmodel_dir.outerskull   = replace(fullfile('headmodel','outerskull.mat'),'\','/');
    subject_info.completed                  = true;
    
    % Saving subject files
    disp ("-->> Saving MEEG file");   
    for i=1:length(MEEGs)
        EEG = MEEGs(i).EEG;
        save(fullfile(output_subject_dir,subject_info.meeg_dir{i}),'-struct','EEG');
    end
    disp ("-->> Saving channel file");
    save(fullfile(output_subject_dir,subject_info.channel_dir),'-struct','Cdata');
    disp ("-->> Saving leadfield file");
    save(fullfile(output_subject_dir,subject_info.leadfield_dir.leadfield),'-struct','HeadModels');
    disp ("-->> Saving AQCI file");
    save(fullfile(output_subject_dir,subject_info.leadfield_dir.AQCI),'-struct','AQCI');
    disp ("-->> Saving scalp file");
    save(fullfile(output_subject_dir,subject_info.headmodel_dir.scalp),'-struct','Shead');
    disp ("-->> Saving outer skull file");
    save(fullfile(output_subject_dir,subject_info.headmodel_dir.outerskull),'-struct','Sout');
    disp ("-->> Saving inner skull file");
    save(fullfile(output_subject_dir,subject_info.headmodel_dir.innerskull),'-struct','Sinn');
    disp ("-->> Saving surf file");
    save(fullfile(output_subject_dir,subject_info.sourcemodel_dir),'-struct','Scortex');
    disp ("-->> Saving subject file");
    saveJSON(subject_info,fullfile(output_subject_dir,strcat(subID,'.json')));
end
if(isequal(action,'update'))
    % Updating subject files
    subject_info.meeg_dir   = replace(fullfile('meeg','meeg.mat'),'\','/');
    subject_info.completed  = true;
    
    disp ("-->> Saving MEEG file");
    if(~isfolder(fullfile(base_path,subID,'meeg')))
        mkdir(fullfile(base_path,subID,'meeg'));
    end
    save(fullfile(base_path,subID,subject_info.meeg_dir),'-struct','MEEG');
    disp ("-->> Saving channel file");
    save(fullfile(output_subject_dir,subject_info.channel_dir),'-struct','Cdata');
    disp ("-->> Saving leadfield file");
    save(fullfile(output_subject_dir,subject_info.leadfield_dir.leadfield),'-struct','HeadModels');
    disp ("-->> Saving subject file");
    save(fullfile(base_path,subID,'subject.mat'),'-struct','subject_info');
end
end



