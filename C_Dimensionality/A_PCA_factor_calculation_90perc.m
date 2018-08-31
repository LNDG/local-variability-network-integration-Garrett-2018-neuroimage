% This function finds PCA dimensionality necessary to capture up to 90% of the total variance of whole-brain subjects' spatiotemporal data.
% Input: preprocessed nifti, common coordinates
% Ouput: Dimensions; Number of PCA dimensions, EXPLAINED: percentage of varianc explained per
% component 
% Requires usage of NIfTI toolbox. Available at: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image


%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_wholebrain/']);  % output path

mkdir(SAVEPATH);

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))

%% Load common coords

load([BASEPATH, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

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
    img = img'; % transposing of img allows proper formatting for PCA calculations: spatial PCA, i.e. columns need to be voxels, rows timepoints
    
    %% PCA
    
    try
        [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true));  % spatial PCA using correlation matrix (correlation over time) (Only EXPLAINED output needed)
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
            Dimensions=j;                 % Choose dimension that reaches min 90% of variance
            break
        end
    end
    
    %% Save indivSubjectList{i}ual .mats containing PCA information
    
    SAVEFILE=(['NKI_',SubjectList{i}, '_spatialPCAcorr_90variance.mat']);
    save([SAVEPATH, SAVEFILE],'EXPLAINED', 'Dimensions');
    disp (['saved to: ', SAVEPATH, SAVEFILE]);
    
    clear  Dimensions EXPLAINED TotalVar SAVEFILE img j fname NIFTIPATH;
    
end

