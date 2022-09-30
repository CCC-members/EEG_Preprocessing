function EEGs = import_eeg_format(subID, properties, data_path)

data_type    = properties.format;
if(~isequal(properties.channel_label_file,"none") && ~isempty(properties.channel_label_file))
    user_labels = jsondecode(fileread(properties.channel_label_file));   
else
    user_labels = [];
end
if(~isequal(properties.electrodes_file,"none") && ~isempty(properties.electrodes_file))
    filepath = strrep(properties.electrodes_file,'SubID',subID);
    base_path =  properties.base_path;
    electrodes_file = fullfile(base_path,subID,filepath);    
    if(isfile(electrodes_file))
        electrodes = tsvread(electrodes_file);
        user_labels = electrodes.name;
    end
end
if(~isequal(properties.derivatives_file,"none") && ~isempty(properties.derivatives_file))
    derivatives_file = strrep(properties.derivatives_file,'SubID',subID);
    if(isfile(derivatives_file))
        derivatives = tsvread(derivatives_file);
    else
        derivatives = [];
    end
else
    derivatives = [];
end

toolbox_path        = properties.clean_data.toolbox_path;
max_freq            = properties.clean_data.max_freq;
chan_action         = properties.clean_data.rej_or_interp_chan.action;
select_events       = properties.clean_data.select_events;
clean_art_params    = properties.clean_data.clean_artifacts;
decompose_ica       = properties.clean_data.decompose_ica;
report_output_path  = properties.general_params.reports.output_path;
subject_report_path = fullfile(report_output_path,subID);
if(~isfolder(subject_report_path))
    mkdir(subject_report_path);
end
EEGs      = eeglab_preproc(subID, data_path, data_type, toolbox_path, 'verbosity', true, 'max_freq', max_freq,...
    'labels', user_labels, 'select_events', select_events, 'derivatives', derivatives,...
    'save_path', subject_report_path, 'chan_action', chan_action, 'clean_art_params', clean_art_params, 'decompose_ica', decompose_ica);
for i=1:length(EEGs)
    EEGs(i).labels   = {EEGs(i).chanlocs(:).labels};
end

end
