capture log close

// Assignment 5 Followup
// Will Doyle
// 2020-02-20
// On Github

global ddir "../../data/"

use "${ddir}apps_credits.dta"


local y credits

local controls byses1 bynels2m bynels2r 

local xvars i.bypared i.bysex

local interaction_vars i.bypared##i.bysex

local ttype rtf

//1. Create a basic model with four or five key covariates, including continuous, 
//at least one categorical variable and binary variable. 

eststo mod1 : reg `y' `xvars' `controls'

//1. Create a properly formatted table based on these results.

esttab mod1 using 05-assign.`ttype',  varwidth(50) label  ///
refcat(2.bypared "Parental Education, base level= Less than HS",nolabel) ///
				nobaselevels ///
               nodepvars              ///
                   b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                   


//1. Run another model that interacts one categorical variable with one binary variable.

eststo mod2 : reg `y' `interaction_vars' `controls'


//1. Create a properly formatted table based on these results.

esttab mod1 mod2 using 05-assign.`ttype', varwidth(50) ///
    refcat(2.bypared "Parental Education, base level= Less than HS" /// 
	2.bypared#2.bysex "Interaction of Parental Education with Female:", nolabel) ///
	interaction(" X ") ///
	label ///
               nomtitles ///
               nobaselevels ///
               nodepvars              ///
                b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                 
exit 


//1. Run the margins comand to generate predictions from the interacted model,
// with everything held constant except the two variables used for interaction.

//1. Create a table based on the results of the margins command.

//1. Create a figure based on the results of the margins command. 



exit
