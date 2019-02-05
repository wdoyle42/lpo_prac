capture log close

//  

use caschool_new, clear

/* Using the California schools dataset, estimate a model that identifies
 the predicted impact of an additional computer per student, controlling for
 student teacher ratios, expenditures per student, cal works percent, and 
 free/reduced meal percent on test scores. 

*/

eststo main_model: reg testscr comp_stu str expn_stu_t calw_pct meal_pct

graph twoway scatter testscr comp_stu || ///
             lfitci testscr comp_stu 

/*			 Create a graphic that shows the
 predicted impact of increasing computers per student over its range with 
 uncertainty around the prediction.

 */
 
/* Assume that a policy has been suggested that will provide each district 
with an additional 10 computers for every 100 students. Holding all other 
values at a reasonable level, predict the impact of this increase on student 
test scores at the district level, with an appropriate statement of uncertainty. Remember that what you’ll need to be doing here is forecasting. Assume that you’ll be going from around 10 computers per 100 students to the higher value.

*/

estimates restore main_model

margins, predict(xb) at( (mean) _all comp_stu=(.13 .23)) 


/*
//The legislature is now debating a range of policies, from an increase of 10 
computers per 100 students to 40 per 100. Predict the impact of an increase 
from the minimum suggested level to the maximum suggested level, again with 
an appropriate statement of uncertainty. Plot the result in a manner 
appropriate for presentation to an interested lay audience.

*/

estimates restore main_model

margins, predict(xb) at( (mean) _all comp_stu=(.1 (.05) .4)) 

marginsplot,recast(bar)

/*
Assume that each additional computer costs $500. Calculate the 
cost/benefit ratio of an increase of 10 computers per 100 students for 
the state as a whole in terms of dollars per increase in test scores.
(Hint: you have enrollment numbers for each district in the variable 
enrl_tot.)
*/
 
sum enrl_tot, detail

scalar total_enroll= r(sum)

sum computer, detail

scalar total_computers=r(sum)

scalar overall_comp_stu=total_computers/total_enroll

estimates restore main_model

margins, predict(xb) at( (mean) _all comp_stu=(.11 .21)) post

//Difference in test scores

scalar difference =_b[2._at]-_b[1._at]

scalar new_total_computers=total_enroll*.21

scalar computer_cost=(new_total_computers-total_computers)*500

scalar cost_effect=(computer_cost/difference)/1000

exit 

/*In a separate document, 
comment on the coefficients estimated in the model,
 including their direction and significance. Report 
 the results of your predictions, interpreting them 
 for an interested policy audience. Describe how much 
 it would cost to increase the number of computers per
 student in the state by 10 computers per student, 
 both as a total and as a per student measure. 
 Then describe the uncertainty around your forecast of 
 increasing from the current ratio to the higher level. 
 Make sure to include a graphic for your state legislator. 
 */
 
 /* The results indicate that an increase of 10 computers per 100
 students predicts an increase of 1.7 on the standardized test. If 
 the state were to increase computers per student from its current rate
 of about 10 computers per 100 students to 20 computers per 100 
 students, test scores would be predicted to increase from about 653.7 to 655.4
 However, these results include a substantial amount of uncertainty. As
 the figure shows, at the increased level of .2, predicted scores range from
 654 to 656.8.
 */
 
 
