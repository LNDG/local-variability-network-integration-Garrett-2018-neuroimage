%% Load, Filter and Save a NIfTI
% This function bandpass filters unfiltered nifti files with restfmri
% bandpassfilter rest_bandpass.m. Filtering is performed with a
% rectangular window. Rest toolbox V1.8_130615 was used. Also used spm8.
% Input: functional nifti
% Output: bandpass filtered nifti
% Parameters: TR, low and high cutoff frequencies, adjust in script below!

%% NOTES:

% The script requires the user to alter a preproc_mat_config file in which
% the ProjectPath and SubjectList are stated.

% Please run the script while in the */NKI_enhanced_rest/A_preproc/scripts
% folder so as to properly access the preproc_mat_config file.

%% Add paths & SubjetList

[ProjectPath,SubjectList]=preproc_mat_config;

addpath(genpath([ProjectPath, 'E_toolboxes/REST_V1.8_130615']))
addpath(genpath([ProjectPath, 'E_toolboxes/spm8']))

%% loop over subjects
for i=1:numel(SubjectList)
    
%% Variable Paths

RESTPATH = ([ProjectPath 'A_preproc/data/', SubjectList{i}, '/rest']);
FEATDATA = ([RESTPATH, '/', SubjectList{i}, '.feat/filtered_func_data.nii.gz']);
BANDPATH = ([RESTPATH, '/bandpass']);

%% Copy data

mkdir ([BANDPATH, '/data']);
copyfile (FEATDATA, [BANDPATH, '/data']);
cd (BANDPATH);

%% Bandpass Filter

% Adjust parameters, for detail see help rest_bandpass.m

ADataDir = 'data';
ASamplePeriod = 0.645;
ALowPass_HighCutoff = 0.2;
AHighPass_LowCutoff = 0.01;
AAddMeanBack = 'yes';
AMaskFilename = 0;
CUTNUMBER = 10;

rest_bandpass(ADataDir, ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, AAddMeanBack, AMaskFilename, CUTNUMBER);

disp ([SubjectList{i}, ': filtering done']);

%% Clean up

disp ([SubjectList{i}, ': ZIPPING']);
movefile ([BANDPATH, '/data_filtered/Filtered_4DVolume.nii'], [RESTPATH, '/', SubjectList{i}, '_rest_feat_BPfilt.nii']);

gzip ([RESTPATH, '/', SubjectList{i}, '_rest_feat_BPfilt.nii']);
rmdir (BANDPATH, 's');
delete ([RESTPATH, '/', SubjectList{i}, '_rest_feat_BPfilt.nii']);

disp ([SubjectList{i}, ': clean up done']);

end