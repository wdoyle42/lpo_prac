capture log close                       // closes any logs, should they be open
set linesize 90
log using "cleaning.log", replace    // open new log

// NAME: Data cleaning
// FILE: lecture9_cleaning.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 15 October 2014
// LAST: 24 Ocotber 2016
     
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// load CA school data with problems
use caschool_problem, replace

// replacing problematic variable labels 
describe
label variable gr_span "Grade Span"

// LOOKING FOR OUTLIERS WITH VARIOUS PLOTS

// box plot str
graph box str, name(box_str)
graph export  box_str.eps, name(box_str) replace

// histogram str
histogram str, name(hist_str)
graph export  hist_str.eps, name(hist_str) replace

// IMPOSSIBLE VALUES 

// summarize calw percent
sum calw_pct

// LOOKING FOR IMPLAUSIBLE VALUES WITH VARIOUS PLOTS

// twoway scatter of avginc and meal_pct
graph twoway scatter avginc meal_pct, name(sc_inc_meal)
graph export  sc_inc_meal.eps, name(sc_inc_meal) replace

// CHECKING CALCUATIONS

// create new student teacher ratio variable
gen str_two = enrl_tot / teachers

// twoway scatter of both student teacher ratio variables
graph twoway scatter str_two str, name(sc_str_str_two)
graph export  sc_str_str_two.eps, name(sc_str_str_two) replace

// assume negative means missing and drop
replace teachers = . if teachers == -4

// create another new student teacher ratio variable
gen str_three = enrl_tot / teachers

// twoway scatter of new new and old student teacher ratio variables
graph twoway scatter str_three str, name(sc_str_str_three)
graph export  sc_str_str_three.eps, name(sc_str_str_three) replace

// LOOKING FOR DUPLICATES 

// check for duplicate observations
duplicates report observation_number

// check for duplicate district cod
duplicates report dist_cod

// CHECK FOR NEGATIVE VALUES, MISSING DATA

// inspect test scores
inspect testscr

// inspect reading scores
inspect read_scr

// plot reading scores for further investigation
histogram read_scr, name(hist_read_scr)
graph export hist_read_scr.eps, name(hist_read_scr) replace                                              

// end file     
log close
exit
