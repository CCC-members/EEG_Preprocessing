function EEG = process_import_eeg(properties,subject)

% Getting params

modality    = properties.general_params.modality;
subID       = subject.name;
ref_file    = properties.general_params.meeg_data.reference_file;
ref_path    = fileparts(ref_file);
file = fullfile(subject.folder,subject.name,strrep(ref_file,'SubID',subID));

[basepath, filename, ext] = fileparts(file);

if(isequal(modality,'EEG'))
    switch ext
        case '.edf'
            PLUGINLIST = evalin('base', 'PLUGINLIST');
            isInstalled = find(ismember({PLUGINLIST.plugin},{'Biosig'}),1);
            if(isempty(isInstalled) || ~isInstalled )
                plugin_askinstall('Biosig',[],1);
            end
            EEG = pop_biosig(file);
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
            EEG.data = double(EEG.data);
            new_labels              = replace({EEG.chanlocs.labels}','-REF','');
            [EEG.chanlocs.labels]   = new_labels{:};
            new_labels              = replace({EEG.chanlocs.labels}',' ','');
            [EEG.chanlocs.labels]   = new_labels{:};
            new_labels              = replace({EEG.chanlocs.labels}','-A12','');
            [EEG.chanlocs.labels]   = new_labels{:};
        case '.eeg'
            PLUGINLIST = evalin('base', 'PLUGINLIST');
            isInstalled = find(ismember({PLUGINLIST.plugin},{'Biosig'}),1);
            if(isempty(isInstalled) || ~isInstalled )
                plugin_askinstall('Biosig',[],1);
            end
            EEG = pop_biosig(file);
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
            EEG.data = double(EEG.data);

            new_labels              = replace({EEG.chanlocs.labels}','-REF','');
            [EEG.chanlocs.labels]   = new_labels{:};
            new_labels              = replace({EEG.chanlocs.labels}',' ','');
            [EEG.chanlocs.labels]   = new_labels{:};

        case '.set'
            EEG  = pop_loadset(file);
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);

        case '.dat'
            EEG                     = pop_loadBCI2000(file);
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
        case '.plg'
            try
                EEG                 = readplot_plg(fullfile(file));
                EEG.subject = subID;
                EEG.filename = filename;
                EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
            catch
                EEG                = [];
                return;
            end
            template                = eeg_emptyset;
            load('templates/labels_nomenclature.mat');
            orig_labels             = labels_match(:,1);
            for i=1:length(orig_labels)
                label               = orig_labels{i};
                pos                 = find(strcmp({EEG.chanlocs.labels},num2str(label)),1);
                if(~isempty(pos))
                    EEG.chanlocs(pos).labels = labels_match{i,2};
                end
            end
        case '.txt'
            EEG                     = eeg_emptyset;
            EEG.filename            = strrep(strrep(ref_file,'1.txt',''),'SubID',subID);
            EEG.filepath            = basepath;
            EEG.subject             = subID;
            labels                  = jsondecode(fileread(properties.general_params.meeg_data.labels));
            EEG.chanlocs            = cell2struct(labels','labels');  
            EEG.nbchan              = length(EEG.chanlocs);
            if(properties.general_params.meeg_data.trials)
                files = dir(basepath);
                files([files.isdir]) = [];
                for i=1:length(files)
                    file = files(i);
                    data = readmatrix(fullfile(file.folder,file.name));
                    data = data';
                    EEG.data{i} = data;
                end
                EEG.srate               = 100;
                EEG.pnts                = size(data,2);
                EEG.xmin                 = 0;
                EEG.xmax                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
                EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
                EEG.trials              = length(EEG.data);
            else
                [~,filename,~]          = fileparts(file);
                EEG.filename            = filename;
                EEG.filepath            = filepath;
                data                    = readmatrix(file);
                data                    = data';
                EEG.data                = data;
                EEG.subject             = subID;
                EEG.nbchan              = length(EEG.chanlocs);
                EEG.pnts                = size(data,2);
                EEG.srate               = 200;
                EEG.xmin                 = 0;
                EEG.xmax                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
                EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
            end          
        case 'mff'
            PLUGINLIST = evalin('base', 'PLUGINLIST');
            isInstalled = find(ismember({PLUGINLIST.plugin},{'Biosig'}),1);
            if(~isInstalled)
                plugin_askinstall('Biosig',[],1);
            end
            EEG                     = pop_readegimff(file);
        case '.vhdr'
            PLUGINLIST = evalin('base', 'PLUGINLIST');
            isInstalled = find(ismember({PLUGINLIST.plugin},{'bva-io'}),1);
            if(isempty(isInstalled) || ~isInstalled )
                plugin_askinstall('bva-io',[],1);
            end
            [base_path,hdrfile,extf] = fileparts(file);
            hdrfile = strcat(hdrfile,extf);
            [EEG, com] = pop_loadbv(base_path, hdrfile);
            EEG.srate = 1000;
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
    end
    % Downsalmpling data
    if(EEG.srate > 250)
        EEG = pop_resample(EEG,250);
    end
    if(properties.general_params.meeg_data.clean_data)
        min_freq = properties.preproc_params.clean_data.min_freq;
        max_freq = properties.preproc_params.clean_data.max_freq;
        EEG = pop_eegfiltnew(EEG, 'locutoff', min_freq, 'hicutoff',max_freq, 'filtorder', 3300);
        [EEG,changes] = eeg_checkset(EEG);
    end
elseif(isequal(modality,'MEG'))
    MEEGs = import_meg_format(subID, preprocessed_params, data_path);
else
    MEEGs = load(data_path);
    MEEGs = MEEGs.data_struct;
end

end

