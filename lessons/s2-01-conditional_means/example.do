sysuse auto, clear

drop if rep78==.

// Condtional means by rep78, five level ordinal variable
egen double cond_mean_mpg=mean(mpg), by(rep78)

gen double cond_mean_error=mpg-cond_mean_mpg

gen double cond_mean_error_sq=cond_mean_error*cond_mean_error

egen double mse=mean(cond_mean_error_sq)

gen double rmse=sqrt(mse)

li rmse in 1

reg mpg i.rep78

predict yhat

predict reg_resid, residual

// These don't match exactly 

li mpg yhat cond_mean_mpg reg_resid cond_mean_error cond_mean_error_sq mse rmse if yhat!=cond_mean_mpg

