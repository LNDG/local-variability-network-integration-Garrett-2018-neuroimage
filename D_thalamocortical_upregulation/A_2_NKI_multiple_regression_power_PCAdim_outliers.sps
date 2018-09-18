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

*Specify spss table directory below!


GET 
  FILE='/Volumes/FB-LIP/Projects/NKI_enhanced/data/mri/analyses/Paper1_2017_Variability_integration/NKI_enhanced_rest/D_thalamocortical_upregulation/scripts/thalamocortical_upregulation.sav'. 
DATASET NAME DataSet1 WINDOW=FRONT. 

*calculate paired ttests: compare thalamic (Horn) and cortical power for each network

T-TEST PAIRS=corticalPower_auditory corticalPower_dDMN corticalPower_vDMN corticalPower_LECN 
    corticalPower_RECN corticalPower_high_visual corticalPower_language corticalPower_precuneus 
    corticalPower_prim_visual corticalPower_ant_salience corticalPower_post_salience 
    corticalPower_sensorimotor corticalPower_visuospatial WITH HornPower_auditory HornPower_dDMN 
    HornPower_vDMN HornPower_LECN HornPower_RECN HornPower_high_visual HornPower_language 
    HornPower_precuneus HornPower_prim_visual HornPower_ant_salience HornPower_post_salience 
    HornPower_sensorimotor HornPower_visuospatial (PAIRED) 
  /CRITERIA=CI(.9500) 
  /MISSING=ANALYSIS.




*############################################################
*## Multiple regression models for all 13 networks with outlier-removal ##
*##         outliers: worst 5% of MAH Q-Q plot                                              ##
*############################################################

*Anterior salience

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 117168 or ID = 154419 or ID = 106780)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 117168 or ID = 154419 or ID = 106780) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_ant_salience
  /METHOD=ENTER HornPower_ant_salience PCAdim_ant_salience
  /RESIDUALS HISTOGRAM(ZRESID).

*Auditory

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 106780 or  ID = 117168 or ID = 153790)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 106780 or  ID = 117168 or ID = 153790) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_auditory
  /METHOD=ENTER HornPower_auditory PCAdim_auditory
  /RESIDUALS HISTOGRAM(ZRESID).



*dDMN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 117168 or  ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 117168 or  ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_dDMN
  /METHOD=ENTER HornPower_dDMN PCAdim_dDMN
  /RESIDUALS HISTOGRAM(ZRESID).


*Higher visual

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 120493 or  ID = 137073 or ID = 170363)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 120493 or  ID = 137073 or ID = 170363)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_high_visual
  /METHOD=ENTER HornPower_high_visual PCAdim_high_visual
  /RESIDUALS HISTOGRAM(ZRESID).


*language

Use all.
COMPUTE filter_$=(not(ID = 103714 or ID = 117168 or  ID = 137073 or ID = 190501 or ID = 106780)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or ID = 117168 or  ID = 137073 or ID = 190501 or ID = 106780)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_language
  /METHOD=ENTER HornPower_language PCAdim_language
  /RESIDUALS HISTOGRAM(ZRESID).


*LECN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_LECN
  /METHOD=ENTER HornPower_LECN PCAdim_LECN
  /RESIDUALS HISTOGRAM(ZRESID).


*Posterior salience

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 149794)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 149794)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_post_salience
  /METHOD=ENTER HornPower_post_salience PCAdim_post_salience
  /RESIDUALS HISTOGRAM(ZRESID).


*precuneus

Use all.
COMPUTE filter_$=(not(ID = 103714 or ID = 137073 or ID = 180093 or ID = 190501 or ID = 112249)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or ID = 137073 or ID = 180093 or ID = 190501 or ID = 112249)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_precuneus
  /METHOD=ENTER HornPower_precuneus PCAdim_precuneus
  /RESIDUALS HISTOGRAM(ZRESID).


*Primary visual

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_prim_visual
  /METHOD=ENTER HornPower_prim_visual PCAdim_prim_visual
  /RESIDUALS HISTOGRAM(ZRESID).



*RECN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 117168 or ID = 106780 or ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or  ID = 117168 or ID = 106780 or ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_RECN
  /METHOD=ENTER HornPower_RECN PCAdim_RECN
  /RESIDUALS HISTOGRAM(ZRESID).


*sensorimotor

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 117168 or ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356  or  ID = 117168 or ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_sensorimotor
  /METHOD=ENTER HornPower_sensorimotor PCAdim_sensorimotor
  /RESIDUALS HISTOGRAM(ZRESID).


*vDMN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_vDMN
  /METHOD=ENTER HornPower_vDMN PCAdim_vDMN
  /RESIDUALS HISTOGRAM(ZRESID).


*visuospatial

Use all.
COMPUTE filter_$=(not(ID = 103714 or ID= 117168 or  ID = 137073 or ID = 180093 or ID = 153790)).
VARIABLE LABELS filter_$ 'not(ID = 103714  or ID= 117168 or  ID = 137073 or ID = 180093 or ID = 153790))) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_visuospatial
  /METHOD=ENTER HornPower_visuospatial PCAdim_visuospatial
  /RESIDUALS HISTOGRAM(ZRESID).


*############################################################
*## Multiple regression models for all 13 networks without outlier-removal ##
*############################################################

