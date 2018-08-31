% This script creates masks for each network and applies it to subjects' SD_BOLD matrices
% Input: SD_BfMRIsessiondata.mat, Shirer's 14 network masks
% Output: SD_BfMRIsessiondata.mat containing power values for each of the
% 14 networks, for each subject 


%% Specify paths

[ProjectPath, SubjectList] = PLS_mat_config();

MATPATH = ([ProjectPath, 'B_PLS/SD_NKIrest/']);    % directory containing PLS SD mat files
SAVEPATH = ([ProjectPath,'B_PLS/SD_NKIrest/14networks_PLS/']);    % save path
MASKPATH= ([ProjectPath,'G_standards_masks/Shirer_14networks/']);    % directory containing network mask images

mkdir(SAVEPATH);

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));

%% Network names

network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};

%% Load network coordinates
% load network masks and match to common coordinate space

load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

for k = 1:length(network_names)
    mask = S_load_nii_2d([MASKPATH, network_names{k}, '.nii']); % load mask in original space
    coords=find(mask); %network: coords in original space, needed for final_coords
    network_coords{k}=intersect(coords, final_coords); %coords in original space, but only final_coords    
    coords_st_space = mask(final_coords);  % constrain to common coordinates final_coords
    network{k}=find(coords_st_space); %network coords in constrained final_coords space 
    clear coords coords_st_space mask
end


%% Apply network masks to each subjects and save

for k=1:length(network_coords)
    
    for i=1:length(SubjectList)
        
        load ([MATPATH, 'SD_', SubjectList{i}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat']);
        
        st_datamat=st_datamat(:, network{k}); %network: coords of each network in common space (st_coord space)
        st_coords=network_coords{k}; %network_coords: coords of each network in original space
        
        save ([SAVEPATH, 'SD_', SubjectList{i}, '_', network_names{k}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat'], 'SingleSubject', 'behavdata', 'behavname', 'create_datamat_info', 'create_ver', 'normalize_volume_mean', 'num_subj_cond', 'session_info', 'singleprecision', 'st_coords', 'st_datamat', 'st_dims', 'st_evt_list', 'st_origin', 'st_voxel_size', 'st_win_size', 'unequal_subj');
    end 
    
end