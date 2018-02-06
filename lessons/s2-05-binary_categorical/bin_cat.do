capture log close

log using "bin_cat_stata.log", replace

// Working with binary and cateogrical independent variables
// Will Doyle
// 2018-01-29
// Practicum repo on github

// TOC

local coding=1

local regression=1

local margins=1


//locals

global ddir "../../data/"

local y bynels2m 

local controls byses1

local ttype tex

/**************************************************/
/* Coding */
/**************************************************/
    
if `coding'==1{

use ${ddir}plans.dta, clear

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

local race_names amind asian black hispanic_no hispanic_race multiracial white

tab(byrace), gen(race_)

local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable white "White"
label variable multiracial "Multiracial"

label variable byincome "Income"


gen hispanic=0
replace hispanic=1 if hispanic_no==1|hispanic_race==1
replace hispanic=. if byrace==.

label variable hispanic "Hispanic"

local plan_names noplan dontknow votech cc fouryr earlygrad

recode byrace (4/5=4) (6=5) (7=6) (.=.), gen(byrace2)

label define byrace2 1 "Am.Ind." 2 "Asian/PI" 3 "Black" 4 "Hispanic" 5 "Multiracial" 6 "White"

label values byrace2 byrace2

gen urm=.
replace urm=0 if byrace2==4 | byrace2==6
replace urm=1 if byrace2==1 | byrace2==2 | byrace2==3 | byrace2==5
  
tab(f1psepln), gen(plan_)

local i=1

foreach val of local plan_names{
  rename plan_`i' `val'
  local i=`i'+1
}


label variable noplan "Plans: No plans"
label variable dontknow "Plans: Don't know"
label variable votech "Plans: Voc/Tech School"
label variable cc "Plans: Comm Coll"
label variable fouryr "Four Year"
label variable earlygrad "Early Graduation"

/* Plans for those who have them */

gen order_plan=.
replace order_plan=1 if noplan==1| dontknow==1
  replace order_plan=2 if votech==1|cc==1
  replace order_plan=3 if fouryr==1

label define orderplan 1 "---No Plans/DK" 2 "---Votech/CC" 3 "---Four Year"

label values order_plan orderplan
  
local pareds bymothed byfathed bypared

local ed_names nohs hs 2yrnodeg 2yr some4  4yrgrad masters phd

foreach pared of local pareds{

tab(`pared'), gen(`pared'_)

local i=1

foreach val of local ed_names{
  rename `pared'_`i' `pared'_`val'
  local i=`i'+1
}

label variable `pared'_nohs "Less than HS"
label variable `pared'_hs "HS/GED"
label variable `pared'_2yr "CC" 
label variable `pared'_some4 "Four year attend"
label variable `pared'_4yrgrad "Bachelor's"
label variable `pared'_masters "Master's"
label variable `pared'_phd "PhD"
}


// Recode Mother Education

recode bymothed (1=1) (2=2) (3/5=3) (6/8=4) (.=.), gen(bymothed2)

label define pared2 1 "---Less than HS" 2 "---HS" 3 "---Some College" 4 "---College or More"

label values bymothed2 pared2

label define expect -1 "Don't Know" 1 "Less than HS" 2 "HS" 3 "2 yr" 4 "4 yr No Deg" ///
    5 "Bachelors" 6 "Masters" 7 "Advanced"

label values bystexp expect
  
tab bystexp,gen(exp_)

gen female=bysex==2
replace female=. if bysex==.

lab var female "Female"

// Recode test scores 

//replace bynels2m=bynels2m/100

//replace bynels2r=bynels2r/100  
  
recode f2ps1sec (1=1) (2=2) (4=3) (3=4) (5/9=4), gen(first_inst)

label define sector 1 "Public 4 Year" 2 "Private 4 Year" 3 "Public 2 Year"  4 "Other"

label values first_inst sector

   
lab var bynels2m "10th Grade Math Scores"
lab var bynels2r "10th Grade Reading Scores"
lab var byses1 "SES"
lab var byses2 "SES v2"

save ${ddir}plans2.dta, replace

}/*End coding section */

else use ${ddir}plans2.dta, clear

// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

tab order_plan

// NOPE!
eststo order1: svy: reg `y' order_plan

//Proper factor notation
eststo order1: svy: reg `y' i.order_plan byses1 female


esttab order1 using order1.`ttype',  varwidth(50) label  ///
				nobaselevels ///
               nodepvars              ///
                   b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                   
			   
			   
esttab order1 using order1.`ttype',  varwidth(50) label  ///
    refcat(2.order_plan "Plans, Reference= No Plans/ Don't Know",nolabel) ///
        nobaselevels ///
               nomtitles ///
               nodepvars              ///
                b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                   


//Proper factor notation
eststo order1: svy: reg `y' i.order_plan i.bymothed2 byses1 female

esttab order1 using order1a.`ttype',  varwidth(50) label  ///
    refcat(2.order_plan "Plans, Reference= No Plans/ Don't Know" 2.bymothed2 "Mother's Education, Ref= Less than HS"  ,nolabel) ///
        nobaselevels ///
               nomtitles ///
               nodepvars              ///
                b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                   
			   
			  
			   

//Proper factor notation: setting base levels
eststo order2: svy: reg `y' ib(freq).order_plan byses1 female

esttab order2 using order2.`ttype',  varwidth(50) label  ///
               nodepvars              ///
                   b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace                   


esttab order2 using order2.`ttype',  varwidth(50)   ///
    refcat(1.order_plan "College Plans, Reference=Plans to go to College",nolabel) ///
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

margins, predict(xb) at((mean) byses1 order_plan=(1 2 3)) post

// Factor notation, interaction

//Proper factor notation: setting base levels
eststo order3: svy: reg `y' b3.order_plan##i.female byses1

esttab order3 using order3.`ttype', varwidth(50) ///
    refcat(1.order_plan "College Plans, Reference=Plans to go to College:" 1.order_plan#1.female "Interaction of Plans with Female:", nolabel) ///
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


// Margins to figure out what's going on
margins, predict(xb) at((mean) byses1 order_plan=(1 2 3) female=(0 1)) post

esttab . using margins.`ttype' , margin label nostar ci ///
    varlabels(1._at "No College Plans, Male" ///
                  2._at "No College Plans, Female" ///
                      3._at "Vo-Tech/Community College, Male" ///
                          4._at "Vo-Tech/Community College, Female" ///
                              5._at "Four-Year College Plans, Male" ///
                                  6._at "Four-Year College Plans, Female" ) ///
        replace


log close
exit
