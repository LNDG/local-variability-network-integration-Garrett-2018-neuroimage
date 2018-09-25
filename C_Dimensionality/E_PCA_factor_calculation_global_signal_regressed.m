% This script checks effect of global signal regression on examining temporal
% dynamics in voxels.
% Input: subject's niftis
% Output: global signal per timepoint, residualized nifti, correlation of
% PCAdim estimation comparing with and without global signal regression


%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
MASKPATH  = ([BASEPATH,'G_standards_masks/']);  
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAcorr_GSreg/']);  % output path

mkdir (SAVEPATH)

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))

% load common coordinates: GM masked
load([MASKPATH, 'GM_mask/GMcommoncoords.mat']); % load final_coords: already gray-matter masked!


%% Load subject's nifti image and run PCA
for z=1:numel(SubjectList)
    
    NIFTIPATH = ([BASEPATH, 'A_preproc/data/', SubjectList{z}, '/rest/']);  % directory of preprocessed images
    fname=([NIFTIPATH,SubjectList{z},'_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii']);
    
    nii = double(S_load_nii_2d(fname));
    img=nii(final_coords, :);
    img=img'; %already transformed for spatial PCA: rows = timepoints, columns = voxels
    
    %% Compute and regress global mean signal
    
    global_mean = mean(img,2); %mean per time point, averaged across all voxels
    
    % residualize global mean signal from image
    img_reg = residualize(global_mean,img);
    
    % check corr histogram between mean signal and time series of each voxel
    corr_Global2Vox = corr(global_mean,img);
    % figure; hist(corr_Global2Vox); % shows how much global signal is contained in each voxel
    
    % confirm if residualization worked
    corr_Global2Resid = corr(global_mean, img_reg);
    % figure; hist(corr_Global2Resid); % should be around zero!
    
    %% Test whether correlation breaks down between pre and post reg voxels
    
    for k=1:length(img(1,:))   
        corr_vect(k) = corr(img(:,k),img_reg(:,k)); % should be very high for most of the voxels       
    end
    % figure; hist(corr_vect);
    
    %% Test whether PCA dim estimate increases systematically %% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% PCAs
    
    % perform PCA on subject's masked nifti
    [coeff_img, scores_img, ~, ~, EXPLAINED_img] = pca(img, 'VariableWeights','variance', 'Centered', true);   % spatial PCA using correlation matrix
    
    % perform PCA on subject's residualized masked nifti
    [coeff_img_reg, scores_img_reg, ~, ~, EXPLAINED_img_reg] = pca(img_reg, 'VariableWeights','variance', 'Centered', true);   % spatial PCA using correlation matrix
    
    
    %% Extracting components explaining at least 90% of the total variance
    
    % initialize total variance and dimensionality counts
    TotalVar_img=0;
    Dimensions_img=0;
    
    TotalVar_img_reg=0;
    Dimensions_img_reg=0;
    
    % extract components for the original masked image
    for j=1:numel(EXPLAINED_img)
        TotalVar_img=TotalVar_img+EXPLAINED_img(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
        if TotalVar_img>90                      % set 90% criterion here.
            Dimensions_img=j;
            break
        end
    end
    
    % extract components for the residualized masked image
    for j=1:numel(EXPLAINED_img_reg)
        TotalVar_img_reg=TotalVar_img_reg+EXPLAINED_img_reg(j,1);
        if TotalVar_img_reg>90
            Dimensions_img_reg=j;
            break
        end
    end
    
    %% Check correlation of explained variance pre and post residualization of the global mean signal
    
    corr_EV_img2resid=corr(EXPLAINED_img,EXPLAINED_img_reg);
    
    %% Save results
    
    save([ SAVEPATH 'NKI_', SubjectList{z}, '_PCAcorr_GSreg.mat'], 'corr_Global2Vox', 'corr_Global2Resid', 'corr_vect', 'Dimensions_img', 'Dimensions_img_reg', 'EXPLAINED_img', 'EXPLAINED_img_reg', 'corr_EV_img2resid', 'img_reg');
    clear corr_Global2Vox corr_Global2Resid corr_vect Dimensions_img Dimensions_img_reg EXPLAINED_img EXPLAINED_img_reg corr_EV_img2resid img_reg TotalVar_img_reg TotalVar_img j k fname NIFTIPATH coeff_img_reg coeff_img global_mean scores_img_reg scores_img img nii
    
end
