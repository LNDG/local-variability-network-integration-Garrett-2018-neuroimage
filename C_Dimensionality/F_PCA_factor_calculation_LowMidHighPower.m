% This script checks effect of global signal regression on examining temporal
% dynamics in voxels. Outpus PCAdim whole brain after GS regression 
% Input: subject's niftis
% Output: global signal per timepoint, residualized nifti, correlation of
% PCAdim estimation comparing with and without global signal regression


%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
PLSPATH = [ProjectPath,'B_PLS/SD_NKIrest/'];
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_LowMidHighPower/']);  % output path

mkdir (SAVEPATH)

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))


%% Filter parameters 
Fs=1/0.6449999809;%NKI TR=.645 sec.    num_sec = round(885/Fs);         % time points
filterOrder = 4;

% manually picked frequency boarders
% TAKE CARE TO USE ALL DIGITS!!!!
low_freqLOW = 0.010511102663118;   
high_freqLOW = 0.040292560208620;
low_freqMID = 0.041168485430546;
high_freqMID = 0.070949942976048;
low_freqHIGH = 0.071825868197974; 
high_freqHIGH = 0.101607325743476;


for i = 1:length(SubjectList)
    NIFTIPATH = ([BASEPATH, 'A_preproc/data/', SubjectList{i}, '/rest/']);
    fname=([NIFTIPATH,SubjectList{i},'_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);

    a = load([PLSPATH, 'SD_', SubjectList{i}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat']);

    try
        nii = load_nii (fname);
    catch ME; disp (ME)
    end

    data_raw = reshape (nii.img, [], nii.hdr.dime.dim(5));
    data_raw = data_raw(a.st_coords,:);
    clear nii


    %% Low frequency band
    %Butterworth filter:
    %1. high pass filter using the low cut off
    [B,A]  = butter(filterOrder,low_freqLOW/(Fs/2),'high'); % check order
    data   = filtfilt(B,A,data_raw); clear A B

    %2. low pass filter using the high cut off
    [B,A]  = butter(filterOrder,high_freqLOW/(Fs/2),'low'); % check order  
    data   = filtfilt(B,A,data); clear A B   
    
    %PCA
    TotalVar = 0;
    [~, ~, ~, ~, EXPLAINED] = pca(data', 'VariableWeights','variance');

    for j=1:numel(EXPLAINED)
        TotalVar=TotalVar+EXPLAINED(j,1);   %EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90                      %set 90% criterion here.
            Dimensions(1)=j;                 
        break
        end
    end

    clear data EXPLAINED

    %% Mid frequency band
    %Butterworth filter:
    %1. high pass filter useing the low cut off
    [B,A]  = butter(filterOrder,low_freqMID/(Fs/2),'high'); % check order
    data   = filtfilt(B,A,data_raw); clear A B

    %2. low pass filter useing the high cut off
    [B,A]  = butter(filterOrder,high_freqMID/(Fs/2),'low'); % check order
    data   = filtfilt(B,A,data); clear A B
    %PCA
    TotalVar = 0;
    [~, ~, ~, ~, EXPLAINED] = pca(data', 'VariableWeights','variance');


    for j=1:numel(EXPLAINED)
        TotalVar=TotalVar+EXPLAINED(j,1);%EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90 %set 90% criterion here.
            Dimensions(2)=j;
            break
        end
    end

    clear data EXPLAINED

    %% High frequency band
    %Butterworth filter:
    %1. high pass filter useing the low cut off
    [B,A]  = butter(filterOrder,low_freqHIGH/(Fs/2),'high'); % check order
    data   = filtfilt(B,A,data_raw); clear A B

    %2. low pass filter useing the high cut off
    [B,A]  = butter(filterOrder,high_freqHIGH/(Fs/2),'low'); % check order
    data   = filtfilt(B,A,data); clear A B  

    %PCA
    TotalVar = 0;
    [~, ~, ~, ~, EXPLAINED] = pca(data', 'VariableWeights','variance');


    for j=1:numel(EXPLAINED)
        TotalVar=TotalVar+EXPLAINED(j,1);%EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90 %set 90% criterion here.
            Dimensions(3)=j;
            break
        end
    end

    clear data EXPLAINED


    %Save data
    save ([SAVEPATH, SubjectList{i}, '_DimensionsLowMidHigh.mat'], 'Dimensions');


end


