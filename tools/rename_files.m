root_path = "/mnt/Data/Talia/Test_Data";
subjects = dir(root_path);
subjects(ismember({subjects.name},{'.','..'})) = [];

for i=1:length(subjects)
    subject = subjects(i);
    files = dir(fullfile(subject.folder,subject.name));
    files([files.isdir]) = [];
    for j=1:length(files)
        file = files(j);
        name_parts = split(file.name,'_');
        name_no = name_parts{end};
       if(isequal(length(name_no),5))
            name_parts(end) = {strcat('0',name_no)};
            file_name = strcat(name_parts{1},'_',name_parts{2},'_',name_parts{end});
            movefile(fullfile(file.folder,file.name),fullfile(file.folder,file_name));
       end
    end
end