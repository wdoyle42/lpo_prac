
//How to create an index via iteration

clear

local j=1 /* Initialize j*/

foreach my_corr of numlist .05(.05).95{

clear

di "The correlation is currently `my_corr'"

gen x=`my_corr'

di "The counter is now set to: `j'"

save  "run_`j'", replace

local j=`j'+1 /* Iterate*/

}
