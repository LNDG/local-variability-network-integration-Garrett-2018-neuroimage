%% Calculates a power values for Craddock parcelation and stores them in sessiondata.mats
% pwelch parameter: to avoid zero-padding, windowsize and cut offs are 
% calculated from exact sampling rate. Sampling rate is loaded from nifit header.  
% input: preprocessed nifti, Craddock parcellations, SD_sessiondatamat template
% output: sessiondata.mats containing sqrt Power values for each parcel and
% two different parcellation schemes (500 and 950 parcels)

% 18-08-28


%% Specify paths

[ProjectPath, SubjectList] = PLS_mat_config();

MATPATH = ([ProjectPath, 'B_PLS/SD_NKIrest/']);    % PLS directory
NIIPATH = ([ProjectPath,'A_preproc/data/']);    %directory containing rest niftis
MASKPATH = ([ProjectPath,'G_standards_masks/craddock_2011_parcellations/']);    % directory containing craddock mask images
SAVEPATH = ([MATPATH, 'Craddock_parcellation/']);

mkdir(SAVEPATH);

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));


for i=1:length(SubjectList) %loop over subjects
    
    %% Alter sessiondata.mat file structure
    % check if file is there and load st_datamat and session_info our of SD_xxx_sessiondata.mat

    if exist([MATPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat'], 'file') == 2;
        a=load ([MATPATH,'SD_',SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat']);

        else disp ([SubjectList{i},'_NKIrest_SPMdetrend_BfMRIsessiondata.mat not found!'])
    end

    clear a.st_datamat

    a.st_evt_list=[1, 2];
    a.num_subj_cond=[1, 1];
    a.session_info.num_conditions=2;
    a.session_info.num_conditions0=2;
    a.session_info.condition_baseline={};
    a.session_info.condition_baseline{1, 1}=[-1, 1];
    a.session_info.condition_baseline{1, 2}=[-1, 1];
    a.session_info.condition_baseline0=a.session_info.condition_baseline;  
    a.session_info.condition={};
    a.session_info.condition{1, 1}='sqrtTotalPower500';
    a.session_info.condition{2, 1}='sqrtTotalPower950';
    a.session_info.condition0=a.session_info.condition;
    a.session_info.run.blk_onsets={};
    a.session_info.run.blk_onsets{1, 1}=1;
    a.session_info.run.blk_onsets{1, 2}=1;
    a.session_info.run.blk_length={};
    a.session_info.run.blk_length{1, 1}=884;
    a.session_info.run.blk_length{1, 2}=884;

    % check in datafolder if nifit ends with .nii or .nii.gz, if gziped unzip
    % load and delete afterwards. 
    % add S_load_nifit2d somewhen

    try
        img = S_load_nii_2d ([NIIPATH, SubjectList{i}, '/rest/', SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);
    catch ME
        disp ([SubjectList{i},'_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended not found!']);
    end


    %% organize input data
    data = img(a.st_coords,:);                               % apply st_coords


    %% load Craddock parcellation (500 and 950 parcels) and constrain to st_coords 
    craddock=S_load_nii_2d([MASKPATH, 'tcorr05_2level_all_MNI2mm_NN.nii']);
    parcels500_st_coords=craddock(a.st_coords, 34); %mask parcellation with st_coords
    numParcels500=nonzeros(unique(parcels500_st_coords)); % existing unique parcel numbers, without 0
    parcels950_st_coords=craddock(a.st_coords, 43); %mask parcellation with st_coords
    numParcels950=nonzeros(unique(parcels950_st_coords)); % existing unique parcel numbers

    %% data = median time series per parcel 
    for x=1:length(numParcels500) %for all parcels
            data500(x, :)=median(data(parcels500_st_coords==numParcels500(x), :)); %get median of all voxels per parcel
    end
    for x=1:length(numParcels950) %for all parcels
            data950(x, :)=median(data(parcels950_st_coords==numParcels950(x), :)); %get median of all voxels per parcel
    end

    %% Remove mean from each parcel
    for k=1:numel(numParcels500)%remove mean from signal to avoid zero frequency peak? For info, see https://sccn.ucsd.edu/svn/software/eeglab/functions/octavefunc/signal/pwelch.m.
        data500(k,:)=data500(k,:)-mean(data500(k,:));    
    end
    for k=1:numel(numParcels950)%remove mean from signal to avoid zero frequency peak? For info, see https://sccn.ucsd.edu/svn/software/eeglab/functions/octavefunc/signal/pwelch.m.
        data950(k,:)=data950(k,:)-mean(data950(k,:));    
    end

    clear img;

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
    
    %% Loop through parcels: create power values (pwelch)
    
    %preallocate variables
    sumPxx500 = zeros (size(data500,1),1);
    sumPxx950 = zeros (size(data950,1),1);

    for k=1:size(data500,1)

        % pWelch
        [pxx, ~] = pwelch(data500(k,:),hann(window_size),[],low_freq:FreqRes:high_freq,Fs);

        % sum of power/variance for 3rd condition
        sumPxx500(k) = sum(pxx);

        %% clean up
        clear pxx 

    end

    for k=1:size(data950,1)

        % pWelch
        [pxx, ~] = pwelch(data950(k,:),hann(window_size),[],low_freq:FreqRes:high_freq,Fs);

        % sum of power/variance for 3rd condition
        sumPxx950(k) = sum(pxx);

        %% clean up
        clear pxx 

    end

    % square root of power: values comparable to SD
    sumPXX500=sqrt(sumPxx500);
    sumPXX950=sqrt(sumPxx950);

    % write sqrt power values in datamats, for 500 and 950 parcellations separately
    a.st_datamat=zeros(2, length(a.st_coords)); %preallocate
    for k=1:length(numParcels500) % for each parcel, write the median power values at the right coordinates
        Parcel_coords=find(parcels500_st_coords==numParcels500(k)); %get coords of each parcel
        a.st_datamat(1, Parcel_coords)=sumPXX500(k); %replace all voxel values within parcel with median value;
    end
    for k=1:length(numParcels950) % for each parcel, write the median power values at the right coordinates
        Parcel_coords=find(parcels950_st_coords==numParcels950(k)); %get coords of each parcel
        a.st_datamat(2, Parcel_coords)=sumPXX950(k); %replace all voxel values within parcel with median value;
    end

    %% Save data 
   
    save ([SAVEPATH, 'SD_',SubjectList{i},'_NKIrest_SPMdetrend_Craddock_BfMRIsessiondata.mat'],  '-struct', 'a', '-mat');


end

