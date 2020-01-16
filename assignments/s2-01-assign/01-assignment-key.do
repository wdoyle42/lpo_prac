capture log close

// Assignment 1
// programming and conditional means
// Will Doyle
// REV: 2020-01-16
// on github


use ../../data/plans2.dta, clear

// Takes a variable list (assumed to be a series of continuous variables)
// as its argument.

// Converts each continuous variable into a series of dummy variables, 
//one for each quartile.

// Returns dummy variables that are appropriately labeled 
//(both as variables and values).

local myvars bynels2m bynels2r byses1

foreach number_quantiles of numlist 2 4 10{

	foreach myvar of local myvars{
		egen `myvar'_q_`number_quantiles'=cut(`myvar'), group(`number_quantiles')

		tab `myvar'_q_`number_quantiles', gen(`myvar'_quantile_`number_quantiles'_q_)

		foreach i of numlist 1/`number_quantiles'{
			la var `myvar'_quantile_`number_quantiles'_q_`i' "`myvar' with `number_quantiles' quantiles  quantile `i'"
				} // End loop over binary variable quartiles

		} // End loop over variables

		
} // End loop over number of quantiles


//

foreach i of numlist 2 4 10{
egen cond_mean_`i'=mean(bynels2m), by(byses1_q_`i')

gen sq_resid_cond_mean_`i'=(bynels2m-cond_mean_`i')^2

sum sq_resid_cond_mean_`i'

scalar mse_`i'=r(mean)

scalar rmse_`i'=sqrt(mse_`i')

}


//generate a simple mean of your dependent variable
egen uncond_mean=mean(bynels2m)

gen sq_resid_uncond_mean=(bynels2m-uncond_mean)^2

sum sq_resid_uncond_mean

scalar mse_uncond=r(mean)

scalar rmse_uncond=sqrt(mse_uncond)

reg bynels2m byses1

predict reg_resid, residual

gen reg_resid_sq=reg_resid*reg_resid

sum reg_resid_sq

scalar mse_reg=r(mean)

scalar rmse_reg=sqrt(mse_reg)

exit 

