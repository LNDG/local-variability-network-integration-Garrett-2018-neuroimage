% This script finds PCA dimensionality necessary to capture up to 90% of the total variance of subjects' spatiotemporal data.
% Instead of whole brain, voxel time series are calculated within
% Shirer's 14 networks, restricted to cortical regions only!
% Input: preprocessed nifti, common subject coordinates, network masks,
% Harvard Oxford cortical atlas
% Output per network: Dimensions (number of PCA components), EXPLAINED (variance explained per PCA component)
% Requires usage of NIfTI toolbox. Available at: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image


%% Set paths

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
SAVEPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_14networks_cortical/']);  % output path
MASKPATH= ([BASEPATH,'G_standards_masks/']);   % path containing all masks

mkdir(SAVEPATH);

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'E_toolboxes/preprocessing_tools']))
addpath(genpath([ BASEPATH 'E_toolboxes/NIfTI_20140122']))

%% Load subject coordinates

load([BASEPATH, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

%% Load Harvard Oxford cortical atlas

fname=[MASKPATH, 'Harvard-Oxford_atlases/HarvardOxford-cort-maxprob-thr25-2mm.nii'];
cortex=S_load_nii_2d(fname);
cortex=cortex(final_coords); %mask with final_coords
cortex_coords=find(cortex); %coords of cortical parts

%% Specify network names

network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};

%% Load network coordinates

for k = 1:length(network_names)
    mask = S_load_nii_2d([MASKPATH, 'Shirer_14networks/', network_names{k}, '.nii']); % load mask in original space
    coords_st_space = mask(final_coords);  % contrain to common coordinates final_coords
    network{k}=logical(coords_st_space);
    clear coords coords_st_space
end


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
    for k=1:length(network) % cycle over all 14 networks
        
        % get only cortical parts of Shirer networks!
        network_coords_cortical=intersect(cortex_coords, find(network{k}));
        img_network = img(network_coords_cortical,:);
        img_network = img_network'; % transposing of img allows proper formatting for PCA calculations (spatial PCA, correlation over time)
        
        %% PCA
        % coeff_RAW: component coefficient scores. Later calculated by normalization of scores*data. But variable is initiliazed here.
        
        try
            [coeff_RAW, scores, ~, ~, EXPLAINED] = pca(img_network, 'VariableWeights','variance', 'Centered', true);   % spatial PCA using correlation matrix     
            % error log
        catch ME
            disp([ME.message, SubjectList{i}])
        end
        
        %% Extracting components explaining > 90% variance
        % calculate factor loading for number of dimensions (so that at least 90% of total variance explained)
        
        % initialize total variance and dimensionality count
        TotalVar=0;
        Dimensions=0;
        
        for j=1:numel(EXPLAINED)
            TotalVar=TotalVar+EXPLAINED(j,1);   %EXPLAINED represents variance accounted for by a given dimension.
            if TotalVar>90                      %set 90% criterion here.
                Dimensions=j;                  
                break
            end
        end
        
        %% Save individual .mats for each subject
        
        SAVEFILE=(['NKI_', SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_corticalROIs_>90variance.mat']);
        save([SAVEPATH, SAVEFILE],'coeff_RAW','scores', 'EXPLAINED', 'Dimensions'); % note that EXPLAINED here is from unrotated solution. Will be very different upon rotation...
        disp (['saved to: ', SAVEPATH, SAVEFILE]);
        
        clear img_network scores Dimensions TotalVar network_coords_cortical EXPLAINED 
    end
    clear img NIFTIPATH fname k
end