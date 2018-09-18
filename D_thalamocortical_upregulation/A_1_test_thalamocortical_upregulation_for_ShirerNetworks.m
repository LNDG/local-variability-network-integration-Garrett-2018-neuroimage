%function A_1_test_thalamocortical_upregulation_for_ShirerNetworks
% This script tests thalamocortical upregulation from Horn's thalamic
% subdivisions to the cortical parts of each Shirer' network (14)
% Input: preprocessed niftis, Horn's thalamic subdivisions, Shirer's 14
% networks, Harvard-Oxford cortical atlas, voxel' sqrtPower values (stored
% in subject's sessiondata.mat)
% Ouput: Within subject: significant upregulation across networks per subj
% Across subjects: 1. significant upregulation for each network
% 2. Correlation of PCAdim and cortical PCAdim for each network
% 3. Correlation of PCAdim and corticothalamic power difference for each network
%
%%  Important: this script makes use of the Statistics Toolbox for running the ttests!

%% Set paths

[ProjectPath, SubjectList] = thalamocortical_upregulation_mat_config;

PLSPATH = [ProjectPath,'B_PLS/SD_NKIrest/'];
SAVEPATH = [ProjectPath, 'D_thalamocortical_upregulation/results/'];
PCAPATH = [ProjectPath, 'C_Dimensionality/'];
MASKPATH = [ProjectPath, 'G_standards_masks/'];

mkdir(SAVEPATH);

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));
addpath(genpath([ProjectPath, 'E_toolboxes/NIfTI_20140122']));

%% Load common coords

load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);

%% Load Harvard Oxford cortical atlas

fname=[MASKPATH, 'Harvard-Oxford_atlases/HarvardOxford-cort-maxprob-thr25-2mm.nii'];
cortex=S_load_nii_2d(fname);

cortex_coords=find(cortex); %cortex_coords ins MNI space

%% load Horn's 2016 thalamic subdivisions

regions={'primarymotor', 'sensory', 'occipital', 'prefrontal', 'premotor',  'postparietal', 'temporal'};    % set region names

for j=1:length(regions)
    
    nii=S_load_nii_2d([MASKPATH, 'Horn_2016_Thalamic_Connectivity_Atlas/', regions{j}, '_thr_MNI_2mm.nii.gz']);
    Horn=nii(final_coords);
    Horn_coords{j}=find(Horn);

end


%% Specify mapping of Horn regions to Shirer networks
% mapping specified manually beforehands, see manuscript, methods

network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};

for k=1:length(network_names)
    network{1, k}=network_names{k}; 
end

network{2, 1}=[4, 5, 7]; % ant_salience = PFC, premotor, temporal
network{2, 2}=[4, 7]; % auditory = PFC, temporal
network{2, 3}=[4]; % basal_ganglia = PFC
network{2, 4}=[4, 6, 7]; % dorsal_DMN = PFC, parietal, temporal
network{2, 5}=[3]; % high_visual = occipital
network{2, 6}=[4, 6]; % language = parietal, PFC
network{2, 7}=[4, 6, 7]; % LECN = PFC, parietal, temporal
network{2, 8}=[2, 4, 6, 7]; % post_salience = sensory, PFC, parietal, temporal
network{2, 9}=[3, 6]; % precuneus = occipital, parietal
network{2, 10}=[3]; % prim_visual = occipital
network{2, 11}=[4, 6]; % RECN = PFC, parietal 
network{2, 12}=[1, 2, 5]; % sensorimotor=primary motor, sensory, premotor
network{2, 13}=[3, 4, 6, 7]; % ventral_DMN = occipital, PFC, parietal, temporal
network{2, 14}=[2, 3, 4, 6, 7]; % visuospatial=sensory, occipital, PFC, parietal, temporal

relevant_networks=[1:2, 4:14]; %only 13 networks are relevant (for t-tests)

%% Mapping of Horn regions to Shirer networks for a given subject and calculating power differences

