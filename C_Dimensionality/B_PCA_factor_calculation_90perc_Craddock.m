% This function finds PCA dimensionality necessary to capture up to 90% of the total variance of whole-brain subjects' spatiotemporal data.
% Instead of voxel time series, median time series are calculated within
% Craddock's parcels (500 and 950 parcels respectively)
% i.e. median time series of parcels (not voxels) are used!
% Input: preprocessed nifti, common subject coordinates, craddock mask
% Outuput: Dimensions (number of PCA components), EXPLAINED (variance explained per PCA component)
% Requires usage of NIfTI toolbox. Available at: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image


%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_wholebrain_craddock/']);  % output path
MASK = ([BASEPATH,'G_standards_masks/craddock_2011_parcellations/tcorr05_2level_all_MNI2mm_NN.nii.gz']); %craddock parcellations

mkdir(SAVEPATH);


%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))

%% Load st coords

load([BASEPATH, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

%% load Craddock parcellation (500 and 950 parcels) and constrain to st_coords 
craddock=S_load_nii_2d(MASK); %load parcellation
parcels500_st_coords=craddock(final_coords, 34); %mask parcellation with st_coords, 500 parcellation = volume 34
numParcels500=nonzeros(unique(parcels500_st_coords)); % existing parcel numbers, without 0
parcels950_st_coords=craddock(final_coords, 43); %mask parcellation with st_coords, 950 parcellation = volume 43
numParcels950=nonzeros(unique(parcels950_st_coords)); % existing parcel numbers

%% Loop over subjects
for i=1:numel(SubjectList)
    
    NIFTIPATH = ([BASEPATH, 'A_preproc/data/', SubjectList{i}, '/rest/']);  % directory of preprocessed images
    
    %% Load subject's nifti
    try
        fname=([NIFTIPATH,SubjectList{i},'_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);
        img = S_load_nii_2d(fname);     
        % error log
    catch ME
        disp([ME.message, SubjectList{i}])
    end
    
    img = img(final_coords,:);    % constrains the img file to only use final_coords, which are commonly activated voxels across subjects
    
    %% 1. for parcels = 500 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for x=1:length(numParcels500) %for all parcels
        MEDIAN(x, :)=median(img(parcels500_st_coords==numParcels500(x), :)); %get median of all voxels per parcel
    end
      
    data = MEDIAN';                % transposing of img allows proper formatting for PCA calculations (spatial PCA, correlation over time)
    
    %% PCA
    
    try
        [~, ~, ~, ~, EXPLAINED] = pca(data, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix (Only EXPLAINED output needed)
        % error log
    catch ME
        disp([ME.message, SubjectList{i}])
        
    end
    
    %% Extracting components explaining up to 90% of the variance
    
    % Initialize total variance and dimensions count
    TotalVar=0;
    Dimensions=0;
    
    for j=1:numel(EXPLAINED)
        TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90                      % set 90% criterion
            Dimensions=j;                 % Choose dimension that reaches 90%.
            break
        end
    end
    
    %% Save indivSubjectList{i}ual .mats containing PCA information
    
    SAVEFILE=(['NKI_',SubjectList{i}, '_spatialPCAcorr_90variance_craddock500.mat']);
    save([SAVEPATH, SAVEFILE],'EXPLAINED', 'Dimensions');
    disp (['saved to: ', SAVEPATH, SAVEFILE]);
    
    clear MEDIAN data Dimensions EXPLAINED TotalVar
    
    %% 2. for parcels = 950 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for x=1:length(numParcels950) %for all parcels
        MEDIAN(x, :)=median(img(parcels950_st_coords==numParcels950(x), :)); %get median of all voxels per parcel
    end
      
    data = MEDIAN';                % transposing of img allows proper formatting for PCA calculations (spatial PCA, correlation over time)
    
    %% PCA
    try
        [~, ~, ~, ~, EXPLAINED] = pca(data, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix (Only EXPLAINED output needed)
        % error log
    catch ME
        disp([ME.message, SubjectList{i}])
        
    end
    
    %% Extracting components explaining up to 90% of the variance
    
    % Initialize total variance and dimensions count
    TotalVar=0;
    Dimensions=0;
    
    for j=1:numel(EXPLAINED)
        TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar>90                      % set 90% criterion
            Dimensions=j;                 % Choose dimension that reaches 90%.
            break
        end
    end
    
    %% Save indivSubjectList{i}ual .mats containing PCA information
    
    SAVEFILE=(['NKI_',SubjectList{i}, '_spatialPCAcorr_90variance_craddock950.mat']);
    save([SAVEPATH, SAVEFILE],'EXPLAINED', 'Dimensions');
    disp (['saved to: ', SAVEPATH, SAVEFILE]);
    
    clear  MEDIAN data Dimensions EXPLAINED TotalVar SAVEFILE img j fname NIFTIPATH;
    
end

