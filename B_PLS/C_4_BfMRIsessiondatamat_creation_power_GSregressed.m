
% 21-09-2018
% This script calculates whole-brain power for functional images after
% global signal regression
%INPUT: GSregressed functional nifti
%OUTPUT: sqrt of whole-brain power, saved as a new condition in PLS
%sessiondata.mat file

[ProjectPath,SubjectList{i}]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
PLSPATH  = ([BASEPATH,'B_PLS/SD_NKIrest/']); 

for i=1:length(SubjectList{i})
    % check if file is there and load st_datamat and session_info our of SD_xxx_sessiondata.mat
    if exist([PLSPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat'], 'file') == 2
        a=load ([PLSPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat']);
    else disp ([SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat not found!'])
    end


    %load img_reg (GSR image); 
    load([BASEPATH,'C_Dimensionality/PCAcorr_GSreg/NKI_', SubjectList{i}, '_PCAcorr_GSreg.mat'], 'img_reg');   
    data=img_reg'; %time points = columns
    % attention: data is already zero-mean due to GSregression!


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

    sumPxx = zeros (size(data,1),1);

    for k=1:size(data,1)   %number of voxels
    % pWelch
    [pxx, ~] = pwelch(data(k,:),hann(window_size),[],low_freq:FreqRes:high_freq,Fs); 
    sumPxx(k) = sum(pxx); % sum of power across time-points
    end


    %% Save data 
    % save power as new "condition' into st_data.mat of NKI data
    % Update st_datamat info accordingly

    a.session_info.pls_data_path=PLSPATH;
    a.session_info.run.file_pattern=([SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);

    %square root to have same metric as SD
    a.st_datamat(3,:) = sqrt(sumPxx');
    a.session_info.condition{3,1} = 'totalPower_GSreg';
    a.session_info.condition0 = a.session_info.condition;
    a.session_info.num_conditions = 3;
    a.session_info.num_conditions0 = 3;
    a.num_subj_cond = [1,1,1];
    a.st_evt_list = [1,2,3];
    a.session_info.condition_baseline0{3} = a.session_info.condition_baseline0{1};
    a.session_info.condition_baseline{3} = a.session_info.condition_baseline{1};
    a.session_info.run.blk_onsets{3} = a.session_info.run.blk_onsets{1};
    a.session_info.run.blk_length{3} = a.session_info.run.blk_length{1};

    save ([PLSPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat'], '-struct' ,'a', '-mat');


end

