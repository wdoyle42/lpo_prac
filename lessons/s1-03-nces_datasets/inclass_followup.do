capture log close

log using "inclass_followup.log", replace

// Follow up to in class prompts
// Will Doyle
// 2020-09-09

global ddir "../../data/"

use ///
BYSES1 ///
BYPARED ///
BYRACE ///
F3PS1SEC ///
using "${ddir}els_02_12_byf3pststu_v1_0.dta", clear

renvars *, lower

save "${ddir}els_analysis.dta", replace

// Recode for misssing 

replace byses1=. if inlist(byses1, -9,-8,-4,-3)

replace bypared=. if inlist(bypared, -9,-8,-4,-3)

replace byrace=. if inlist(byrace, -9,-8,-4,-3)

replace f3ps1sec=. if inlist(f3ps1sec, -9,-8,-4,-3)

tab f3ps1sec

mean byses1, over(f3ps1sec)


graph bar byses1, over(f3ps1sec)

graph bar byses1, over(f3ps1sec, ///
	relabel (1  "Pub 4-year" ///
			 2 "Priv 4-year" ///
			3 "FP 4-year" ///
			4 "Pub 2-year" ///
			5 "Priv 2-year" ///
			6 "FP 4-year" ///
			7 "Pub < 2-year" ///
			8 "Priv <2-year" ///
			9 "FP <2-year") ///
	label(alternate angle(45) labsize(small) ) sort(1))  ///
	ytitle("Average SES") name(SES, replace)
	
gen parent_bach=bypared>6
replace parent_bach=. if bypared==. 	

mean parent_bach, over(f3ps1sec)


graph bar parent_bach, over(f3ps1sec, ///
	relabel (1  "Pub 4-year" ///
			 2 "Priv 4-year" ///
			3 "FP 4-year" ///
			4 "Pub 2-year" ///
			5 "Priv 2-year" ///
			6 "FP 4-year" ///
			7 "Pub < 2-year" ///
			8 "Priv <2-year" ///
			9 "FP <2-year") ///
	label(alternate angle(45) labsize(small) ) sort(1))   ///
	ytitle("Pr(Parent has BA)") name(parent_ed, replace)


exit 
