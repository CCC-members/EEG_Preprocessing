function OutEEGs = process_import_events(properties,EEGs)

select_events = properties.preproc_params.select_events.events;

for e=1:length(EEGs)
    EEG = EEGs(e);
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
    events = [EEG.event];

    for i=1:length(select_events)
        count = 1;
        regions = struct;
        filter = select_events{i};
       
        for j=1:length(events)-1
            if(isequal(events(j).type, filter))
                regions(count).type     = events(j).type;
                regions(count).start    = events(j).latency;
                regions(count).end      = events(j+1).latency;
                count = count + 1;
            end
        end
        if(isequal(events(end).type, filter))
            regions(count).type     = events(end).type;
            regions(count).start    = events(end).latency;
            regions(count).end      = EEG.times(end);
        end       
        try
            times  = [regions.start; regions.end]';
            newEEG = pop_select(EEG, 'point', times);
            newEEG.task = filter;
            OutEEGs(i) = eeg_checkset(newEEG);            
        catch Ex
            disp('--------------------------------------------------------------------------');
            disp("-->> ERROR");
            disp(Ex.message);
            disp('--------------------------------------------------------------------------');
            continue;
        end
    end
    % EEGs(i+1).task = 'protmap';
    % EEGs(i+1) = EEG;
end
end