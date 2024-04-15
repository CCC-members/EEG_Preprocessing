function EEG = get_eeg_by_events(EEG,event_1,event_2)

events = [EEG.event];
regions = struct;
for i=1:length(events)-1
    if(isequal(events(i).type, event_1))
        break;
    else
        regions(i).type     = events(i).type;
        regions(i).start    = events(i).latency;
        regions(i).end      = events(i+1).latency;
    end
end
if(i==1)
    regions(i).type     = events(i).type;
    regions(i).start    = 0;
    regions(i).end      = events(i).latency;
end

times  = [regions.start; regions.end]';
EEG = pop_select(EEG, 'time', times);
end

