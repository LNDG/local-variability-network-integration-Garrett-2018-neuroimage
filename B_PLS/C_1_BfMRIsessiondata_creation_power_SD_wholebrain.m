function C_1_BfMRIsessiondata_creation_power_SD_wholebrain
% This script performs the 2nd pre-step for PLS: Fill matrix with
% power and SD values for various condtions, runs and blocks.
% Input: mean_BfMRIsessiondata.mat
% Output: SD_BfMRIsessiondata.mat
% The SD_BfMRIsessiondata.mat are input for the PLS analysis and store the
% voxel's power values, whole brain coverage, and the common
% coordinate space between all subjects


%% Set directories

[ProjectPath, SubjectList] = PLS_mat_config();

MATPATH = [ProjectPath, 'B_PLS/SD_NKIrest/MeanBOLD_files/']; % specify directory containing MeanBOLD PLS files

SAVEPATH = [ProjectPath, 'B_PLS/SD_NKIrest/'];   % specify where SD_BOLD PLS files will be saved

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));

%% Load common coordinates (Output of S_GMcommonCoords.m)
 
load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate SD values %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Specify conditions

conditions = {'SD'};    % set all relevant condition names

for i = 1:length(SubjectList)

%% Specify subject's nifti path

NIIPATH_ROOT = [ ProjectPath, 'A_preproc/data/', SubjectList{i}, '/rest/'];       % specify directory containing preprocessed images

NIIPATH = ([NIIPATH_ROOT, SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);

%% Load a subject's session data mat file (output from previous step).

session_mat = load([MATPATH,'mean_',SubjectList{i},'_NKIrest_BfMRIsessiondata.mat']);

% replace fields with correct info: prefix and replacing st_coords with
% final_coords= gray matter masked common set of coords between all
% subjects
session_mat = rmfield(session_mat,'st_datamat');
session_mat = rmfield(session_mat,'st_coords');
session_mat.session_info.datamat_prefix=['SD_',SubjectList{i},'_NKIrest_'];
session_mat.st_coords = final_coords';  

%% create this subject's datamat

session_mat.st_datamat = zeros(numel(conditions),numel(final_coords));


%% ---------------- SD_BOLD Calculation -----------------------------------
% Within each bloack (scan) as deviation from block's 
% temporal mean. 


%% Load file

% load nifti file for this run

[ nii ] = load_nii( NIIPATH );
img = double(reshape(nii.img,[],size(nii.img,4)));     % voxel x time

img = img(final_coords,:);  % this command constrains the img file to only use final_coords, which is common across subjects.

clear nii;


%% Get standard deviation from image = SD
session_mat.st_datamat = squeeze(std(img,0,2))';
disp(['SD calculation: done'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate TotalPower values %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Remove mean from each voxel
for j=1:numel(final_coords)%remove mean from signal to avoid peak at freq=0. For info, see https://sccn.ucsd.edu/svn/software/eeglab/functions/octavefunc/signal/pwelch.m.
    img(j,:)=img(j,:)-mean(img(j,:));
end


%% Welch - Method
% returns PSD using Welch's overlapped segment averaging estimator.
% [pxx,f] = pwelch(x,window,noverlap,f,fs)
% x = data; window = segemntlength; noverlap = nonoverlaping window, default
% 50%;  f = Units per cycle; fs = sample frequency

%% Parameters for pwelch
Fs=1/0.6449999809;%NKI TR=.645 sec.
FreqRes=Fs/885;%is 885 total points after removing the first 15 volumes (~10 sec worth of data).
n_bins_low=ceil(.01/FreqRes);%Because Fourier transform gives a single frequency bin per time point in the data (=885 bins here), we need to calculate which bin
%number holds a frequency close to the lower bound we want (here, ~.01 Hz).
low_freq=n_bins_low*FreqRes;%now calculate the actual numerical value of that bin.
n_bins_high=ceil(.10/FreqRes);%and do same for high frequency bound we want (here, ~.10 Hz).
high_freq=n_bins_high*FreqRes;%and get that bin's numerical value.
window_size=ceil(Fs*1/low_freq);%this calculates smallest window size that gives us the slowest frequency we need. 

%% Loop through voxels

sumPxx = zeros (size(img,1),1);

for k=1:size(img,1)    
    % pWelch
    [pxx, fx] = pwelch(img(k,:),hann(window_size),[],low_freq:FreqRes:high_freq,Fs);

    % sum of power/variance for 3rd condition
    sumPxx(k) = sum(pxx);   

    %% clean up
    clear pxx fx 
end
disp(['power calculation: done'])

% save all values in the appropriate datamat
clear img 

%% add 2nd condition = square root of power: values comparable to SD
session_mat.st_datamat(2,:) = sqrt(sumPxx');
session_mat.session_info.condition{1,1} = 'resting_state_SD';
session_mat.session_info.condition{2,1} = 'resting_state_sqrtPower';

%alter field descriptions 
session_mat.session_info.condition0 = session_mat.session_info.condition;
session_mat.session_info.num_conditions = 2;
session_mat.session_info.num_conditions0 = 2;
session_mat.num_subj_cond = [1,1];
session_mat.st_evt_list = [1,2];
session_mat.session_info.condition_baseline{2} = session_mat.session_info.condition_baseline{1};
session_mat.session_info.condition_baseline0{2} = session_mat.session_info.condition_baseline0{1};
session_mat.session_info.run.blk_onsets{2} = session_mat.session_info.run.blk_onsets{1};
session_mat.session_info.run.blk_length{2} = session_mat.session_info.run.blk_length{1};

%% save the two conditions in the BfMRIsessiondata.mat
save([SAVEPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat'],'-struct','session_mat','-mat');
clear session_mat

end

end