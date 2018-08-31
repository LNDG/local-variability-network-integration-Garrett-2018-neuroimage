%this helper script loads all single Dimensions datamats and stores them in
%one mat file: this can be then copied to the PLS analysis.txt file

[ProjectPath,SubjectList]=preproc_mat_config;

BASEPATH = (ProjectPath);   % root directory
SAVEPATH =([BASEPATH, 'C_Dimensionality/PCAdimSPAT_results/']); %save directory
mkdir(SAVEPATH)

%% wholebrain %%
%%%%%%%%%%%%%%%%

DATAPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_wholebrain/']);  % path where Dimensions are stored

for i=1:length(SubjectList)
    load([DATAPATH, 'NKI_',SubjectList{i}, '_spatialPCAcorr_90variance.mat'], 'Dimensions');
    Dimensions_wholebrain(i) = Dimensions;
    clear Dimensions
end

Dimensions_wholebrain = Dimensions_wholebrain'; %transpose: get in the right shape for PLS
save([SAVEPATH, 'NKI_N100_spatialPCAcorr_>90variance_wholebrain.mat'], 'Dimensions_wholebrain', 'SubjectList');

%% Craddock %%
%%%%%%%%%%%%%%

DATAPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_wholebrain_craddock/']);  % path where Dimensions are stored

for i=1:length(SubjectList)
    load([DATAPATH, 'NKI_',SubjectList{i}, '_spatialPCAcorr_90variance_craddock500.mat'], 'Dimensions');
    Dimensions500(i)=Dimensions; 
    clear Dimensions
    load([DATAPATH, 'NKI_',SubjectList{i}, '_spatialPCAcorr_90variance_craddock950.mat'], 'Dimensions');
    Dimensions950(i)=Dimensions; 
    clear Dimensions
    
end

Dimensions500=Dimensions500';
Dimensions950=Dimensions950';

save([SAVEPATH, 'NKI_N100_spatialPCAcorr_>90variance_Craddock500.mat'], 'Dimensions500', 'SubjectList');
save([SAVEPATH, 'NKI_N100_spatialPCAcorr_>90variance_Craddock950.mat'], 'Dimensions950', 'SubjectList');

%% 14 networks %%
%%%%%%%%%%%%%%%%%

DATAPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_14networks/']);  % path where Dimensions are stored

for i=1:length(SubjectList)
        network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};
    for k=1:length(network_names)
        load([DATAPATH, 'NKI_',SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_>90variance.mat'], 'Dimensions');
        Dimensions_14networks(i, k) = Dimensions;
        clear Dimensions
    end
end

for k=1:length(network_names)
    Dimensions = Dimensions_14networks(:, k)';
    save([SAVEPATH, 'NKI_N100_spatialPCAcorr_>90variance_', network_names{k}, '.mat'], 'Dimensions', 'SubjectList');
end

%% 14 networks cortical %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

DATAPATH = ([BASEPATH,'C_Dimensionality/PCAdimSPAT_14networks_cortical/']);  % path where Dimensions are stored

for i=1:length(SubjectList)
        network_names={'anterior_Salience', 'Auditory', 'Basal_Ganglia', 'dDMN', 'high_Visual', 'Language', 'LECN', 'post_Salience', 'Precuneus', 'prim_Visual', 'RECN', 'Sensorimotor', 'vDMN', 'Visuospatial'};
    for k=1:length(network_names)
        load([DATAPATH, 'NKI_', SubjectList{i}, '_spatialPCAcorr_', network_names{k}, '_corticalROIs_>90variance.mat'], 'Dimensions');
        Dimensions_14networks(i, k) = Dimensions;
        clear Dimensions
    end
end

for k=1:length(network_names)
    Dimensions = Dimensions_14networks(:, k)';
    save([SAVEPATH, 'NKI_N100_spatialPCAcorr_>90variance_', network_names{k}, '_corticalROIs.mat'], 'Dimensions', 'SubjectList');
end