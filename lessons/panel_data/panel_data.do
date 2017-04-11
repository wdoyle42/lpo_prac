version 12 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */
log using "panel.log", replace
    
/* Panel data */
/* Working with panel datasets, xt commands*/
/* Will Doyle */
/* 170411 */
/* Practicum Folder */

clear
clear mata /* Clears any fluff that might be in mata */
estimates clear /* Clears any estimates hanging around */
set more off /*Get rid of annoying "more" feature */ 

use diss, clear

order state year
sort state year

li if _n <10
	*bysort year: gen x1 = _n
di _N
	*bysort year: gen x2 = _N
*other underscore commands?

/* Reshaping, long to wide and back again */

reshape wide approps_i perc1824 gsppc_i incpcp_i ttld_ft_ percpriv taxcpc_i income_i legcomp_i legideo citideo board pub4tuit_i, i(state)   j(year)

reshape long approps_i perc1824 gsppc_i incpcp_i ttld_ft_ percpriv taxcpc_i income_i legcomp_i legideo citideo board pub4tuit_i, i(state)   j(year) 

drop if state == 1 /* The Alaska problem */
    
/* Set up data as panel data */
xtset state year, yearly

// help tsvarlist

// what is the correlation between appropriations in the current year and appropriations in the prior year?

corr approps_i L.approps_i

// what is the correlation between appropriations in the current year and appropriations two years ago?

corr approps_i L2.approps_i

// what is the average year-to-year difference in public 4-year tuition during the 1990's?

sum D.pub4tuit_i if year>=1990 

sum approps_i L.F.approps_i

/* Some plots */
xtline approps_i

graph export app_line.pdf, replace

xtline pub4tuit_i

graph export tuit_line.pdf, replace

egen pub4_med= median(pub4tuit_i), by(state)

sort pub4_med

#delimit ;
graph hbox pub4tuit_i,
over(state, sort(1) descending label(labsize(tiny) )) /*This was a giant pain*/
;

graph export tuit_box.pdf, replace;

#delimit ;
graph hbox approps,
over(state, sort(1) descending label(labsize(tiny) )) 
;


#delimit ;
graph hbox approps,
over(year, sort(1) descending label(labsize(tiny) )) 
;

graph export approps_box.pdf, replace;

 
#delimit cr


/*Ordinary Least Squares */  

local y approps_i

local controls perc1824 incpcp_i percpriv taxcpc_i  legcomp_i i.board 

reg `y'  legideo `controls'

predict e, resid

graph box e, over(state, sort(1) descending label(labsize(tiny))) /*Horrible*/

graph export resid_state.pdf, replace

graph box e, over(year, sort(1) descending label(labsize(tiny))) /* Not too bad */

graph export resid_year.pdf, replace

/* Fixed Effects for Units (states) */

xi: xtreg `y'  legideo `controls', fe

estimates store fe1

xi: reg `y' legideo `controls' i.state

/* Fixed Effects for Units and Time (state and year) */

xi: xtreg `y' legideo   `controls' i.year , fe

xi: reg `y' legideo `controls' i.state i.year

/* Fixed effects with AR1 error terms */

xi: xtregar `y' legideo `controls', fe rhotype (tsc) twostep lbi

xi: xtpcse `y' legideo `controls' i.state, correlation (ar1) independent

/*Random effects */

xi: xtreg `y' legideo `controls', re

estimates store re1

/*Hausman test */

hausman fe1 re1,  sigmamore

/* First differenced model*/

sort state year 

xtreg D.approps D.legideo D.perc1824 D.incpcp_i D.percpriv D.taxcpc_i  D.legcomp_i   

xtpcse D.approps D.legideo D.perc1824 D.incpcp_i D.percpriv D.taxcpc_i  D.legcomp_i, correlation (ar1) independent

log close

exit 

