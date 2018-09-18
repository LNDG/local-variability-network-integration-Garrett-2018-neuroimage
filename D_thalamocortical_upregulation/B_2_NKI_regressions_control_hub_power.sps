* Encoding: UTF-8.

*Before executing you need to load relevant variables from the analyses output mats into an spss table called thalamocortical_upregulation.sav in the scripts folder
*Required variables: 

*ID = SubjectList

*Respective columns of HornPower matrix saved in thalamocortical_upregulation_for_ShirerNetworks.mat:
HornPower_ant_salience
HornPower_auditory
HornPower_dDMN
HornPower_high_visual
HornPower_language
HornPower_LECN
HornPower_post_salience
HornPower_precuneus
HornPower_prim_visual
HornPower_RECN
HornPower_sensorimotor
HornPower_vDMN
HornPower_visuospatial

*Respective columns of corticalPower matrix saved in thalamocortical_upregulation_for_ShirerNetworks.mat:
corticalPower_ant_salience
corticalPower_auditory
corticalPower_dDMN
corticalPower_high_visual
corticalPower_language
corticalPower_LECN
corticalPower_post_salience
corticalPower_precuneus
corticalPower_prim_visual
corticalPower_RECN
corticalPower_sensorimotor
corticalPower_vDMN
corticalPower_visuospatial

*Respective columns of PCAdim matrix saved in thalamocortical_upregulation_for_ShirerNetworks.mat:
PCAdim_ant_salience
PCAdim_auditory
PCAdim_dDMN
PCAdim_high_visual
PCAdim_language
PCAdim_LECN
PCAdim_post_salience
PCAdim_precuneus
PCAdim_prim_visual
PCAdim_RECN
PCAdim_sensorimotor
PCAdim_vDMN
PCAdim_visuospatial

*Respective columns of DIFF_cortex_thalamus matrix saved in thalamocortical_upregulation_for_ShirerNetworks.mat:
DIFF_cortex_thalamus_ant_salience
DIFF_cortex_thalamus_auditory
DIFF_cortex_thalamus_dDMN
DIFF_cortex_thalamus_high_visual
DIFF_cortex_thalamus_language
DIFF_cortex_thalamus_LECN
DIFF_cortex_thalamus_post_salience
DIFF_cortex_thalamus_precuneus
DIFF_cortex_thalamus_prim_visual
DIFF_cortex_thalamus_RECN
DIFF_cortex_thalamus_sensorimotor
DIFF_cortex_thalamus_vDMN
DIFF_cortex_thalamus_visuospatial

*Variables saved in hub_regions_power.mat:
hubPower_PCCPrecun
hubPower_IPS
hubPower_MFG_visuosp
hubPower_SMA
hubPower_MFG_RECN
hubPower_MFG_LECN
hubPower_MFG_ECNbilateral

*Specify path of spss table

GET 
  FILE='/Volumes/FB-LIP/Projects/NKI_enhanced/data/mri/analyses/Paper1_2017_Variability_integration/NKI_enhanced_rest/D_thalamocortical_upregulation/scripts/thalamocortical_upregulation.sav'. 
DATASET NAME DataSet1 WINDOW=FRONT. 

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT PCAdim_ant_salience 
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_ant_salience DIFF_cortex_thalamus_ant_salience.


REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT PCAdim_auditory 
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA 
    hubPower_MFG_ECNbilateral HornPower_auditory DIFF_cortex_thalamus_auditory.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_dDMN
  /METHOD=ENTER hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_dDMN DIFF_cortex_thalamus_dDMN.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_high_visual
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_high_visual DIFF_cortex_thalamus_high_visual.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_language
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_language DIFF_cortex_thalamus_language.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_LECN
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA HornPower_LECN DIFF_cortex_thalamus_LECN.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_post_salience
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_post_salience DIFF_cortex_thalamus_post_salience.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_precuneus
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_precuneus DIFF_cortex_thalamus_precuneus.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_prim_visual
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_prim_visual DIFF_cortex_thalamus_prim_visual.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_RECN
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA HornPower_RECN DIFF_cortex_thalamus_RECN.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_sensorimotor
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_MFG_ECNbilateral HornPower_sensorimotor DIFF_cortex_thalamus_sensorimotor.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_vDMN
  /METHOD=ENTER hubPower_PCCPrecun hubPower_IPS hubPower_MFG_visuosp hubPower_SMA hubPower_MFG_ECNbilateral HornPower_vDMN DIFF_cortex_thalamus_vDMN.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT PCAdim_visuospatial
  /METHOD=ENTER hubPower_PCCPrecun hubPower_SMA hubPower_MFG_ECNbilateral HornPower_visuospatial DIFF_cortex_thalamus_visuospatial.

* Save output

OUTPUT SAVE OUTFILE='/Volumes/FB-LIP/Projects/NKI_enhanced/data/mri/analyses/Paper1_2017_Variability_integration/NKI_enhanced_rest/D_thalamocortical_upregulation/results/NKI_regressions_control_hub_power.spv'.
