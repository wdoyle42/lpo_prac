capture log close
// LPO Practicum
// Will Doyle
// Spring 2017
// Advanced Reporting: complex tables and graphics



clear

set more off

graph drop _all

global ddir "../../data/"

use ${ddir}attend, clear

describe

/* Missing data*/

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -3 -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */


/* Recodes */
  
local race_names amind asian black hispanic_race hispanic_norace multiracial white

tab(byrace), gen(race_)

local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

gen hispanic=hispanic_race==1|hispanic_norace==1

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable hispanic "Hispanic"
label variable white "White"
label variable multiracial "Multiracial"

local race amind asian black hispanic multiracial 


gen expect_college=.

replace expect_college=1 if bystexp>=5 & bystexp <.
replace expect_college=0 if bystexp>0 &bystexp <5

/* Set locals */

local y f2evratt

local x expect_college

local ses byses1

local race  amind asian black hispanic multiracial

local sex  bysex

local tests bynels2m bynels2r

local controls "ses" "race" "sex" "tests" 

local gtype pdf


exit
// Balance test



if `systemno'==4{        
 quietly reg `test_var' tsaa_eli if abs(running)<`bw' & acyear<2007
}
else{
 quietly reg `test_var' tsaa_eli if abs(running)<`bw' & system2==`systemno' &acyear<2007
}

scalar my_diff = round(_b[tsaa_eli],.001)

scalar my_t =round(_b[tsaa_eli]/_se[tsaa_eli],`my_sig')

mat M= [my_diff,my_t]

if `bw'==27{
    mat M_line=M
}
else mat M_line=(M_line,M)

} // End bandwidth loop

if `i'==1{
    mat M_out=M_line
}
else mat M_out=(M_out \ M_line)

    local i=`i'+1
} // End variable loop

if `systemno'==1{
mat M_balance=M_out
}
else mat M_balance=(M_balance \M_out)

}

// Regression results

    
if `regression'==1{

//Local Linear, no FE

foreach systemno of numlist 1/4{

capture mat drop beta_line se_line

foreach bw of local bws{

//Full Sample
    
if `systemno'==4{
reg persist `interact' `controls' i.acyear if abs(running)<`bw' & acyear<2007 , robust
}

else{
 reg persist `interact' `controls' i.acyear if abs(running)<`bw'&system2==`systemno' & acyear<2007 , robust
}


if `bw'==27{
    mat beta_line=round(_b[tsaa_eli],`my_sig')
    mat se_line=round(_se[tsaa_eli],`my_sig')
    mat n_line=e(N)
}
else{
    mat beta_line=(beta_line,round(_b[tsaa_eli],`my_sig'))
    mat se_line=(se_line,round(_se[tsaa_eli],`my_sig'))
    mat n_line=(n_line,e(N))
}


}


mat M_out=(beta_line \ se_line \n_line)

if `systemno'==1{
mat loc_results=M_out
}
else{
mat loc_results=(loc_results \M_out)
}
}


// Complex Graphics

// Combine three sectors

grc1leg2 persist_1.gph persist_2.gph persist_3.gph, legendfrom(persist_1.gph) rows(1) name(persist,replace)
