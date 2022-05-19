/***
# Machine Learning Using Stata
***/
	
	
/* Machine Learning */
/* Will Doyle */
/* 2022-05-19 */

/* 

## Machine Learning	

Machine learning is a catch-all term used for the process of predictive modeling
in cases where (a) predictive accuracy is paramount and (b) making inferences 
from parameter estimates is either not important or of no concern whatsoever. 

The canonical examples of machine learning come from situations where the analyst has
a fairly large dataset (say greater than 1,000,000 cases) and a very large number of potential 
covariates (say 1000s). The analyst is not testing any theories about any given covariate,
but simply wishes to use the data available to come up with an accurate prediction. 

Machine learning mostly comes from engineering, but has been making its way into the social sciences. 

A few notes on terminology:

A "feature" in machine learning is a covariate.




*/	
	

/***

## Software

The "lassopack" from this site is a really good resource for the tools we'll need. 

https://statalasso.github.io/docs/lassopack/

***/	

/***

	
	
// net install pdslasso, ///
//	from("https://raw.githubusercontent.com/statalasso/pdslasso/master/") 


## Readings:

The best text is still Elements of Statistical Learning from Hastie et al. It's available for free download here:

https://hastie.su.domains/ElemStatLearn/

***/


/***
## Feature Selection

When faced with a situation with a large number of possible predictors, machine learning proceed via feature selection. There are two commonly used approaches to feature selection: ridge and lasso. In addition, there's a hybrid approach between the two, called 'elastic net'. What we'll do today is implement both the ridge and the lasso, then use tools to cross validate the results. Finally, we'll tune the hyperparameters in the model. 


### Ridge Regression

The ridge approach uses a downweighting function that utilizes the square of the existing covariates. This penalty is referred to as lambda. The idea is that covariates that don't contribute as much to model fit will be downweighted using a square power function. 

### Lasso

The lasso approach uses a downwweighting function that's based on the absolute value of the existing covariates. This approach to penalization will result in highly correlated covariates being quickly downweighted to 0. 

### Elastic net

Elastic net is a combination of ridge and lasso. It proceeds by using a mixture (alpha) which determines how much of the penalty (lambda) will come from ridge and lasso. It's a kind of compromise between the two approaches. 

***/


/*
## Cross Validation

The essence of prediction is discovering the extent to which our models can predict outcomes for data that does not come from our sample. Many times this process is temporal. We fit a model to data from one time period, then take predictors from a subsequent time period to come up with a prediction in the future. For instance, we might use data on team performance to predict the likely winners and losers for upcoming soccer games. 

This process does not have to be temporal. We can also have data that is out of sample because it hadn't yet been collected when our first data was collected, or we can also have data that is out of sample because we designated it as out of sample.

The data that is used to generate our predictions is known as 
*training* data. The idea is that this is the data used to train our model, to let it know what the relationship is between our predictors and our outcome. So far, we have worked mostly with training data. 

That data that is used to validate our predictions is known as *testing* data. With testing data, we take our trained model and see how good it is at predicting outcomes using out of sample data. 

One very simple approach to this would be to cut our data in half. This is what we've done so far.  We could then train our model on half the data, then test it on the other half. This would tell us whether our measure of model fit (e.g. rmse, auc) is similar or different when we apply our model to out of sample data. 

But this would only be a "one-shot" approach. It would be better to do this multiple times, cutting the data into two parts: training and testing, then fitting the model to the training data, and then checking its predictions against the testing data. That way, we could generate a large number of rmse's to see how well the model fits on lots of different possible out-of-sample predictions. 

This process is called *cross validation*, and it involves two important decisions: first, how will the data be cut, and how many times will the validation run. 


*/ 	
	
net install lassopack, ///
	from("https://raw.githubusercontent.com/statalasso/lassopack/master/")  replace
	
use ../../data/plans2, clear	

local y bynels2m

local features bynels2r byses1 i.byrace i.f1psepln i.bysex i.bypared

/***

## Regular old regression

We'll begin by predicting math scores as a function of a standard set of characteristics, including
reading scores, ses, race, plans to go college, sex and parental education

***/

reg `y' `features'

 
 
 
 /***

### Ridge Regression

We'll use the lasso2 command from lassopack throughout these examples. In lasso2, 
lambda is the overall penalty level, which controls the general degree of penalization, while alpha is the elastic net parameter, which determines the relative contribution of ridge vs. lasso. Alpha=1 is lasso, while alpha =0 is ridge. The command is set to hold alpha at 1 by default.   

lasso2 is set up by default to try and find the lambda that has the most predictive power. We're going to override this and use a pre-set series of lambdas, from .2 to .01.

Note: I'm using the glmnet notation because that's most familiar to me. 

***/


 
lasso2 `y' `features',  alpha(0) lambda(.2(.05).01) lglmnet

lasso2, lic(ebic)




/*** 
### Lasso Regression

Setting  alpha to 1 switches us over to lasso

***/
 
 

lasso2 `y' `features',  alpha(1) lambda(.2(.05).01) lglmnet

lasso2, lic(ebic)
 
 


/*** 
### Elastic Net

Setting  alpha to .5 indicates that we want an "equal" weight for both ridge and lasso. 

***/


lasso2 `y' `features',  alpha(.5) lambda(.2(.05).01) lglmnet


lasso2, lic(ebic)
 
 


/***

### Hyperparameter tuning and cross validation

So far we've specified lambda and alpha by hand. But we really should try lots of different values of each
to try and figure out which combination gives us the best model fit. We'll do that via cross validation. What we'll do is divide the dataset 10 unique times, then estimate each combination of alpha and lambda for each training/testing divide set by that fold. 

***/

 
//cvlasso `y' `features',  alpha (0 .1 .5 1)  lambda(.2(.05).01) lglmnet postest


cvlasso `y' `features',  alpha (0 .1 .5 1)  lcount(5) lglmnet plotcv // Don't use lcount 5!

graph save cv_graph.gph, replace
