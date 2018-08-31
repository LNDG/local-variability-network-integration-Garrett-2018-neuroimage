#!/bin/bash

## This script uses the FSL regfilt function to denoise the input niftis (regress out the artefactual ICA component time series)
## Input: rejcomps.txt containing artefactual components
## Output: denoised nifti


# TODO: Run script from the */NKI_enhanced_rest/A_preproc/scripts to properly access the preproc_bash_config file
source preproc_bash_config.sh

for SID in ${SubjectList} ;do

RestDir="${ProjectPath}/A_preproc/data/${SID}/rest" #directory containing input niftis
rejcomps=$(cat ${ProjectPath}/A_preproc/scripts/E_0_rejcomps/${SID}_rejcomps.txt) #textfiles containing artefactual components

echo "denoising rejected components ${rejcomps} for ${SID}"

fsl_regfilt -i ${RestDir}/${SID}_rest_feat_BPfilt -o ${RestDir}/${SID}_rest_feat_BPfilt_denoised -d ${RestDir}/${SID}_rest_feat_BPfilt.ica/melodic_mix -f "${rejcomps}" 

if [ -f ${RestDir}/${SID}_rest_feat_BPfilt_denoised.nii.gz ] ; then #check if denoising was accomplished

echo "done" 

fi

done