

user_labels = jsondecode(fileread('D:/Develop/EEG_Preprocessing/config_labels/labels_chbm_58.json'));
eeglab_path = ""
template    = load('templates/EEG_template.mat');
load('templates/labels_nomenclature.mat');

% changing labels

orig_labels = labels_match(:,1);
for i=1:length(orig_labels)
    label = orig_labels{i};
    pos = find(strcmp({EEG.chanlocs.labels},num2str(label)),1);
    if(~isempty(pos))
        EEG.chanlocs(pos).labels = labels_match{i,2};
    end
end
chan_row    = template.EEG.chanlocs(1);
data_labels      = EEG.chanlocs;
for i=1:length(data_labels)
    chan_row.labels = data_labels(i).labels;
    new_chanlocs(i) = chan_row;
end
EEG.chanlocs = new_chanlocs;
EEG.chaninfo = template.EEG.chaninfo;

% deleting channels
data        = EEG.data;
labels      = {EEG.chanlocs.labels}';
from        = 1;
limit       = size(data,1);
clean_labels = {size(user_labels,1),1};
for i=1:length(user_labels)
    clean_labels{i} = strrep(user_labels{i},' ','');
end
while(from <= limit)
    pos = find(strcmpi(labels{from}, clean_labels), 1);
    if (isempty(pos))
        data(from,:)    = [];
        labels(from)    = [];
        limit           = limit - 1;        
    else
        from = from + 1;
    end
end
EEG.data                    = data;
rej_indms                   = length(labels)+1:length(EEG.chanlocs);
EEG.chanlocs(rej_indms)     = [];
[EEG.chanlocs.labels]       = labels{:};
EEG.nbchan                  = size(data,1);


% setting coordinates
EEG         = pop_chanedit(EEG, 'lookup',fullfile(eeglab_path,'plugins/dipfit/standard_BEM/elec/standard_1005.elc'),'eval','chans = pop_chancenter( chans, [],[]);');
clear_ind   = [];
for i=1:length(EEG.chanlocs)
    if(isempty(EEG.chanlocs(i).X))
        clear_ind = [clear_ind; i];
    end
end
EEG.chanlocs(clear_ind) = [];
EEG.data(clear_ind,:)   = [];
EEG.nbchan              = length(EEG.chanlocs);



