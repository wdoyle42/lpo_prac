/***
LPO 9952
=================

Binary and Categorical Variables in Regression
=================

Binary and categorical variables can be a headache to work with. It's worth taking some time to think about each step 
with these kinds of variables in order to make sure that they are being reported effectively. 

***/


capture log close

log using "bin_cat_stata.log", replace

// Working with binary and cateogrical independent variables
// Will Doyle
// 2021-03-04
// Practicum repo on github

// TOC

local coding=1

local regression=1

local margins=1

//locals

global ddir "../../data/"

local y bynels2m 

local controls byses1

local ttype rtf

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

/***

## Coding

First, it's worth thinking pretty carefully about how these variables
will be coded. Are you sure that they are mutually exclusive and
exhaustive? How about the numbers of categories? Are these appropriate
for the task at hand? Are they really categorical or can they be
thought of as ordered? How would you figure this out? 

In general, it's better to favor fewer categories, but you need to
make sure that your decisions reflect the important questions in your
theoretical framework. 

Below, I recode the race variables as they're constructed by NCES to
be more useful in our analysis. 


***/										  
										  
										  
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

/***

## Binary Variables

Binary variables must always be constructed to be directional. Never
have a binary variable for ``sex,'' always construct this kind of
binary variable as either  student identified as``male'' or student identified as``female.'' Binary variables in
a regression represent an intercept shift-- for the group in question,
they increase or decrease the intercept by that amount.  

***/


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


/***


## Categorical Variables

When running a model with categorical variables, Stata won't always
know what you're talking about. If the underlying variable is numeric,
it will simply include that variable as numeric. This is not
good. Instead, we need to use the \texttt{i.} formulation, which
specifies not only that a given variable is to be understood as a
factor variable, but also allows the user some fine-grained control
over how this will be constructed. 

Remember that categorical variables must always be interpreted
relative to their reference category. We cover how to think about that
next. 

***/

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

/*
1  did not finish high school
                         3,044         2  graduated from high school or
                                          ged
                         1,663         3  attended 2-year school, no
                                          degree
                         1,597         4  graduated from 2-year school
                         1,758         5  attended college, no 4-year
                                          degree
                         3,466         6  graduated from college
                         1,785         7  completed master^s degree or
                                          equivalent
                         1,049         8  completed phd, md, other
                                          advanced degree
                           856         .  

*/

/***

## Quick Exercise
Run the above regression, but use parental education as a
predictor. Create a properly formatted table with parental education
as a categorical variable. 

***/

/***

## Reference Categories for Categorical Variables

It's important to put some thought into reference categories for
category variables. If you have no other preference, then use the
largest group. You can accomplish this via the \texttt{ib(freq).}
command. You should put some careful thought into the contrasts you'd
like to draw--which groups do you want to compare and why? 

***/
			   
			   
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


/***

## Quick Exercsie

Run the regression above, but include parental education. This time,
output the results with some college as the reference category for
parental education. 

***/


/***
## Interactions


When interacting a binary variable with a categorical variable, you
must do the FULL interaction-- you can't just interact with one
level. Same thing applies to continuous variables. 

***/

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

			   
/***

## Margins and Interactions

Once you're undertaking interactions with categorical variables, it's
generally a good idea to interpret them using the margins command. In
the below code I use margins to interpret the interaction between a
categorical and a binary variable and to make a table with confidence
intervals from the output. 


***/			   
			   

// Margins to figure out what's going on
margins, predict(xb) at((mean) byses1 order_plan=(1 2 3) female=(0 1)) post

estimates store order_female

esttab . using margins.`ttype' , margin label nostar ci ///
    varlabels(1._at "No College Plans, Male" ///
                  2._at "No College Plans, Female" ///
                      3._at "Vo-Tech/Community College, Male" ///
                          4._at "Vo-Tech/Community College, Female" ///
                              5._at "Four-Year College Plans, Male" ///
                                  6._at "Four-Year College Plans, Female" ) ///
        replace 


// not great
marginsplot, name(margins_1,replace)

// better

marginsplot, recast(scatter) ciopts(recast(rspike)) name(margins_2,replace)

// best

preserve

estimates restore order_female

parmest,  list (parm estimate min95 max95) fast

egen levels =fill(1/6)

graph twoway bar estimate levels

restore

/***

## Quick Exercise

Again include parental education, and generate predicted probabilities
using the margins command. Then go back and choose a different
reference category. Does a different reference category result in
different predicted probablities? 
***/
 

log close
exit
