%% this script calculates power for 3 different frequency bands: low, middle, high
    
%% Set directories

[ProjectPath, SubjectList] = PLS_mat_config();

MATPATH = [ProjectPath, 'B_PLS/SD_NKIrest/']; % specify directory containing MeanBOLD PLS files
SAVEPATH = [ProjectPath, 'B_PLS/SD_NKIrest/power_LowMidHigh/'];   % specify where SD_BOLD PLS files will be saved
mkdir(SAVEPATH)

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));

%% Load GM-masked, common coordinates (Output of S_GMcommonCoords.m)
 
load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

for i=1:length(SubjectList) %loop over subjects
    
    %% Alter sessiondata.mat file structure
    % check if file is there and load st_datamat and session_info our of SD_xxx_sessiondata.mat

    if exist([MATPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat'], 'file') == 2;
        a=load ([MATPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat']);
        else disp ([SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat not found!'])
    end

    clear a.st_datamat
    
    a.st_evt_list=[1, 2, 3];
    a.num_subj_cond=[1, 1, 1];
    a.session_info.num_conditions=3;
    a.session_info.num_conditions0=3;
    a.session_info.condition_baseline={};
    a.session_info.condition_baseline{1, 1}=[-1, 1];
    a.session_info.condition_baseline{1, 2}=[-1, 1];
    a.session_info.condition_baseline{1, 3}=[-1, 1];
    a.session_info.condition_baseline0=a.session_info.condition_baseline;  
    a.session_info.condition={};
    a.session_info.condition{1, 1}='sqrtLowPower';
    a.session_info.condition{2, 1}='sqrtMidPower';
    a.session_info.condition{3, 1}='sqrtHighPower';
    a.session_info.condition0=a.session_info.condition;
    a.session_info.run.blk_onsets={};
    a.session_info.run.blk_onsets{1, 1}=1;
    a.session_info.run.blk_onsets{1, 2}=1;
    a.session_info.run.blk_onsets{1, 3}=1;
    a.session_info.run.blk_length={};
    a.session_info.run.blk_length{1, 1}=884;
    a.session_info.run.blk_length{1, 2}=884;
    a.session_info.run.blk_length{1, 3}=884;
    
    %% Specify subject's nifti path
    NIIPATH_ROOT = [ ProjectPath, 'A_preproc/data/', SubjectList{i}, '/rest/'];       % specify directory containing preprocessed images
    NIIPATH = ([NIIPATH_ROOT, SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);

    try
        img = S_load_nii_2d (NIIPATH);
    catch ME
        disp ([SubjectList{i},'_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended not found!']);
    end
    
    %% organize input data
    data = img(a.st_coords,:);          % apply st_coords
    
    %Remove mean from signal
    for k=1:size(data, 1)%remove mean from signal from each voxel. For info, see https://sccn.ucsd.edu/svn/software/eeglab/functions/octavefunc/signal/pwelch.m.
        data(k,:)=data(k,:)-mean(data(k,:));    
    end
    clear img
    
     %% Parameters for pwelch
    Fs=1/0.6449999809;%NKI TR=.645 sec.
    FreqRes=Fs/885;%is 885 total points after removing the first 15 volumes (~10 sec worth of data).
  %  FreqRes = FreqRes/2; %double the number of bins to get a total number which is dividable by three (three different freq bands)
    % manually picked frequency boarders
    % TAKE CARE TO USE ALL DIGITS!!!!
    low_freqLOW = 0.010511102663118;   
    high_freqLOW = 0.040292560208620;
    low_freqMID = 0.041168485430546;
    high_freqMID = 0.070949942976048;
    low_freqHIGH = 0.071825868197974; 
    high_freqHIGH = 0.101607325743476;
    
    window_size=ceil(Fs*1/low_freqLOW);%we want to use stable window sizes: based on the slowest frequency we want to detect
    
    % preallocate loop variables
    siz = size(data,1);
    pxxLOW = zeros(siz,numel(low_freqLOW:FreqRes:high_freqLOW));
    pxxMID = zeros(siz,numel(low_freqMID:FreqRes:high_freqMID));
    pxxHIGH = zeros(siz,numel(low_freqHIGH:FreqRes:high_freqHIGH));
    pxxTOTAL = zeros(siz,numel(low_freqLOW:FreqRes:high_freqHIGH));

    
    %loop through voxels
    for k=1:(siz)

        try
            %pwelch
            [pxxLOW(k,:),~] = pwelch(data(i,:),hann(window_size),[],low_freqLOW:FreqRes:high_freqLOW,Fs);
            [pxxMID(k,:),~] = pwelch(data(k,:),hann(window_size),[],low_freqMID:FreqRes:high_freqMID,Fs);
            [pxxHIGH(k,:),~] = pwelch(data(k,:),hann(window_size),[],low_freqHIGH:FreqRes:high_freqHIGH,Fs);
            [pxxTOTAL(k,:),~] = pwelch(data(k,:),hann(window_size),[],low_freqLOW:FreqRes:high_freqHIGH,Fs);
            
        catch ME1
            disp 'error at pwelch'
            disp (ME1.message)
        end
    end
    
    
    % sum and SQRT power
    % first sum, because sqrt a matrix result in imaginary values
    pxxLOW = sum(pxxLOW');
    pxxMID = sum(pxxMID');
    pxxHIGH = sum(pxxHIGH');
    % square root the total Pxx data to reflect the same metric as SD.
    SQRTpxxLOW = sqrt(pxxLOW);
    SQRTpxxMID = sqrt(pxxMID);
    SQRTpxxHIGH = sqrt(pxxHIGH);
    
     % write sqrt power values in datamats, for the frequency bands
     % separately
    a.st_datamat(1, :)=SQRTpxxLOW; 
    a.st_datamat(2, :)=SQRTpxxMID; 
    a.st_datamat(3, :)=SQRTpxxHIGH; 
    
    %% Save data 
   
    save ([SAVEPATH, 'SD_',SubjectList{i},'_NKIrest_SPMdetrend_LowMidHighPower_BfMRIsessiondata.mat'],  '-struct', 'a', '-mat');

end
    

