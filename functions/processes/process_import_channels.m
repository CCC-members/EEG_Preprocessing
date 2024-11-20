function EEGs = process_import_channels(properties,EEGs)

for e=1:length(EEGs)
    EEG = EEGs(e);
    meeg_params = properties.general_params.meeg_data;
    if(meeg_params.BIDS)
        channels_filename    = strrep(EEG.filename,'eeg','channels');
        opts = detectImportOptions(fullfile(EEG.filepath,strcat(channels_filename,'.tsv')), FileType="text");
        chanlocs_raw         = table2struct(readtable(fullfile(EEG.filepath,strcat(channels_filename,'.tsv')),opts));
        [EEG.chanlocs.type] =  chanlocs_raw(:).type;
        [EEG.chanlocs.sampling_frequency] =  chanlocs_raw(:).sampling_frequency;
        [EEG.chanlocs.low_cutoff] =  chanlocs_raw(:).low_cutoff;
        [EEG.chanlocs.high_cutoff] =  chanlocs_raw(:).high_cutoff;
    end

    % Load the channel locations into the EEG structure
    chan_template = dir(fullfile(properties.general_params.eeglab.base_path,'plugins','dipfit*','**','standard_1005.elc'));
    chan_template_file = fullfile(chan_template.folder,chan_template.name);
    EEG                             = pop_chanedit(EEG, 'lookup',chan_template_file,'eval','chans = pop_chancenter( chans, [],[]);');
    no_channels = {};
    count = 1;
    for i=1:length(EEG.chanlocs)
        if(isempty(EEG.chanlocs(i).X) && isempty(EEG.chanlocs(i).Y) && isempty(EEG.chanlocs(i).Z))
            no_channels{count} = EEG.chanlocs(i).labels;
            count = count + 1;
        end
    end
    if ~isempty(no_channels)
        EEG = pop_select(EEG, 'nochannel', no_channels);
    end
    [EEG,changes] = eeg_checkset(EEG);

    % data_type    = data_params.format;
    %         if(~isequal(channel_label_file,"none") && ~isempty(channel_label_file))
    %             user_labels = jsondecode(fileread(channel_label_file));
    %         else
    %             user_labels = [];
    %         end
    %         if(~isequal(data_params.electrodes_file,"none") && ~isempty(data_params.electrodes_file))
    %             filepath = strrep(data_params.electrodes_file,'SubID',subID);
    %             base_path =  data_params.base_path;
    %             electrodes_file = dir(fullfile(base_path,subID,'**',filepath));
    %             electrodes_file = fullfile(electrodes_file.folder,electrodes_file.name);
    %             if(isfile(electrodes_file))
    %                 electrodes = tsvread(electrodes_file);
    %                 user_labels = electrodes.name;
    %             end
    %         end
    %         if(~isequal(data_params.derivatives_file,"none") && ~isempty(data_params.derivatives_file))
    %             file_name = strrep(data_params.derivatives_file,'SubID',subID);
    %             derivatives_file = dir(fullfile(data_params.base_path,'derivatives','**',subID,'eeg',file_name));
    %             derivatives_file = fullfile(derivatives_file.folder,derivatives_file.name);
    %             if(isfile(derivatives_file))
    %                 derivatives = tsvread(derivatives_file);
    %             else
    %                 derivatives = [];
    %             end
    %         else
    %             derivatives = [];
    %         end
    %
    %
    %
    % % Read the TSV electrodes file
    %     channels_filename    = strrep(EEG.filename,'eeg','channels');
    %     opts = detectImportOptions(fullfile(EEG.filepath,strcat(channels_filename,'.tsv')), FileType="text");
    %     chanlocs_raw         = table2struct(readtable(fullfile(EEG.filepath,strcat(channels_filename,'.tsv')),opts));
    %
    %     %import convertion table
    %     if(properties.dataset.channels.converted)
    %         channel_file = strcat(properties.dataset.channels.from,'_to_',properties.dataset.channels.to,'.txt');
    %         opts = detectImportOptions(fullfile(pwd,'functions','tools',channel_file), FileType="text");
    %         table = table2struct(readtable(fullfile(pwd,'functions','tools',channel_file),opts));
    %         reject_indx = [];
    %         for i=1:length(EEG.chanlocs)
    %             label = EEG.chanlocs(i).labels;
    %             indx = find(ismember({table.BioSemi},label),1);
    %             if(~isempty(indx))
    %                 EEG.chanlocs(i).labels = table(indx).EasyCap;
    %             else
    %                 reject_indx = [reject_indx; i];
    %             end
    %         end
    %         EEG = pop_select(EEG, 'nochannel', reject_indx);
    %     end
    %
    EEGs(e) = EEG;
end

end