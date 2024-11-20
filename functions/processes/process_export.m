function EEGs = process_export(properties,EEGs)

% sub-01_task-oddball_desc-preproc_eeg.set
% sub-001_ses-t1_task-resteyesc_desc-epochs_eeg.set
% sub-001_task-eyesclosed_eeg.set
% sub-01_task-oddball_desc-preproc_eeg.set
output_path = fullfile(properties.general_params.workspace.base_path,'eeglab');
if(~isfolder(output_path))
    mkdir(output_path);
end
subject_path = fullfile(output_path,EEGs(end).subject);
if(~isfolder(subject_path))
    mkdir(subject_path);
end
for i=1:length(EEGs)
    EEG     = EEGs(i);
    file_sec = split(EEG.filename,'_');
    SubID   = file_sec{1};
    task    = strcat('task-',strrep(strrep(strrep(EEGs(i).task,'_',''),'-',''),' ',''));
    desc    = 'desc-preproc';
    if(properties.general_params.meeg_data.segments)
        filename = strcat(SubID,'_',task,'_',file_sec{end},'_',desc,'.set');
    else
        filename = strcat(SubID,'_',task,'_',desc,'_',file_sec{end},'.set');
    end
    save(fullfile(subject_path,filename),'-struct','EEG','-mat','-v7.3');
end

end

