function B_GMcommonCoords
%This script creates a mask of coordinates including only gray matter (GM) coordinates and
%commonly activated coordinates for all subjects in the sample called final coordinates
%        
%Note: All niftis need to have the same resolution and be in standard space
%Input: preprocessed functional niftis in standard space
%Output: mat file containing common coordinates

%% NOTE ABOUT MASK USED FOR ANALYSIS 

% A mask containing a total of N115 subjects was used in the analysis, but 
% said analysis only contained a total of N100 subjects. This is due to 
% the fact that, for this study, we were only interested in adult brains 
% and 15 of the N115 subjects were children, which were later dropped from 
% analysis. For this reason, we are including the original coordinates of 
% the N115 mask in the following location in the repository:
% 
% ./NKI_enhanced_rest/G_standards_masks/GM_mask/N115_GMcommoncoords.mat

%% Specify paths

[ProjectPath, SubjectList] = PLS_mat_config();

DATAPATH = [ProjectPath, 'A_preproc/data/']; %preprocessed niftis in standard space

SAVEPATH = [ProjectPath, 'G_standards_masks/GM_mask']; %standard gray matter mask

%% Load MNI template of GM mask

GMmask=load_nii ([ProjectPath, 'G_standards_masks/avg152_T1_gray_mask_90.nii']);

final_coords = (find(GMmask.img))';

%% Get common coordinates
% initialize common coordinates to a vector from 1 to 1 million to ensure 1st subjects coords are all included

common_coords = (1:1000000);


for i = 1:numel(SubjectList)
   try
    
    % load subject nifti
    fname = [DATAPATH , SubjectList{i}, '/rest/', SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii'];

    nii = load_nii(fname); %load preprocessed images
    
        
    % create a matrix of intersecting coordinats over all subjects
    subj_coords = find(nii.img(:,:,:,1));
    common_coords=intersect(common_coords,subj_coords);
  
    disp ([SubjectList{i}, ': added to common coords'])
  
   % Error log    
   catch ME
       warning(['error with subject ', SubjectList{i}]);
   end
   
end

%% Match common coordinates with GM coordinates

final_coords=intersect(final_coords,common_coords); % creates final coordinates
final_coords=final_coords';

%% Save final coordinates

save ([SAVEPATH, 'GMcommoncoords.mat'], 'final_coords');

end

