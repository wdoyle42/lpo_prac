Assignment 8
================
LPO 9951 | Fall 2016

Complete the following steps:

1.  Based on your work in assignment 7, recompile your dataset with appropriate weights.
2.  Calculate the mean and standard errors of five continuous (and/or binary) variables *without* taking into account the sampling design.
3.  Perform this same calculations, this time using the `svyset` command and `svy: mean` to calculate the mean and standard error of these same variables taking into account the sampling design, using linearized estimates of the variance. Then repeat the above, using another method (e.g., BRR, jackknife, bootstrap) to estimate the variance.
4.  Present the results of all three estimation techniques into nicely formatted output. This can be Stata window output, but organize it in such a way that I don't have to hunt. Perhaps scalars? Or if you are feeling bold, matrices.
5.  Describe the differences you observe in one paragraph. In a second paragraph, speculate as to why you may have found these differences. This can be writen in the do file as a long comment.

<br>
