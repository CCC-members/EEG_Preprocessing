function OutEEGs = process_import_events(properties,EEGs)

for e=1:length(EEGs)
    EEG = EEGs(e);
    EEG.event = struct;
    meeg_params = properties.general_params.meeg_data;
    if(meeg_params.BIDS)
        event_filename = strrep(EEG.filename,'eeg','events');
        opts = detectImportOptions(fullfile(EEG.filepath,strcat(event_filename,'.tsv')), FileType="text");
        events_raw         = table2struct(readtable(fullfile(EEG.filepath,strcat(event_filename,'.tsv')),opts));
        % Fill in the structure
        for i = 1:length(events_raw)
            EEG.event(i).latency   = events_raw(i).onset;
            EEG.event(i).duration  = events_raw(i).duration;
            EEG.event(i).type     = events_raw(i).trial_type;
            EEG.event(i).sample   = events_raw(i).sample;
        end
    end
    OutEEGs(e) = EEG;
end

end

