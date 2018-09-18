% This script extracts power in hub regions of each Shirer network
%Input: Shirer's functional ROIs that span pre-defined hub regions
%Ouput: median power per hub region

%% Set paths

[ProjectPath, SubjectList] = thalamocortical_upregulation_mat_config;

PLSPATH = [ProjectPath,'B_PLS/SD_NKIrest/'];
SAVEPATH = [ProjectPath, 'D_thalamocortical_upregulation/results/'];
MASKPATH = [ProjectPath, 'G_standards_masks/Shirer_14networks/'];


%% Add toolboxes:adjust locations!

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));
addpath(genpath([ProjectPath, 'E_toolboxes/NIfTI_20140122']));

%% Load common coordinates

load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

%% Load hubs from Shirer networks
% load hubs, count number of voxels and save coordinates
% hubs = PCC, IPS, MFG, SMA
% find functional ROIs within Shirer's networks that span these hub regions!
% PCC: dDMN(map 4), IPS: visuospatial (2&6), MFG: visuospatial (3&7) + ECN (1), SMA: sensorimotor (3) 

% PCC: map 4
PCC=S_load_nii_2d([MASKPATH, 'Functional_ROIs/dorsal_DMN/04/4.nii']);
PCC=PCC(final_coords);

num_vox_PCC_hub=length(find(PCC));
coords_PCC=find(PCC);

%visuospatial IPS: maps 2 & 6
IPS=S_load_nii_2d([MASKPATH, 'Functional_ROIs/Visuospatial/02/2.nii']);
IPS=IPS(final_coords);

IPS2=S_load_nii_2d([MASKPATH, 'Functional_ROIs/Visuospatial/06/6.nii']);
IPS2=IPS2(final_coords);

coords_hub2=find(IPS2);
IPS(coords_hub2)=IPS2(coords_hub2);

num_vox_IPS=length(find(IPS));
coords_IPS=find(IPS);

%visuospatial MFG: maps 3 & 7
MFG=S_load_nii_2d([MASKPATH, 'Functional_ROIs/Visuospatial/03/3.nii']);
MFG=MFG(final_coords);

MFG2=S_load_nii_2d([MASKPATH, 'Functional_ROIs/Visuospatial/07/7.nii']);
MFG2=MFG2(final_coords);

coords_hub2=find(MFG2);
MFG(coords_hub2)=MFG2(coords_hub2);

num_vox_MFG=length(find(MFG));
coords_MFG=find(MFG);

% RECN MFG: map 1
RECN_MFG=S_load_nii_2d([MASKPATH, 'Functional_ROIs/RECN/01/1.nii']);
RECN_MFG=RECN_MFG(final_coords);

num_vox_RECN_hub=length(find(RECN_MFG));
coords_RECN_MFG=find(RECN_MFG);

% LECN MFG: map 1
LECN_MFG=S_load_nii_2d([MASKPATH, 'Functional_ROIs/LECN/01/1.nii']);
LECN_MFG=LECN_MFG(final_coords);

num_vox_LECN_hub=length(find(LECN_MFG));
coords_LECN_MFG=find(LECN_MFG);

RECN_MFG(coords_LECN_MFG)=LECN_MFG(coords_LECN_MFG); % get both RECN and LECN together
num_vox_ECN_hub=length(find(RECN_MFG));
coords_ECN_MFG=find(RECN_MFG);

%sensorimotor:map 3
SMA=S_load_nii_2d([MASKPATH, 'Functional_ROIs/Sensorimotor/03/3.nii']);
SMA=SMA(final_coords);

num_vox_SMA=length(find(SMA));
coords_SMA=find(SMA);


%% Extract power only within these hub regions

for i=1:length(SubjectList)
    
    load([PLSPATH, 'SD_', SubjectList{i}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat'],'st_datamat');
    
    power(i, :)=st_datamat(2, :); % 2 = total power
    power_PCC(i, :)=power(i, coords_PCC);
    power_IPS(i, :)=power(i, coords_IPS);
    power_MFG_visuospatial(i, :)=power(i, coords_MFG);
    power_MFG_RECN(i, :)=power(i, coords_RECN_MFG);
    power_MFG_LECN(i, :)=power(i, coords_LECN_MFG);
    power_MFG_ECN(i, :)=power(i, coords_ECN_MFG);
    power_SMA(i, :)=power(i, coords_SMA);
    
end

%% Calculate median power within hub regions

hubPower_PCC=median(power_PCC')';
hubPower_IPS=median(power_IPS')';
hubPower_MFG_visuosp=median(power_MFG_visuospatial')';
hubPower_MFG_RECN=median(power_MFG_RECN')';
hubPower_MFG_LECN=median(power_MFG_LECN')';
hubPower_MFG_ECNbilateral=median(power_MFG_ECN')';
hubPower_SMA=median(power_SMA')';

%% Save results

save([SAVEPATH, 'hub_regions_power.mat'], 'SubjectList', 'hubPower_PCC', 'hubPower_IPS', 'hubPower_MFG_visuosp', 'hubPower_MFG_RECN', 'hubPower_MFG_LECN', 'hubPower_MFG_ECNbilateral', 'hubPower_SMA');