*Anterior salience

Use all.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_ant_salience
  /METHOD=ENTER HornPower_ant_salience PCAdim_ant_salience
  /RESIDUALS HISTOGRAM(ZRESID).

*Auditory

Use all.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_auditory
  /METHOD=ENTER HornPower_auditory PCAdim_auditory
  /RESIDUALS HISTOGRAM(ZRESID).


*dDMN

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_dDMN
  /METHOD=ENTER HornPower_dDMN PCAdim_dDMN
  /RESIDUALS HISTOGRAM(ZRESID).

*Higher visual

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_high_visual
  /METHOD=ENTER HornPower_high_visual PCAdim_high_visual
  /RESIDUALS HISTOGRAM(ZRESID).

*language

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_language
  /METHOD=ENTER HornPower_language PCAdim_language
  /RESIDUALS HISTOGRAM(ZRESID).

*LECN

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_LECN
  /METHOD=ENTER HornPower_LECN PCAdim_LECN
  /RESIDUALS HISTOGRAM(ZRESID).


*Posterior salience

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_post_salience
  /METHOD=ENTER HornPower_post_salience PCAdim_post_salience
  /RESIDUALS HISTOGRAM(ZRESID).

*precuneus

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_precuneus
  /METHOD=ENTER HornPower_precuneus PCAdim_precuneus
  /RESIDUALS HISTOGRAM(ZRESID).

*Primary visual

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_prim_visual
  /METHOD=ENTER HornPower_prim_visual PCAdim_prim_visual
  /RESIDUALS HISTOGRAM(ZRESID).


*RECN

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_RECN
  /METHOD=ENTER HornPower_RECN PCAdim_RECN
  /RESIDUALS HISTOGRAM(ZRESID).


*sensorimotor

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_sensorimotor
  /METHOD=ENTER HornPower_sensorimotor PCAdim_sensorimotor
  /RESIDUALS HISTOGRAM(ZRESID).


*vDMN

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_vDMN
  /METHOD=ENTER HornPower_vDMN PCAdim_vDMN
  /RESIDUALS HISTOGRAM(ZRESID).


*visuospatial

Use all.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT DIFF_cortex_thalamus_visuospatial
  /METHOD=ENTER HornPower_visuospatial PCAdim_visuospatial
  /RESIDUALS HISTOGRAM(ZRESID).



*#########################################
*## Repeated measures mixed models ##########
*#########################################

*Anterior salience

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 117168 or ID = 154419 )).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 117168 or ID = 154419) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_ant_salience corticalPower_ant_salience WITH PCAdim_ant_salience 
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_ant_salience.


*Auditory

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 106780 or  ID = 117168 or ID = 153790)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 106780 or  ID = 117168 or ID = 153790) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_auditory  corticalPower_auditory WITH PCAdim_auditory 
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_auditory.


*dDMN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_dDMN  corticalPower_dDMN WITH PCAdim_dDMN
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_dDMN.

*Higher visual

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID = 120493 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID = 120493 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_high_visual corticalPower_high_visual WITH PCAdim_high_visual
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_high_visual.

*language

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID= 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID= 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_language corticalPower_language WITH PCAdim_language
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_language.


*LECN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_LECN corticalPower_LECN WITH PCAdim_LECN
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_LECN.

*Posterior salience

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_post_salience corticalPower_post_salience WITH PCAdim_post_salience
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_post_salience.

*precuneus

Use all.
COMPUTE filter_$=(not(ID = 103714 or ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_precuneus corticalPower_precuneus WITH PCAdim_precuneus
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_precuneus.

*Primary visual

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_prim_visual corticalPower_prim_visual WITH PCAdim_prim_visual
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_prim_visual.


*RECN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 117168)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or  ID = 117168)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_RECN corticalPower_RECN WITH PCAdim_RECN
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_RECN.


*sensorimotor

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356  or  ID = 117168 or ID = 137073 or ID = 180093)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356  or  ID = 117168 or ID = 137073 or ID = 180093)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_sensorimotor corticalPower_sensorimotor WITH PCAdim_sensorimotor
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_sensorimotor 

*vDMN

Use all.
COMPUTE filter_$=(not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714 or  ID = 105356 or ID= 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_vDMN corticalPower_vDMN WITH PCAdim_vDMN
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_vDMN 

*visuospatial

Use all.
COMPUTE filter_$=(not(ID = 103714 or ID= 117168 or  ID = 137073)).
VARIABLE LABELS filter_$ 'not(ID = 103714  or ID= 117168 or  ID = 137073)) (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.
GLM HornPower_visuospatial corticalPower_visuospatial WITH PCAdim_visuospatial
  /WSFACTOR=power 2 Polynomial 
  /MEASURE=power_DIFF 
  /METHOD=SSTYPE(3) 
  /PRINT=ETASQ PARAMETER 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=power 
  /DESIGN=PCAdim_visuospatial

*Save output

OUTPUT SAVE OUTFILE='/Volumes/FB-LIP/Projects/NKI_enhanced/data/mri/analyses/Paper1_2017_Variability_integration/NKI_enhanced_rest/D_thalamocortical_upregulation/results/NKI_multiple_regression_power_PCAdim_outliers.spv'.
