---
output:
  pdf_document: default
  html_document: default
---
# Assignment 3

Using the api dataset,(https://stats.idre.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop) complete the following steps for the full sample AND three different levels of school spending: low enrollmlent (less than 25th percentile in enrollment), middle (middle two quartiles), large (above or equal to 75th percentile). Do this by creating a loop structure around the following
steps.

1. Create a series of macros, one for each of the following characteristics of schools: students, teachers, parents

2. Create a table of descriptive statistics for these variables using the esttab command.
Make sure it is clearly labeled.

3. Generate a table of conditional means of api00 as a function of other interesting independent
variables.

4. Create a scatterplot or scatterplots that display some of the key relationships in the data.
Clearly label this scatterplot.

5. Run a series of regressions, one for each “set” of characteristics and one fully specified
model, with api00 as the dependent variable.

6. Report the results of your regression in a beautifully formatted table.

7. Create a graphic the shows the impact of the various independent variables on the outcome
variable. Clearly label and describe this graphic.

You'll need to submit two files, a do file that will accomplish all of these steps, and a word file that includes all of your graphics and tables.