for i=1:length(SubjectList)

    load([PLSPATH, 'SD_', SubjectList{i}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat'],'st_datamat'); % load whole-brain datamat with sqrtPower and SD values
    power_all(i, :)=st_datamat(2, :); % 2 = load sqrtPower values for all voxels


    for k=1:length(network_names) %for each network separately

        % load PCAdim of cortical parts of all Shirer networks
        load([PCAPATH, 'PCAdimSPAT_14networks_cortical/NKI_', SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_corticalROIs_>90variance.mat'], 'Dimensions');
        PCAdim(i, k)=Dimensions; % matrix with PCAdim for all subjects and networks

        % coords of all Horn subdivisions which map to this network
        coords=vertcat(Horn_coords{network{2, k}}); 
        number_thalamic_vox(k)=length(coords); %get number of voxels within mapping (aggregated) Horn's subdivisions

        % median power value of aggregated thalamic subdivisions (assigned to each network)
        HornPower(i, k)=median(power_all(i, coords)); 

        % load sessiondatamat: power of Shirer networks
        load([PLSPATH, '14networks_PLS/SD_', SubjectList{i}, '_', network_names{k}, '_NKIrest_SPMdetrend_BfMRIsessiondata.mat'],'st_datamat', 'st_coords');

        % constraining networks to cortical regions only (cortex_coords)
        network_coords_orig(k)=length(st_coords);
        cortical_coords=intersect(st_coords, cortex_coords); %only cortical network coords
        power_coords=find(ismember(cortical_coords, st_coords)); % index of where cortical coords are located in st_coords space
        network_voxels(k)=length(find(power_coords)); %number of voxels left (cortical coords, common space)

        % calculate median power within cortical parts of Shirer networks
        corticalPower(i, k)=median(st_datamat(2, power_coords)); % 2 = total power

        % calculate power difference between cortical network parts and power of its assigned thalamic subdivisions
        DIFF_cortex_thalamus(i, k)=(corticalPower(i, k)-HornPower(i,k));

        clear st_coords power_coords cortical_coords coords

    end

    %% Paired t-tests showing upregulation between thalamus-cortex across networks

    [h(i), p(i)]=ttest(corticalPower(i, relevant_networks), HornPower(i, relevant_networks));
    median_power_cortex(i)=median(corticalPower(i, :)');
    median_power_thalamus(i)=median(HornPower(i, :)');

end

number_significant_upregulations=length(find(h)); % how many subjects showed significant differences across networks?

%% Paired t-tests showing upregulation between thalamus-cortex across subjects

for k=1:length(relevant_networks)
    [h_networks(k), p_networks(k)]=ttest(corticalPower(:, relevant_networks(k)), HornPower(:, relevant_networks(k)));
end


%% Correlation between PCAdim and corticalPCAdim

% load subjects data for PCAdim and cortical PCAdim
for i=1:length(SubjectList)
    
    for k=1:length(network_names)
        
        load([PCAPATH, 'PCAdimSPAT_14networks_cortical/NKI_', SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_corticalROIs_>90variance.mat'], 'Dimensions');
        PCAdim(i, k)=Dimensions;
        
        load([PCAPATH, 'PCAdimSPAT_14networks/NKI_', SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_>90variance.mat'], 'Dimensions');
        corticalPCAdim(i, k)=Dimensions;       
    end
    
end

% % correlate PCAdim and cortical PCAdim for each Shirer network across subjects
% for k=1:length(network_names)
%     Kor_PCAdim_corticalPCAdim(k)=corr(PCAdim(:, k), corticalPCAdim(:, k));   
% end
% 
% %% Correlation between PCAdim and corticothalamic power difference for each network
% 
% for k=1:length(network_names)
%     Kor_DIFF_cortex_thalamus_PCAdim(k)=corr(PCAdim(:, k), DIFF_cortex_thalamus(:, k));
% end

%% save output matrices
% for 14 cortical networks and 7 thalamus divisions

save([SAVEPATH, 'thalamocortical_upregulation_for_ShirerNetworks.mat'], 'SubjectList', 'network', 'cortex_coords', 'PCAdim',  'Horn_coords', 'HornPower', 'corticalPower', 'DIFF_cortex_thalamus');

%end