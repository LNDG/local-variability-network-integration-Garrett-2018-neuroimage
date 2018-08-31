%% Load, Detrend and Save a Nifti
% Detrend nifti using spm_detrend. spm8 was used.
% Input: preprocessed, registered nifti
% Output: detrended nifti
% Paramters: detrend, adjust in script below!

%% NOTES:

% The script requires the user to alter a preproc_mat_config file in which
% the ProjectPath and SubjectList are stated.

% Please run the script while in the */NKI_enhanced_rest/A_preproc/scripts
% folder so as to properly access the preproc_mat_config file.

%% Detrending to the cubic order

k=3;

%% Add paths & SubjetList

[ProjectPath,SubjectList]=preproc_mat_config;

addpath(genpath([ProjectPath, 'E_toolboxes/prepreocessing_tools']))
addpath(genpath([ProjectPath, 'E_toolboxes/NIfTI_20140122']))
addpath(genpath([ProjectPath, 'E_toolboxes/spm8']))

%% Loop over subjects
for i=1:numel(SubjectList)
%% Get exact file location

disp(['Processing subject ' SubjectList{i} ])

RESTPATH=([ProjectPath, 'A_preproc/data/', SubjectList{i}, '/rest/' ]);
fname = ([RESTPATH, SubjectList{i} '_rest_feat_BPfilt_denoised_MNI2mm_flirt']);

%% Load & reshape nifti
% check in datafolder if nifit ends with .nii or .nii.gz and load
% specific file (x by y by z by time)
disp('loading nifti')
if exist([fname, '.nii.gz'], 'file') == 2
    nii = load_nii ([fname, '.nii.gz']);
    
elseif exist([fname, '.nii'], 'file') == 2
    nii = load_nii ([fname, '.nii']);
    
else
    disp ([fname, ' not found!']);
end

disp('loading: done')

% 4 here refers to 4th dimension in 4D file (time).
data = double(reshape(nii.img,[],size(nii.img,4)));

%% Detrend
% call detrend function. 2= detrend linear and quadratic. SPM must be
% installed. data must be 2D. function flips data and detrend col wise
% here: time is detrended

data = data';

% detrend in serveral steps. 1. linear 2. quadratic 3. cubic
disp('detrending data')
for j=1:k
    data=spm_detrend(data,j);
end

%retranspose matrix
data = data';

disp('detrending: done')
disp('saving nifti')

% reshape data back to 4D, take dimensions from nifti header
nii.img = reshape(data,nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4),size(nii.img,4));

%% Save 
fname = ([fname '_detrended']);
save_nii (nii, [fname, '.nii']); 

disp('save: done')

end