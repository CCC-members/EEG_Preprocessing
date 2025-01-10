%%
%% Update Multinational Norm data structure
%%
disp("=====================================================================");
disp("************************ Strarting process **************************");
disp("=====================================================================");
root_path = "E:\Data\MultinationalNorm";

datasets = dir(root_path);
datasets(ismember({datasets.name},{'..','.'})) = [];

for i=1:length(datasets)
    disp("-----------------------------------------------------------------");
    disp(strcat("-->> Processing dataset: ",dataset.name));
    dataset = datasets(i);
    files = dir(fullfile(dataset.folder,dataset.name));
    files(ismember({files.name},{'..','.'})) = [];

    for j=1:length(files)
        file = files(j);
        [~,subID,ext] = fileparts(file.name);
        disp(strcat("---->> Processing subject: ",subID));
        subject_path = fullfile(file.folder,subID);
        if(~isfolder(subject_path))
            mkdir(subject_path);
        end  
        movefile(fullfile(file.folder,file.name),fullfile(subject_path,strcat('sub-',subID,'_task-resting_desc-spectrum.mat')));
    end
    mkdir(fullfile(dataset.folder,dataset.name,derivatives));
end



%%
%% Data report
%%


