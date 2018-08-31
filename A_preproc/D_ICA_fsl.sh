#!/bin/bash

## This script performs ICA on the functional niftis with the help of FSL MELODIC
## goal: use the ICA to detect artefacts and remove these components later from the data
############################################################################################

# Get ProjectPath & SubjectList
# TODO: Run script from the */NKI_enhanced_rest/A_preproc/scripts folder to preoperly access the preproc_bash_config file
source preproc_bash_config.sh

for SID in $SubjectList; do

	RestDir="${ProjectPath}/A_preproc/data/${SID}/rest/" # directory where input niftis are located
	ICADir="${RestDir}/${SID}_rest_feat_BPfilt.ica" # output directory with ICA results
														
	# run fsl melodic
	melodic -i ${RestDir}/${SID}_rest_feat_BPfilt -o ${ICADir} --dimest=mdl -v --nobet --bgthreshold=3 --tr=0.6449999809 --report --guireport=${ICADir}/report.html -d 0 --mmthresh=0.5 --Ostats

done