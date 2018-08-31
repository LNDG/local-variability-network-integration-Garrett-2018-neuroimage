function A_Sessiondatamat_file_modification
% This script creates session data mat-files for PLS from txt template (NKI_PLS_NKIrest_template_batch_file.txt)
% Input: NKI_PLS_NKIrest_template_batch_file.txt (adjusted to your data) 
% Output: NKI mean batch txt file and mean_sessiondata.mat file for each subject

%% Set directories and ID list

[ProjectPath, SubjectList] = PLS_mat_config();

TEMPLPATH = ([ProjectPath, 'B_PLS/scripts/']); %where the template is
SAVEPATH =([ProjectPath, 'B_PLS/SD_NKIrest/MeanBOLD_files/']); %output directory

mkdir(SAVEPATH);

%% Add PLS toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/Pls']));

%%
for i = 1:length(SubjectList)
    
    %% specify preprocessed image path
    
    NIIPATH = [ProjectPath ,'A_preproc/data/', SubjectList{i}, '/rest/']; %path with input preprocessed functional nnifti
    
    %% replace relevant text in session files for each subject and save it
    
    %copy template file for each subject
    copyfile([TEMPLPATH,'NKI_PLS_NKIrest_template_batch_file.txt'],[SAVEPATH,'mean_',SubjectList{i},'_NKIrest_batch_file.txt']);
    
    %define new text (prefix) and line to replace
    replaceLine1 = 5;
    newText1 = ['prefix mean_',SubjectList{i},'_NKIrest'];

    % move the file position marker to the correct line
      fid = fopen([SAVEPATH,'mean_',SubjectList{i},'_NKIrest_batch_file.txt'],'r+');
      fseek(fid,0,-1);

    for k=1:(replaceLine1-1)
        fgetl(fid);
    end

    % call fseek between read and write operations
    fseek(fid, 0, 'cof');
    fprintf(fid, '%s', newText1); %replace text by correct prefix
    fseek(fid,0,-1);    %this command resets the position in the file to origin.

    replaceLine2 = 21; %define new text and line to be replaced
    %full data path of preprocessed input nifti, block onset (1 if resting
    %state) and block length (entire time series when resting state)
    newText2 = ['data_files ',NIIPATH, SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii'];
    newText3 = 'block_onsets 1';
    newText4 = 'block_length 884';
    newText5 = '%------------------------------------------------------------------------';
    
    % move the file position marker to the correct line
    for k=1:(replaceLine2-1)
        fgetl(fid);
    end

    % call fseek between read and write operations
    fseek(fid, 0, 'cof');
    fprintf(fid, '%s\n\n%s\n\n%s\n%s', newText2, newText3, newText4, newText5)
    fseek(fid,0,-1);
    
    fclose(fid);

    %% create the session files (and mean-based datamats, although we don't need these)

    cd (SAVEPATH);

    batchname=[SAVEPATH,'mean_',SubjectList{i},'_NKIrest_batch_file.txt'];
    batch_plsgui(batchname);

end
end


