#!/bin/bash

## This script registers the preprocessed nifti to standard space (e.g. MNI space)
## Input: preprocessed nifti, anatomical brain-extracted nifti, MNI standard template
## Output: prepocessed nifti in standard space

#The command line calls made in a two-stage registration of imageA to imageB to imageC are as follows:
#flirt [desired options] -in imageA -ref imageB -omat transf_A_to_B.mat
#flirt [desired options] -in imageB -ref imageC -omat transf_B_to_C.mat
#convert_xfm -omat transf_A_to_C.mat -concat transf_B_to_C.mat transf_A_to_B.mat
#flirt -in imageA -ref imageC -out imageoutput -applyxfm -init transf_A_to_C.mat

#The above steps perform two registrations (the first two steps) saving the respective transformations as .mat files, then concatenate the transformations using convert_xfm, then apply the concatenated transformation to resample the original image using flirt. Note that the first two calls to flirt would normally require the cost function or degrees of freedom (dof) to be set in the desired options. In the final call to flirt the option -interp is useful for specifying the interpolation method to be used (the default is trilinear).

# Get ProjectPath & SubjectList
# TODO: Run script from the */NKI_enhanced_rest/A_preproc/scriptsfolder to preoperly access the preproc_bash_config file
source preproc_bash_config.sh

for SID in $SubjectList; do
	
	RestDir="${ProjectPath}/A_preproc/data/${SID}/rest" #directory with input image
	AnatImage="${ProjectPath}/A_preproc/data/${SID}/anat/mprage_brain.nii.gz" #anatomical image, brain extracted (conduct BET beforehands!!)
	InputImage="${RestDir}/${SID}_rest_feat_BPfilt_denoised.nii.gz" #input image
	OutputImage="${RestDir}/${SID}_rest_feat_BPfilt_denoised_MNI2mm_flirt.nii.gz" #output image	
	MNI_2mm="${ProjectPath}/G_standards_masks/standard/MNI152_T1_2mm_brain.nii.gz" #standard image
	
	RegMatricesDir="${RestDir}/reg" # directory where registration matrices will be stored
	mkdir ${RegMatricesDir}

	echo "Running registration procedure for ${SID}"

	echo "creating transf_lowres_to_highres.mat" #functional input nifti to anatomical
	flirt -in ${InputImage} -ref ${AnatImage} -omat ${RegMatricesDir}/transf_lowres_to_highres.mat 
	
	echo "creating transf_highres_to_refMNI.mat" #anatomical to standard space
	flirt -in ${AnatImage} -ref ${MNI_2mm} -omat ${RegMatricesDir}/transf_highres_to_refMNI.mat 

	echo "creating transf_lowres_to_refMNI.mat" #functional input image to standard space concatenating the two steps above
	convert_xfm -omat ${RegMatricesDir}/transf_lowres_to_refMNI.mat -concat ${RegMatricesDir}/transf_highres_to_refMNI.mat ${RegMatricesDir}/transf_lowres_to_highres.mat

	echo "performing registration"
	flirt -in ${InputImage} -ref ${MNI_2mm} -out ${OutputImage} -applyxfm -init ${RegMatricesDir}/transf_lowres_to_refMNI.mat

done

