function Dataset_info = report_process(properties,Dataset_info,preproc_file)

dataset_path = properties.dataset.root_path;
participants_file = fullfile(dataset_path,"participants.tsv");
if(isfile(participants_file))
    opts = detectImportOptions(participants_file, FileType="text");
    participantsT = table2struct(readtable(participants_file,opts));
end


[base_path,file_name,ext] = filepath(preproc_file);
parts = split(file_name,'_');
%% Session
ind_ses = find(contains(parts,{'ses'}),1);
if(~isempty(ind_ses))
    session = split(parts(ind_ses),'-');
    Dataset_info.Participants(end).Session = session{2};
end
if(isfile(participants_file))
    p_pos = find(ismember({participantsT.participant_id},parts{1}));
    if(~isempty(p_pos))
        if(isfield(participantsT,'type'))
            Dataset_info.Participants(end).Type = participantsT(p_pos).type;
        end
        %% Gender
        if(isfield(participantsT,'sex'))
            Dataset_info.Participants(end).Gender = participantsT(p_pos).sex;
        elseif(isfield(participantsT,'Sex'))
            Dataset_info.Participants(end).Gender = participantsT(p_pos).Sex;
        elseif(isfield(participantsT,'Gender'))
            Dataset_info.Participants(end).Gender = participantsT(p_pos).Gender;
        elseif(isfield(participantsT,'gender'))
            Dataset_info.Participants(end).Gender = participantsT(p_pos).gender;
        end
        %% Age
        if(isfield(participantsT,'age'))
            Dataset_info.Participants(end).Age = participantsT(p_pos).age;
        elseif(isfield(participantsT,'Age'))
            Dataset_info.Participants(end).Age = participantsT(p_pos).Age;
        else
            Dataset_info.Participants(end).Age = "0-1";
        end
        if(isfield(participantsT,'hand'))
            Dataset_info.Participants(end).Hand = participantsT(p_pos).hand;
        end
        if(isfield(participantsT,'Handedness'))
            Dataset_info.Participants(end).Hand = participantsT(p_pos).Handedness;
        end
        if(isfield(participantsT,'YOB'))
            Dataset_info.Participants(end).YOB = participantsT(p_pos).YOB;
        end
        if(isfield(participantsT,'Group'))
            Dataset_info.Participants(end).Group = participantsT(p_pos).Group;
        end
    end
end
%% Task or run
ind_task = find(contains(parts,{'task'}),1);
if(~isempty(ind_task))
    task = split(parts(ind_task),'-');
    Dataset_info.Participants(end).Task = task{2};
end
ind_run = find(contains(parts,{'run'}),1);
if(~isempty(ind_run))
    run = split(parts(ind_run),'-');
    Dataset_info.Participants(end).Run = run{2};
end
%% Other data
if(isfile(participants_file))
    if(~isempty(p_pos))
        if(isfield(participantsT,'race'))
            Dataset_info.Participants(end).Race = participantsT(p_pos).race;
        end
        if(isfield(participantsT,'ethnicity'))
            Dataset_info.Participants(end).Ethnicity = participantsT(p_pos).ethnicity;
        end
        if(isfield(participantsT,'education_level'))
            Dataset_info.Participants(end).Education_level = participantsT(p_pos).education_level;
        end
        if(isfield(participantsT,'MoodManipulationGroup'))
            Dataset_info.Participants(end).MoodManipulationGroup = participantsT(p_pos).MoodManipulationGroup;
        end
        if(isfield(participantsT,'medicationUse'))
            Dataset_info.Participants(end).medicationUse = participantsT(p_pos).medicationUse;
        end
    end
end
Dataset_info.Participants(end).Preproc_file = file.name;
end

