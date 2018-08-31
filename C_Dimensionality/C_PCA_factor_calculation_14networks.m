% This script finds PCA dimensionality necessary to capture up to 90% of the total variance of subjects' spatiotemporal data.
% Instead of whole brain, voxel time series are calculated within
% Shirer's 14 networks
% Input: preprocessed nifti, common subject coordinates, network masks
% Output per network: Dimensions (number of PCA components), EXPLAINED (variance explained per PCA component)
% Requires usage of NIfTI toolbox. Available at: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_14networks/']);  % output path
MASKPATH= ([BASEPATH,'G_standards_masks/Shirer_14networks/']);   % path containing all masks

mkdir(SAVEPATH);

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))

%% Specify network names

network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};

%% Load common coordinates

load([BASEPATH, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

%% Load network coordinates

for k = 1:length(network_names)
    coords = S_load_nii_2d([MASKPATH, network_names{k}, '.nii']); % load mask in original space
    coords_st_space = coords(final_coords);  % contrain to common coordinates final_coords
    network{k}=logical(coords_st_space);
    clear coords coords_st_space
end


%% Load subject's nifti
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
    
    %% PCA for each network
    for k=1:length(network) % cycle over networks
        
        % apply network mask
        img_network = img(network{k},:);
        img_network = img_network'; % transposing of img allows proper formatting for PCA calculations (spatial PCA, correlation over time)
        
        %% PCA
        % coeff_RAW: component coefficient scores. Later calculated by normalization of scores*data. But variable is initiliazed here.
        try
            [~,~, ~, ~, EXPLAINED] = pca(img_network, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix.
            % error log
        catch ME
            disp([ME.message, SubjectList{i}])
        end
        
        %% Extracting components explaining > 90% variance
        
        % initialize matrices
        
        TotalVar=0;
        Dimensions=0;
        
        for j=1:numel(EXPLAINED)
            TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
            if TotalVar>90                      % set 90% criterion here.
                Dimensions=j;                   
                break
            end
        end

        
        %% Save individual .mats for each subject
        
        SAVEFILE=(['NKI_',SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_>90variance.mat']);
        save([SAVEPATH, SAVEFILE], 'EXPLAINED', 'Dimensions'); % note that EXPLAINED here is from unrotated solution. Will be very different upon rotation...
        disp (['saved to: ', SAVEPATH, SAVEFILE]);
        
        clear img_network EXPLAINED Dimensions TotalVar j
        
    end
    
    clear img NIFTIPATH fname 
end

