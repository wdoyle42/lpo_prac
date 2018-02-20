## Simulation

Using simulation can help to explain various aspects of statistical
analysis without the need for proofs. Below, I ask you to complete a
simulation study to figure out if an approach is appropriate for a
certain situation.

You are trying to establish the association between planning to go to
college and math scores, using the plans dataset. You're wondering
whether it would be better to include a control for both ses AND
whether the parent went to college. Complete the following steps to
figure this out.


1. Create a simulated binary variable for planning to go to college. Ensure that
   the same proportion of your population wants to go to college as in
   the sample. Also make sure that this variable is correlated with
   SES and parental education in the same magnitude and direction as
   in your smaple.
2. Create another binary variable for whether the respondent's mother
   graduated from college. Make this also have the same proportion of
   your sample is in the plans dataset, and has the same correlation
   with SES and planning to go to college.
3. Create the outcome variable (math scores) as a function of SES,
   planning to go to college and parental education. Make this
   flexible such that the impact of parental education can vary.
4. Repeatedly sample from the population data you generated above,
   then run two regressions for each sample, one which includes
   parental education and one which does not. Create a graphic that
   shows the sampling distribution for your coeffiicent for planning
   to go college when you do and don't control for both SES AND
   parental education.
5. Now allow the impact of parental education on math scores to vary in the
   population. Run a Monte Carlo study that shows what happens to the
   sampling distribution of coefficients for planning to go college
   when do and don't control for both SES and parental education when
   parental education has differing impacts on math scores. 

