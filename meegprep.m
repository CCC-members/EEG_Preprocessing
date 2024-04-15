function meegprep(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Automatic MEEG cleaning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (25-Sep-2019) or higher
%


% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%
%    November 15, 2019


%% Preparing WorkSpace
clc;
close all;
clearvars -except varargin;
disp('-->> Starting process');
% restoredefaultpath;

%%
%------------ Preparing properties --------------------
% brainstorm('stop');
addpath(genpath('app'));
addpath(genpath('config_properties'));
addpath(genpath('functions'));
addpath(genpath('guide'));
addpath('templates');
addpath('tools');
load('tools/mycolormap.mat');

%%
%% Init processing
%%
init_processing("app/properties.json");

%%
%% Starting mode
%%
setGlobalGuimode(true);
for i=1:length(varargin)
    if(isequal(varargin{i},'nogui'))
        setGlobalGuimode(false);
    end
end
if(getGlobalGuimode())
    MEEGprepUI
else
    %% ------------  Checking app properties --------------------------
    properties  = get_properties();
    if(isequal(properties,'canceled'))
        return;
    end
    [status, reject_subjects]    = check_properties(properties);
    if(~status)
        fprintf(2,strcat('\nBC-V-->> Error: The current configuration files are wrong \n'));
        disp('Please check the configuration files.');
        return;
    end

    %%
    %% Starting EEGLAB
    %%
    addpath(properties.general_params.eeglab.base_path);
    eeglab nogui;    

    %%
    %% Calling dataset function to analysis
    %%
    process_error = process_interface(properties, reject_subjects);
end
restoredefaultpath;
disp('-->> Process finished...');
disp("=================================================================");
close all;
clear all;
end



