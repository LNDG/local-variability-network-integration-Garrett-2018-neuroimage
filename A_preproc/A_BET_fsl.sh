#!/bin/bash

#### This script performs FSL BET on the raw anatomical niftis. Further information at https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide
##################################################################################################################################

# TODO: Before running scripts, please change the preproc_bash_config file and the preproc_mat_config file with the correct directories.

# Get ProjectPath & SubjectList 
# TODO: Run script from the */NKI_enhanced_rest/A_preproc/scripts to properly access the preproc_bash_config file
source preproc_bash_config.sh

for SID in $SubjectList; do   

	PreprocAnatDir="${ProjectPath}/A_preproc/data/${SID}/anat" #name of preproc directory with output brain extracted anatomical images
	
	RawAnatDir="${ProjectPath}/A_preproc/RAW/${SID}/anat/" # Raw data directory with anatomical image
	
	mkdir -p ${PreprocAnatDir} #make preproc anat. directory

	# Perform BET with indicated parameter(s)
	bet ${RawAnatDir}mprage.nii.gz ${PreprocAnatDir}/mprage_brain.nii.gz -f 0.25
	# parameters -f and -g can be adjusted, see: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide

done
 
 
