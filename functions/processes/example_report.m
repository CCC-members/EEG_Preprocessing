  %%
    %%  Starting report
    %%
    % Creating a report
    report_name = subID;
    f_report('New');
    % Add a title to the report
    f_report('Title',strcat("EEG preprocessing: ",subID));
    % Add a title to the report
    f_report('Header',strcat("EEG preprocessing: ",subID));
         
    sub_report = fullfile(report_path,subID);
    if(~isfolder(sub_report))
        mkdir(sub_report);
    end








     % Add the footer info to the report
    footer_title = 'Organization';
    text = 'All rights reserved';
    copyright = '@copy CC-Lab';
    contact = 'cc-lab@neuroinformatics-collaboratory.org';
    references = {'https://github.com/CCC-members', 'https://www.neuroinformatics-collaboratory.org/'};
    
    f_report('Footer', footer_title, text, 'ref', references, 'copyright', copyright, 'contactus', contact);
    disp('-->> Saving report.');
    % Export the report
    disp('-->> Exporting report.');
    FileFormat = 'html';
    f_report('Export',sub_report, report_name, FileFormat);