function EEGs = process_import_eeg(properties,subject)

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
            EEGs = EEG;
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
        case '.mff'
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
            EEG.subject = subID;
            EEG.filename = filename;
            EEG.filepath = fullfile(subject.folder,subject.name,ref_path);
            EEGs = EEG;
        case '.asc'
            if(properties.general_params.meeg_data.segments)
                files = dir(fullfile(basepath,'*.asc'));
                files([files.isdir]) = [];                
                for i=1:length(files)
                    file = files(i);
                    EEG                     = eeg_emptyset;
                    EEG.filename            = strrep(file.name,'.asc','');
                    EEG.filepath            = basepath;
                    EEG.subject             = subID;
                    EEG.srate               = 500;
                    data = readmatrix(fullfile(file.folder,file.name));
                    EEG.data = data';
                    table = readtable(fullfile(file.folder,file.name));
                    labels = table.Properties.VariableNames;
                    if(contains(labels,'_CPz'))
                        ref_chann = 'CPz';
                    elseif(contains(labels,'_Cz'))
                        ref_chann = 'Cz';
                    else
                        ref_chann = 'Ave';
                    end
                    labels              = replace(replace(labels,'_CPz',''),'_Cz','');
                    EEG.chanlocs            = cell2struct(labels,'labels');
                    EEG.nbchan              = length(EEG.chanlocs);
                    EEG.pnts                = size(EEG.data,2);
                    EEG.xmin                 = 0;
                    EEG.xmax                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
                    EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
                    EEG.trials              = 1;
                    EEGs(i) = EEG;                    
                end
            else
                EEG                     = eeg_emptyset;
                EEG.filename            = filename;
                EEG.filepath            = fullfile(subject.folder,subject.name,ref_path);
                EEG.subject             = subID;
                data = readmatrix(fullfile(subject.folder,subject.name,ref_path,strcat(filename,'.asc')));
                data                    = data';
                EEG.data                = data;
                EEG.pnts                = size(data,2);
                EEG.xmin                 = 0;
                EEG.xmax                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
                EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
                EEG.trials              = 1;
            end
        case '.mat'
            data_info = load(fullfile(file));            
            if(isfield(data_info,'selectedData'))
                EEG                 = eeg_emptyset;
                EEG.filename        = filename;
                EEG.filepath        = fullfile(subject.folder,subject.name);
                EEG.subject         = subID;
                EEG.srate           = 128;
                labels              = jsondecode(fileread(properties.general_params.meeg_data.labels));
                EEG.chanlocs        = cell2struct(labels','labels');
                EEG.nbchan          = length(EEG.chanlocs);
                data                = data_info.selectedData;
                EEG.data            = data;
                EEG.pnts            = size(data,2);
                EEG.xmin            = 0;
                EEG.xmax            = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
                EEG.times           = (0:EEG.pnts-1)/EEG.srate.*1000;
                EEG.trials          = 1;               
                EEGs                = EEG;
            end
            if(isequal(properties.general_params.meeg_data.format,'spectrum'))
                data_info = data_info.data_struct;
                EEG                 = eeg_emptyset;
                EEG.filename        = filename;
                EEG.filepath        = fullfile(subject.folder,subject.name);
                EEG.subject         = subID;
                EEG.srate           = data_info.srate;
                EEG.chanlocs        = cell2struct(data_info.dnames','labels'); 
                EEG.CrossM          = data_info.CrossM;
                EEG.EEGMachine      = data_info.EEGMachine;
                EEG.fmax            = data_info.fmax;
                EEG.fmin            = data_info.fmin;
                EEG.freqrange       = data_info.freqrange;
                EEG.nbchan          = data_info.nchan;
                EEG.nepochs         = data_info.nepochs;
                EEG.nt              = data_info.nt;
                EEG.ref             = data_info.ref;
                EEG.Spec            = data_info.Spec;
                EEG.Spec_freqrange  = data_info.Spec_freqrange;
                EEG.trials          = 1;
                EEGs = EEG;

                pInfo.SubID = subID;
                pInfo.Age = data_info.age;
                pInfo.Gender = data_info.sex;
                if(isfile(fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json')))
                    participants = jsondecode(fileread(fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json')));
                    participants(end+1) = pInfo;
                else
                    participants(1) = pInfo;
                end
                saveJSON(participants,fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json'));                     
            end
    end
   
    % Getting Participants description
    partic_file = fullfile(properties.general_params.meeg_data.base_path,properties.general_params.meeg_data.participants_file);
    if(isfile(partic_file))
        [~,~,extP] = fileparts(partic_file);
        if(isequal(extP,'.json'))
            parts = jsondecode(fileread(partic_file));
            pInfo = parts(find(ismember({parts.SubID},subID),1));
            pInfo.Nchan = EEG.nbchan;
            pInfo.RefChann = ref_chann;
            pInfo.NSegments = length(files);
        else
            opts        = detectImportOptions(partic_file, FileType="text");
            parts       = table2struct(readtable(partic_file,opts));
            participantR = parts(find(ismember({parts.participant_id},subID),1));
            pInfo.SubID = participantR.participant_id;
            pInfo.Nchan = EEG.nbchan;
            pInfo.Sex = participantR.sex;
        end
        
        if(isfile(fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json')))
            participants = jsondecode(fileread(fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json')));
            participants(end+1) = pInfo;
        else
            participants(1) = pInfo;
        end       
        saveJSON(participants,fullfile(properties.general_params.workspace.base_path,'eeglab','Participants.json'));
    end   

elseif(isequal(modality,'MEG'))
    MEEGs = import_meg_format(subID, preprocessed_params, data_path);
else
    MEEGs = load(data_path);
    MEEGs = MEEGs.data_struct;
end

end

