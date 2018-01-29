/************************************************************************
*** You may need to edit this code.                                  ***
***                                                                  ***
*** Please check all CD statements and USE statements before         ***
*** running this code.                                               ***
***                                                                  ***
*** You may have selected variables that contain missing data or     ***
*** valid skips. You may wish to recode one or both of these special ***
*** values. You need to consult the Variable Description to see if   ***
*** these special codes apply to your extracted variables. You can   ***
*** recode these special values to missing using the following       ***
*** sample code:                                                     ***
***                                                                  ***
*** replace {variable name} = . if {variable name} = {value};        ***
***                                                                  ***
*** Replace {variable name} above with the name of the variable you  ***
*** wish to recode. Replace {value} with the special value you wish  ***
*** to recode to missing.                                            ***
***                                                                  ***
*** It is important to retain full sample weights, replicate         ***
*** weights, and identification numbers as appropriate.              ***
************************************************************************/

/* Change delimiter to a semi-colon */
#delimit;

/* Clear everything */
clear;

/* Change working directory */
cd "C:\EDAT\ECLS-K\";

/* Increase memory size to allow for dataset */
set memory 250m;


/* Create formats */

label define N000001F 1             "SPEAK SPANISH AT HOME", modify;
label define N000001F 2             "DON'T SPEAK SPANISH AT HOME", modify;

/* Import ASCII data using dictionary */
infile using "k8_child_Dict_170912115141";

/* Assign format to variables */
label values C1SPHOME N000001F;

/* Compress the data to save space */
compress;


/* Save dataset */
save "k8_child_170912115141", replace;

/* Display frequencies for the categorical variables */
tabulate C1SPHOME;
