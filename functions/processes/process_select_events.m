function OutEEGs = process_select_events(properties,EEGs)

select_events = properties.event_params.select_events;

EEGs(cellfun(@isempty, {EEGs.filename})) = [];
count = 1;
for e=1:length(EEGs)
    EEG = EEGs(e);
    if(~isempty(select_events))
        events = [EEG.event];
        for i=1:length(select_events)
            countE = 1;
            regions = struct;
            filter = select_events{i};
            for j=1:length(events)-1
                if(isequal(events(j).type, filter))
                    regions(countE).type     = events(j).type;
                    regions(countE).start    = events(j).latency;
                    regions(countE).end      = events(j+1).latency;
                    countE = countE + 1;
                end
            end
            if(isequal(events(end).type, filter))
                regions(countE).type     = events(end).type;
                regions(countE).start    = events(end).latency;
                regions(countE).end      = EEG.times(end);
            end
            try
                times  = [regions.start; regions.end]';
                newEEG = pop_select(EEG, 'point', times);
                newEEG.task = filter;
                OutEEGs(count) = eeg_checkset(newEEG);
                count = count + 1;
            catch Ex
                disp('--------------------------------------------------------------------------');
                disp("-->> ERROR");
                disp(Ex.message);
                disp('--------------------------------------------------------------------------');
                continue;
            end
        end
    elseif(properties.general_params.meeg_data.segments)
            segment = split(EEG.filename,'_');
            segment = split(segment{end},'-');
            segment = segment{end};
            EEG.segment = segment;
            EEG.task = 'Task';
            OutEEGs(count) = EEG;
            count = count + 1;        
    else
        EEG.task = 'Task';
        OutEEGs(count) = EEG;
        count = count + 1;
    end
end
OutEEGs(cellfun(@isempty, {OutEEGs.filename})) = [];
end