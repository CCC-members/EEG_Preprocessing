function save_error = save_output_files(varargin)

save_error = [];
%%
%% Creating structure for each selected event
%%

for i=1:length(varargin)
   eval([inputname(i) '= varargin{i};']); 
end

if(isequal(action,'new'))
    % Creating subject folder structure
    disp(strcat("-->> Creating subject output structure"));
    subID = MEEG.subID;
    action = 'meeg';
    [output_subject_dir] = create_data_structure(base_path,subID,action);
    subject_info = struct;
    if(isfolder(output_subject_dir))
        subject_info.name           = MEEG.subID;
        subject_info.modality       = modality;
        dirref                      = replace(fullfile('meeg','meeg.mat'),'\','/');
        subject_info.meeg_dir  = dirref;       
    end
    disp ("-->> Saving meeg file");
    save(fullfile(base_path,MEEG.subID,subject_info.meeg_dir),'-struct','MEEG');    
    disp ("-->> Saving subject file");
    save(fullfile(output_subject_dir,'subject.mat'),'-struct','subject_info');
end
if(isequal(action,'update'))
    % Updating subject files
    dirref = replace(fullfile('meeg','meeg.mat'),'\','/');
    subject_info.meeg_dir = dirref;
    disp ("-->> Saving MEEG file");
    if(~isfolder(fullfile(base_path,MEEG.subID,'meeg')))
        mkdir(fullfile(base_path,MEEG.subID,'meeg'));
    end
    save(fullfile(base_path,MEEG.subID,subject_info.meeg_dir),'-struct','MEEG');
    disp ("-->> Saving channel file");
    save(fullfile(base_path,MEEG.subID,subject_info.channel_dir),'-struct','Cdata');
    disp ("-->> Saving leadfield file");
    save(fullfile(base_path,MEEG.subID,subject_info.leadfield_dir),'-struct','HeadModel');
    disp ("-->> Saving subject file");
    save(fullfile(base_path,MEEG.subID,'subject.mat'),'-struct','subject_info');
end
if(isequal(action,'event'))
    % Creating subject folder structure
    disp(strcat("-->> Creating subject output structure"));
    subID = MEEG.subID;
    action = 'all';
    [output_subject_dir]        = create_data_structure(base_path,subID,action);        
    subject_info.name           = MEEG.subID;
    dirref                      = replace(fullfile('leadfield',strcat(HeadModel.Comment,'.mat')),'\','/');
    subject_info.leadfield_dir  = dirref;
    dirref                      = replace(fullfile('surf','surf.mat'),'\','/');
    subject_info.surf_dir       = dirref;
    dirref                      = replace(fullfile('channel','channel.mat'),'\','/');
    subject_info.channel_dir    = dirref;
    dirref                      = replace(fullfile('scalp','scalp.mat'),'\','/');
    subject_info.scalp_dir      = dirref;
    dirref                      = replace(fullfile('scalp','innerskull.mat'),'\','/');
    subject_info.innerskull_dir = dirref;
    dirref                      = replace(fullfile('scalp','outerskull.mat'),'\','/');
    subject_info.outerskull_dir = dirref;
    % Saving subject files
    disp ("-->> Saving MEEG file");
    save(fullfile(output_subject_dir,subject_info.meeg_dir),'-struct','MEEG');
    disp ("-->> Saving channel file");
    save(fullfile(output_subject_dir,subject_info.channel_dir),'-struct','Cdata');
    disp ("-->> Saving leadfield file");
    save(fullfile(output_subject_dir,subject_info.leadfield_dir),'-struct','HeadModel');
    disp ("-->> Saving scalp file");
    save(fullfile(output_subject_dir,'scalp','scalp.mat'),'-struct','Shead');
    disp ("-->> Saving outer skull file");
    save(fullfile(output_subject_dir,'scalp','outerskull.mat'),'-struct','Sout');
    disp ("-->> Saving inner skull file");
    save(fullfile(output_subject_dir,'scalp','innerskull.mat'),'-struct','Sinn');
    disp ("-->> Saving surf file");
    save(fullfile(output_subject_dir,'surf','surf.mat'),'-struct','Scortex');
    disp ("-->> Saving subject file");
    save(fullfile(output_subject_dir,'subject.mat'),'-struct','subject_info');    
end


end



