#### PURPOSE

Stata programming will save you time, energy, and sanity. Investing the
time now into learning how to program will certainly pay off. It may
seem easy enough now to just copy code 10 times if you need to complete
an operation 10 times, but force yourself to use your programming
skills. By Maymester, you will thank yourself.

<br>

Tools you already have
----------------------

Programming is more than just knowing the most convenient commands to
shorten the time you spend on menial tasks. It involves thinking about
how the commands you do can be combined to make a more efficient,
readable do-file for you and anyone else who will look at it in the
future.

The following points are good places to start when you are trying to
make your program file more efficient.

-   Previous code: You may have already encountered this strategy in the
    work that you have done thus far for the class. Snippets of code
    that you have already toiled over can be used again and again. The
    following tips might come in handy.
    -   Save your do-files\
    -   Label them well\
    -   Re-use old code, copy-paste\
    -   Make templates if you use a certain piece of code often\
    -   Create files to include or do (e.g., "programs" you can
        immediately run for things like dealing with missing data)\
-   Programming: When you approach your Stata script as a programmer,
    you have a different perspective, a certain general approach on how
    to put these pieces together. The following points are questions you
    might ask yourself in going through the general process for
    your program.
    -   What is the overall task I am trying to accomplish?\
    -   How are the variables structured? Which variables go together?\
    -   What tasks need to be repeated?\
    -   What procedures may stay the same, though the numerical values
        may change?

Remember, The three virtues of a computer programmer are laziness,
impatience, and hubris.

*Laziness* The programmer wants to write as little code as is humanly
possible.

*Impatience* The programmer does not have the patience to undertake a
tedious task.

*Hubris* The programmer is proud enough to believe that she can make the
computer accomplish seemingly impossible tasks.\
<br>

          . version 16

          . capture log close

          . log using "programming.log",replace
          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                name:  <unnamed>
                 log:  /Users/doylewr/lpo_prac/lessons/s1-10-programming/programming.log
            log type:  text
           opened on:   4 Nov 2020, 11:14:00

          . clear

Organizing your do file
-----------------------

As your do files increase in length, you will want some type of
organizational structure. A table of contents at the top of the script
can be very helpful. You certainly don't have to do it the way the way
shown below, but you should have something that makes sense to you and
will be clear to others who may read your script.

    . // TABLE OF CONTENTS
    . // 0.0 Set preferences/globals
    . // 1.0 Recoding /*KW: Bart */
            .//  2.0 Descriptivs /*KW: Lisa */
            .//  3.0 Analysis /* KW: Homer */
            .//  4.0 Graphics /* KW: Marge */
            

<br>

          . local recoding=1

          . local analysis=1

          . global gtype png

          . global ttype rtf

          . clear matrix

          . use ../../data/plans2

          . svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

                pweight: bystuwt
                    VCE: linearized
            Single unit: scaled
               Strata 1: strat_id
                   SU 1: psu
                  FPC 1: <zero>

Macros
------

What's a macro? A way of storing information in Stata.

Why? Simplification. Lots of times we use lists of things. Say we need
to use a list of terms that would influence college choice. This could
be financial, academic, and family influences. We choose indicators to
represent variables in each of these areas. What if we change one of
these? We could change it each and every time, or if we had it stored in
a macro we change it just once.

Macros are also used so that commands don't need to be repeated again
and again, and instead can be written just once. This cuts down on
mistakes and allows the analyst to focus on the analysis. The whole goal
here is to get the computer to do the boring (repetitive) tasks, while
the analyst does the interesting (analytical and interpretive) tasks.

There are two types of macos in Stata, local and global macros. Global
macros should basically never be used.

So, let's do a macro: this macro will contain two variables from the
plans dataset, math and reading test scores

          . local tests bynels2m bynels2r 

What can we do now that we have a macro? Any command that can be run on
the object can now be run on the macro. However, the macro must be
referenced corectly. Referring to the macro without quotes will result
in an error:

Why didn't this work? Without proper specification, a macro can not be
accessed. The macro must be *dereferenced*. For STATA to know it's
dealing with a macro, you must put it in single quotes, meaning that you
start with the left tick (\`) and close with the apostrophe ('). Most of
the curse words directed at STATA have come about as a result of this
syntax. To use our macro, we would do the following:

          . summarize `tests' /*Will work */

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |     15,884    45.35452    13.53664      14.71      79.27
              bynels2r |     15,884    29.63405    9.399866       9.74      50.57

          . local ses byses1 byses2

          . summarize `ses'

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
                byses1 |     15,236    .0421042    .7429628      -2.11       1.82
                byses2 |     15,236    .0447427    .7502604      -2.11       1.98

*Quick Exercise*

Create a macro that contains two variables. Run a summarize command on
the macro.

A Note on Local vs. Global macors

When you run a do file with a local macro, Stata will hold that local
macro in memory only while the do file is running. After it stops, the
macro is dropped. This is important. Say you had a do file with a local
named `family`, because it contained variables relating to a student's
family. After running your do file, you'd like to summarize the family
variables.

`. sum`family' \`

You'll get back an error message because the `family` macro is no longer
held in memory. For this reason, when using macros, it's a good idea to
run the do file as a whole each time, instead of just running pieces of
it.

Programming Concepts
--------------------

<br>

Scalars

In the language of matrix algebra, a scalar is a single number. In STATA
a scalar is a value that can only hold one value at a time. The value
can be numeric or a character.

To define a scalar, use the following syntax:

`scalar pi=3.14159`

More usefully we can define scalars to take on the value of a result.
For instance, to calculate a standardized transformation of the variable
\`income' we could do the following:

\`summarize income'

`scalar mean_income=r(mean)`

`scalar sd_income=r(sd)`

`gen stand_income = (income-mean_income)/sd_income`

Scalars are also quite useful if you have a constant in a do file that
you may wish to change. For instance, if you'd like to limit your
analysis to a certain age group, but you might change that age group as
you go through different iterations.

Quick Exercise
--------------

Generate scalars for a binary or continuous variable's sum and a
variable's total number of units from the plans dataset. Divide the sum
by the total number of units to obtain the mean.

The `varlist` Concept
---------------------

A varlist is a list of variables (of all things). Say for instance you
wanted a local that was equal to just data elements that were in the
base year. We know from NCES nomenclature that all base year data
elements in ELS are preceded by \`\`by''. We can use this, plus the wild
card operator \*, to create a varlist in the following way:

local bydata by\*

This tells STATA to include every variable in the local bydata that
begins with by.

Say you wanted to create a local that included the first five variables
in the dataset. This can be done using the - as part of the command:

`local first_five stu_id-f1sch_id`

If you wanted every variable that had ses, and you knew that variables
could only have one letter or number at the end, you could do something
like this:

`local myses *ses?`

*Quick Exercise*

Generate a varlist that contains only nels related variables, without
naming the variables themselves.

The `numlist` concept
---------------------

A numlist is a way of constructing a pattern of numbers. Stata
recognizes several types of patterns for numlists, including a list like
0 1 2, a sequence like 0/2 and a sequence with steps like 0(1)2.

Loops
-----

A loop construct is the basic stepping stone to a life of laziness,
impatience and hubris.

All loop constructs follow the same basic format:

`(A pattern goes here){`
`(A series of commands for each step in the pattern goes here)` }\`

Note the braces: these always denote the beginning and end of a loop.
The brace must follow the pattern command, and must always be closed
after the body of the loop is complete.

With a loop construct, if you can figure out the underlying set of
commands that you'd like to repeat, and if you can figure out the
pattern that you'd like to apply them, you can simplify some pretty
daunting tasks down to something rather simple. There are three basic
ways to run loops in STATA: the `forvalues`, `foreach` and `while`
commands.

Here's an example: Missing data, as you probably know, are a hassle when
working with NCES datasets. They can be listed as -4, -8, or -9.
Replacing this for every single variable in your dataset with a . would
be time consuming and error prone. The following loop structure (which I
will explain later) can accomplish it for you in just a few lines of
code.

          . if `recoding'==1{
          . foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
          .               foreach i of numlist -4 -8 -9 { /* Start inner loop */
          .                      replace `myvar'=. if `myvar'== `i'
          .                                             }  /* End inner loop */
          .                                           } /* End loop over variables */
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          (0 real changes made)
          . local race_names amind asian black hispanic multiracial white
          . drop `race_names'
          . local race_var_label: label byrace2 1
          . di "`race_var_label'"
          Am.Ind.

          . tab(byrace2), gen(race_)

            RECODE of |
               byrace |
           (student^s |
          race/ethnic |
          ity-composi |
                  te) |      Freq.     Percent        Cum.
          ------------+-----------------------------------
              Am.Ind. |        130        0.85        0.85
             Asian/PI |      1,460        9.58       10.44
                Black |      2,019       13.25       23.69
             Hispanic |      2,214       14.53       38.22
          Multiracial |        735        4.82       43.04
                White |      8,678       56.96      100.00
          ------------+-----------------------------------
                Total |     15,236      100.00
          . local i=1 // initialize counter
          . foreach race_name of local race_names{   // loop over each of the elements in race_names identified above
          .         rename race_`i' `race_name' // rename each variable generated by tab as equiv name
          .         local race_var_label: label byrace2 `i' // grab value label for the that level
          .         label var `race_name' "`race_var_label'" // make the value label the variable level
          .         local ++i //iterate counter by 1, equivalent to: local i=`i'+1
          . }
          . 

          . save plans_b, replace
          file plans_b.dta saved
          . }/*end recoding section conditional*/

          . else{
          . use plans_b, clear
          . }/* end else */

          . if `analysis'==1{
          . local y bynels2m bynels2r
          . local demog amind asian black hispanic white bysex
          . local pared bypared bymothed
          . bysort `demog': sum `y' 

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 0, white = 0, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        368    45.99967    13.83643      16.43      77.47
              bynels2r |        368    29.31185    9.736969      10.13      49.66

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 0, white = 0, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        367    43.85275    12.45861      15.71      73.01
              bynels2r |        367    30.55485    8.426174      10.69      49.44

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 0, white = 1, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      4,297     49.4118    12.95041      14.71      78.56
              bynels2r |      4,297    31.34097    9.300624       9.74      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 0, white = 1, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      4,381    47.89092    12.09374      15.65      76.69
              bynels2r |      4,381    32.83335    8.514871      10.12      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 1, white = 0, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,097     39.2063    13.22485         15      75.69
              bynels2r |      1,097    24.68695    9.192204       9.75      47.85

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 0, hispanic = 1, white = 0, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,117    37.84592    12.63614      15.15      73.37
              bynels2r |      1,117    25.64628    8.905022       9.82      49.44

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 1, hispanic = 0, white = 0, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,004    37.07529    11.61478      14.85      74.18
              bynels2r |      1,004    24.00324    8.336857       9.82      48.55

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 0, black = 1, hispanic = 0, white = 0, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,015    35.87664    11.16035      15.12      75.61
              bynels2r |      1,015    25.27687    8.158944      10.01      48.58

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 1, black = 0, hispanic = 0, white = 0, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        738    50.02741     14.3848      15.99      79.27
              bynels2r |        738    28.77725    9.790352       9.95      49.74

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 0, asian = 1, black = 0, hispanic = 0, white = 0, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        722    48.99823     14.1432      15.55      78.99
              bynels2r |        722    29.77144     9.52353      11.08      49.74

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 1, asian = 0, black = 0, hispanic = 0, white = 0, bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         72    38.07569    11.69312       17.8      72.49
              bynels2r |         72    23.41542    7.906922       10.6      41.52

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = 1, asian = 0, black = 0, hispanic = 0, white = 0, bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         58    39.02741    10.36186      22.72      61.15
              bynels2r |         58    27.19207    7.568352      10.79      40.28

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = ., asian = ., black = ., hispanic = ., white = ., bysex = male

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |          0
              bynels2r |          0

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = ., asian = ., black = ., hispanic = ., white = ., bysex = female

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |          0
              bynels2r |          0

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> amind = ., asian = ., black = ., hispanic = ., white = ., bysex = .

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        648    44.80427    11.24556       16.6      72.75
              bynels2r |        648    28.87716    7.237261      11.74      47.24

          . bysort `pared': sum `y'

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = did not, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        926    36.29864     12.1837      15.15      75.23
              bynels2r |        926    22.84815    7.976839       9.86      48.08

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = did not, bymothed = .

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |          0
              bynels2r |          0

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        511    36.89016    12.64277      14.97      73.68
              bynels2r |        511    23.53352    8.278774      10.13      48.66

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      2,507    41.26339    12.42085      15.65      78.99
              bynels2r |      2,507    26.83786    8.626295       9.89      49.44

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = .

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |          0
              bynels2r |          0

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        119     40.2958    13.22161       16.2      71.38
              bynels2r |        119    25.62227    9.093246      10.69      45.23

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        390    44.09467    12.34262      16.17      73.25
              bynels2r |        390    28.69133    8.640406       9.82      48.02

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,154     42.2999    12.93097      14.85      75.24
              bynels2r |      1,154    27.98836      8.9459       9.98      49.54

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         87    39.41598    12.69535      16.17      65.91
              bynels2r |         87    25.34644    8.453047      10.92      47.75

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        290    44.51759    12.90463      17.73      74.46
              bynels2r |        290     28.9041    9.197216       9.74      48.35

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        166    46.53687    10.81539      21.12      71.89
              bynels2r |        166    29.96139    7.494344      10.79      47.54

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,048    44.52222    12.52586      16.12      78.73
              bynels2r |      1,048    29.27707    8.981425      10.16      48.95

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         98    38.19265    12.70117         15       67.5
              bynels2r |         98    25.24755     9.90177      10.24      47.53

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        300     44.1376    12.58255       18.2      74.34
              bynels2r |        300    29.00637    9.190034      10.87      47.63

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        161    45.90783    12.74323       15.8      74.57
              bynels2r |        161    30.09143    9.430261       10.3      47.24

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        137    45.65292      12.219      16.62      72.47
              bynels2r |        137    31.72328    8.576218      11.73      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      1,058    45.07909    12.58754      16.41      77.27
              bynels2r |      1,058    29.85282    8.689249      10.12      49.74

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = attended, bymothed = .

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |          0
              bynels2r |          0

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        120     38.3675    13.72881      17.82      77.52
              bynels2r |        120      24.046    8.737457      10.18      45.64

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        411    47.14669    13.72442      15.49      78.76
              bynels2r |        411    30.39942    9.139422       9.82      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        232     47.2456    12.66077      16.49       73.4
              bynels2r |        232    31.23487    8.861817      10.23      49.74

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        261     50.2146     12.4629      16.24      75.99
              bynels2r |        261    32.90575    8.964075       10.1      49.66

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        326    48.98267    12.41035      17.72      74.13
              bynels2r |        326     32.6615    8.577078      10.89       48.5

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = graduate, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |      2,106    49.20339    12.78511      15.47      77.47
              bynels2r |      2,106    32.28855    9.100237      10.03      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         37    36.31378    11.94017      15.99      58.63
              bynels2r |         37    22.03811    7.576329      11.73       38.4

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        135    45.38874    14.62208      14.71      77.39
              bynels2r |        135    29.01963    9.981705       9.75      49.44

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         86     47.8586    11.66725      20.35      70.35
              bynels2r |         86    31.87558    8.644887      12.61      49.66

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        106    50.90274    11.30089      15.12       72.3
              bynels2r |        106     32.4767    8.426385      11.72      47.83

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        129    51.41047    12.05469      17.99         77
              bynels2r |        129    33.68426    8.956323      10.43      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        433    54.76028    11.66964      18.25      79.16
              bynels2r |        433    36.00127     8.37303      10.72      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = complete

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        854    52.95843     12.6195      15.55      77.25
              bynels2r |        854    34.91924    8.535885      11.52      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = did not

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         19    35.18947    12.76681      17.57      53.63
              bynels2r |         19       20.66    6.436862      12.23      32.54

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         61    45.73295    13.81682      17.49      66.71
              bynels2r |         61    29.39033    10.52368      10.18      48.94

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         47    45.88404    14.42939      22.18      74.77
              bynels2r |         47    30.94447    9.454503      12.65         45

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         60    52.04467    14.45515      17.54      79.27
              bynels2r |         60    33.13267    10.14322      10.68       49.4

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = attended

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |         74    51.29284    13.32049      17.94      77.47
              bynels2r |         74    33.66662    9.308829      11.61      47.85

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = graduate

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        274    56.62336    11.32135      21.78      78.56
              bynels2r |        274    37.13073    7.661651       11.4      49.74

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = complete

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        202    56.10594     11.7006      17.38      75.52
              bynels2r |        202    36.76287    8.197718      10.71      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = complete, bymothed = complete

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        311    51.57942    14.78805      15.72      76.86
              bynels2r |        311    33.90646     9.89402       9.95      50.57

          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          -> bypared = ., bymothed = .

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |        648    44.80427    11.24556       16.6      72.75
              bynels2r |        648    28.87716    7.237261      11.74      47.24

          . scalar pi=3.14159
          .  display "`pi'"


          . summarize bynels2m

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |     15,884    45.35452    13.53664      14.71      79.27
          . scalar mean_math=r(mean)
          . scalar sd_math=r(sd)
          . scalar sum_math=r(sum)
          . scalar units_math=r(N)
          . scalar math_mean=sum_math/units_math
          . gen stand_math= (bynels2m-mean_math)/(2*sd_math)
          (276 missing values generated)
          . local bydata by*
          . local first_five stu_id-f1sch_id
          . local myses *ses?
          . sum *ed

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
               bypared |     15,304    4.500784     2.09164          1          8
              bymothed |     15,301    3.723221    2.012134          1          8
              byfathed |     15,284    3.869798    2.208181          1          8
          . sum by*ed

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
               bypared |     15,304    4.500784     2.09164          1          8
              bymothed |     15,301    3.723221    2.012134          1          8
              byfathed |     15,284    3.869798    2.208181          1          8

The forvalues structure
-----------------------

The `forvalue` command tells STATA to execute the series of commands
within the braces in a numerical format defined by a numlist.

The general structure of a forvalues command is:

`foreach [local_name] of [number pattern] {     (run the following commands on [local\_name])      }`

          . forvalues i= 1/10{
          .  di "This is number {c 96}i'"
          . }
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'
          This is number `i'

In the example above, I defined the placeholder macro i to be equal to
the numlist 1-10, starting at 1 and moving up by one for each run
through the loop. The braces define the body of the loop. The command is
a simple print command, asking STATA to display the text and the value
of the placeholder macro i.

<br> A more complex example is to convert the date of birth variable
into an age, and then convert the result into a series of binary
variables for 14, 15, 16, 17 or 18 years old(you'll need to download and
install the nsplit command).

          . nsplit bydob_p, digits (4 2) gen (newdobyr newdobm)
          . gen myage= 2002-newdobyr
          (977 missing values generated)
          . forvalues i = 14/18{
          . gen age`i'=0
          . replace age`i'=1 if myage==`i'
          . replace age`i'=. if myage==.
          . }
          (0 real changes made)
          (977 real changes made, 977 to missing)
          (108 real changes made)
          (977 real changes made, 977 to missing)
          (8,813 real changes made)
          (977 real changes made, 977 to missing)
          (5,515 real changes made)
          (977 real changes made, 977 to missing)
          (636 real changes made)
          (977 real changes made, 977 to missing)

Foreach
-------

The foreach structure is a more general version of the fovralues
command. The general pattern for a foreach structure is:

`foreach [local\_name] of [varlist, local numlist, etc] {`
`(run the following commands on [local\_name])` `}`

In the example on missing data, I used a foreach command to recode the
variables. Let's use one now to standardize two test variables by
subtracting the mean and dividing by 2 times their standard deviation
(which is recommended by many statisticians).

          . local mytest *nels*
          . foreach test of local mytest {
          .   sum `test'
          . }

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |     15,884    45.35452    13.53664      14.71      79.27
              bynels2r |     15,884    29.63405    9.399866       9.74      50.57
          . foreach test of varlist *nels*{
          .  sum `test'
          .  gen stand_`test'=(`test'-r(mean))/(2*r(sd))
          . }

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2m |     15,884    45.35452    13.53664      14.71      79.27
          (276 missing values generated)

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
              bynels2r |     15,884    29.63405    9.399866       9.74      50.57
          (276 missing values generated)

*Quick Exercise*

Create a macro that contains only base year variables, with the
exception of the two test variables (bynels2m and bynels2r). Write a
loop that tabulates every variable in this macro.

          . forvalues i =1(3)100{
          . di "I can count by threes, look! `i' "
          . }
          I can count by threes, look! 1 
          I can count by threes, look! 4 
          I can count by threes, look! 7 
          I can count by threes, look! 10 
          I can count by threes, look! 13 
          I can count by threes, look! 16 
          I can count by threes, look! 19 
          I can count by threes, look! 22 
          I can count by threes, look! 25 
          I can count by threes, look! 28 
          I can count by threes, look! 31 
          I can count by threes, look! 34 
          I can count by threes, look! 37 
          I can count by threes, look! 40 
          I can count by threes, look! 43 
          I can count by threes, look! 46 
          I can count by threes, look! 49 
          I can count by threes, look! 52 
          I can count by threes, look! 55 
          I can count by threes, look! 58 
          I can count by threes, look! 61 
          I can count by threes, look! 64 
          I can count by threes, look! 67 
          I can count by threes, look! 70 
          I can count by threes, look! 73 
          I can count by threes, look! 76 
          I can count by threes, look! 79 
          I can count by threes, look! 82 
          I can count by threes, look! 85 
          I can count by threes, look! 88 
          I can count by threes, look! 91 
          I can count by threes, look! 94 
          I can count by threes, look! 97 
          I can count by threes, look! 100 

\subsection{The while command}
The while command is a little outdated. It used to be the main way to
construct loops in Stata, but the forvalues and foreach command have
since superseded it i in most cases. However, it can still be useful,
mainly when you're running complex code that you want to stop if
something bad happens.

The general format of the while command is:

`while (a condition is true) {` `(run these commands)` `}`

So, we can repeat the counting program from above, but use the while
command:

          . local i = 1
          . while `i' < 10 {
          .     di "I have not yet reached 10, instead the counter is now `i' "
          .     local i=`i'+1
          .   }
          I have not yet reached 10, instead the counter is now 1 
          I have not yet reached 10, instead the counter is now 2 
          I have not yet reached 10, instead the counter is now 3 
          I have not yet reached 10, instead the counter is now 4 
          I have not yet reached 10, instead the counter is now 5 
          I have not yet reached 10, instead the counter is now 6 
          I have not yet reached 10, instead the counter is now 7 
          I have not yet reached 10, instead the counter is now 8 
          I have not yet reached 10, instead the counter is now 9 
          .   foreach i of numlist 1/10{
          .  di "Foreach can count too, look: `i'"
          .   }
          Foreach can count too, look: 1
          Foreach can count too, look: 2
          Foreach can count too, look: 3
          Foreach can count too, look: 4
          Foreach can count too, look: 5
          Foreach can count too, look: 6
          Foreach can count too, look: 7
          Foreach can count too, look: 8
          Foreach can count too, look: 9
          Foreach can count too, look: 10
          . local by_select bysex byrace bypared-byincome bystexp
          . foreach myvar of local by_select{
          . tab1 `myvar'
          . }

          -> tabulation of bysex  

                                  sex-composite |      Freq.     Percent        Cum.
          --------------------------------------+-----------------------------------
                                           male |      7,639       49.79       49.79
                                         female |      7,702       50.21      100.00
          --------------------------------------+-----------------------------------
                                          Total |     15,341      100.00

          -> tabulation of byrace  

               student^s race/ethnicity-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
          amer. indian/alaska native, non-hispani |        130        0.85        0.85
          asian, hawaii/pac. islander,non-hispani |      1,460        9.58       10.44
          black or african american, non-hispanic |      2,019       13.25       23.69
                      hispanic, no race specified |        994        6.52       30.21
                         hispanic, race specified |      1,220        8.01       38.22
                        multiracial, non-hispanic |        735        4.82       43.04
                              white, non-hispanic |      8,678       56.96      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,236      100.00

          -> tabulation of bypared  

              parents^ highest level of education |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |        942        6.16        6.16
                graduated from high school or ged |      3,044       19.89       26.05
                attended 2-year school, no degree |      1,663       10.87       36.91
                     graduated from 2-year school |      1,597       10.44       47.35
               attended college, no 4-year degree |      1,758       11.49       58.83
                           graduated from college |      3,466       22.65       81.48
          completed master^s degree or equivalent |      1,785       11.66       93.15
          completed phd, md, other advanced degre |      1,049        6.85      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,304      100.00

          -> tabulation of bymothed  

                        mother^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      1,935       12.65       12.65
                graduated from high school or ged |      4,117       26.91       39.55
                attended 2-year school, no degree |      1,849       12.08       51.64
                     graduated from 2-year school |      1,620       10.59       62.22
               attended college, no 4-year degree |      1,589       10.38       72.61
                           graduated from college |      2,820       18.43       91.04
          completed master^s degree or equivalent |      1,060        6.93       97.97
          completed phd, md, other advanced degre |        311        2.03      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,301      100.00

          -> tabulation of byfathed  

                        father^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      2,039       13.34       13.34
                graduated from high school or ged |      4,314       28.23       41.57
                attended 2-year school, no degree |      1,438        9.41       50.97
                     graduated from 2-year school |      1,194        7.81       58.79
               attended college, no 4-year degree |      1,417        9.27       68.06
                           graduated from college |      2,735       17.89       85.95
          completed master^s degree or equivalent |      1,282        8.39       94.34
          completed phd, md, other advanced degre |        865        5.66      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,284      100.00

          -> tabulation of byincome  

                     Income |      Freq.     Percent        Cum.
          ------------------+-----------------------------------
                       none |         80        0.50        0.50
             $1,000 or less |        178        1.10        1.60
              $1,001-$5,000 |        304        1.88        3.48
             $5,001-$10,000 |        351        2.17        5.65
            $10,001-$15,000 |        697        4.31        9.96
            $15,001-$20,000 |        781        4.83       14.80
            $20,001-$25,000 |        996        6.16       20.96
            $25,001-$35,000 |      1,887       11.68       32.64
            $35,001-$50,000 |      3,017       18.67       51.31
            $50,001-$75,000 |      3,309       20.48       71.78
           $75,001-$100,000 |      2,173       13.45       85.23
          $100,001-$200,000 |      1,806       11.18       96.40
           $200,001 or more |        581        3.60      100.00
          ------------------+-----------------------------------
                      Total |     16,160      100.00

          -> tabulation of bystexp  

            how far in |
                school |
               student |
           thinks will |
          get-composit |
                     e |      Freq.     Percent        Cum.
          -------------+-----------------------------------
            Don't Know |      1,450        9.52        9.52
          Less than HS |        128        0.84       10.36
                    HS |        983        6.45       16.81
                  2 yr |        879        5.77       22.58
           4 yr No Deg |        561        3.68       26.26
             Bachelors |      5,416       35.55       61.81
               Masters |      3,153       20.69       82.50
              Advanced |      2,666       17.50      100.00
          -------------+-----------------------------------
                 Total |     15,236      100.00
          . foreach myvar in `by_select'{
          . tab1 `myvar'
          . }

          -> tabulation of bysex  

                                  sex-composite |      Freq.     Percent        Cum.
          --------------------------------------+-----------------------------------
                                           male |      7,639       49.79       49.79
                                         female |      7,702       50.21      100.00
          --------------------------------------+-----------------------------------
                                          Total |     15,341      100.00

          -> tabulation of byrace  

               student^s race/ethnicity-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
          amer. indian/alaska native, non-hispani |        130        0.85        0.85
          asian, hawaii/pac. islander,non-hispani |      1,460        9.58       10.44
          black or african american, non-hispanic |      2,019       13.25       23.69
                      hispanic, no race specified |        994        6.52       30.21
                         hispanic, race specified |      1,220        8.01       38.22
                        multiracial, non-hispanic |        735        4.82       43.04
                              white, non-hispanic |      8,678       56.96      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,236      100.00

          -> tabulation of bypared  

              parents^ highest level of education |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |        942        6.16        6.16
                graduated from high school or ged |      3,044       19.89       26.05
                attended 2-year school, no degree |      1,663       10.87       36.91
                     graduated from 2-year school |      1,597       10.44       47.35
               attended college, no 4-year degree |      1,758       11.49       58.83
                           graduated from college |      3,466       22.65       81.48
          completed master^s degree or equivalent |      1,785       11.66       93.15
          completed phd, md, other advanced degre |      1,049        6.85      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,304      100.00

          -> tabulation of bymothed  

                        mother^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      1,935       12.65       12.65
                graduated from high school or ged |      4,117       26.91       39.55
                attended 2-year school, no degree |      1,849       12.08       51.64
                     graduated from 2-year school |      1,620       10.59       62.22
               attended college, no 4-year degree |      1,589       10.38       72.61
                           graduated from college |      2,820       18.43       91.04
          completed master^s degree or equivalent |      1,060        6.93       97.97
          completed phd, md, other advanced degre |        311        2.03      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,301      100.00

          -> tabulation of byfathed  

                        father^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      2,039       13.34       13.34
                graduated from high school or ged |      4,314       28.23       41.57
                attended 2-year school, no degree |      1,438        9.41       50.97
                     graduated from 2-year school |      1,194        7.81       58.79
               attended college, no 4-year degree |      1,417        9.27       68.06
                           graduated from college |      2,735       17.89       85.95
          completed master^s degree or equivalent |      1,282        8.39       94.34
          completed phd, md, other advanced degre |        865        5.66      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,284      100.00

          -> tabulation of byincome  

                     Income |      Freq.     Percent        Cum.
          ------------------+-----------------------------------
                       none |         80        0.50        0.50
             $1,000 or less |        178        1.10        1.60
              $1,001-$5,000 |        304        1.88        3.48
             $5,001-$10,000 |        351        2.17        5.65
            $10,001-$15,000 |        697        4.31        9.96
            $15,001-$20,000 |        781        4.83       14.80
            $20,001-$25,000 |        996        6.16       20.96
            $25,001-$35,000 |      1,887       11.68       32.64
            $35,001-$50,000 |      3,017       18.67       51.31
            $50,001-$75,000 |      3,309       20.48       71.78
           $75,001-$100,000 |      2,173       13.45       85.23
          $100,001-$200,000 |      1,806       11.18       96.40
           $200,001 or more |        581        3.60      100.00
          ------------------+-----------------------------------
                      Total |     16,160      100.00

          -> tabulation of bystexp  

            how far in |
                school |
               student |
           thinks will |
          get-composit |
                     e |      Freq.     Percent        Cum.
          -------------+-----------------------------------
            Don't Know |      1,450        9.52        9.52
          Less than HS |        128        0.84       10.36
                    HS |        983        6.45       16.81
                  2 yr |        879        5.77       22.58
           4 yr No Deg |        561        3.68       26.26
             Bachelors |      5,416       35.55       61.81
               Masters |      3,153       20.69       82.50
              Advanced |      2,666       17.50      100.00
          -------------+-----------------------------------
                 Total |     15,236      100.00
          . foreach myvar of varlist bysex-byincome{
          . tab `myvar'
          . }

                                  sex-composite |      Freq.     Percent        Cum.
          --------------------------------------+-----------------------------------
                                           male |      7,639       49.79       49.79
                                         female |      7,702       50.21      100.00
          --------------------------------------+-----------------------------------
                                          Total |     15,341      100.00

               student^s race/ethnicity-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
          amer. indian/alaska native, non-hispani |        130        0.85        0.85
          asian, hawaii/pac. islander,non-hispani |      1,460        9.58       10.44
          black or african american, non-hispanic |      2,019       13.25       23.69
                      hispanic, no race specified |        994        6.52       30.21
                         hispanic, race specified |      1,220        8.01       38.22
                        multiracial, non-hispanic |        735        4.82       43.04
                              white, non-hispanic |      8,678       56.96      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,236      100.00

            student^s |
             year and |
             month of |
                birth |      Freq.     Percent        Cum.
          ------------+-----------------------------------
               198300 |         18        0.12        0.12
               198301 |          3        0.02        0.14
               198302 |          3        0.02        0.16
               198303 |          7        0.05        0.20
               198304 |          9        0.06        0.26
               198305 |          5        0.03        0.30
               198306 |          4        0.03        0.32
               198307 |          8        0.05        0.38
               198308 |          4        0.03        0.40
               198309 |          6        0.04        0.44
               198310 |          9        0.06        0.50
               198311 |         16        0.11        0.61
               198312 |         19        0.13        0.73
               198400 |          3        0.02        0.75
               198401 |         24        0.16        0.91
               198402 |         32        0.21        1.12
               198403 |         32        0.21        1.33
               198404 |         29        0.19        1.52
               198405 |         27        0.18        1.70
               198406 |         39        0.26        1.96
               198407 |         46        0.30        2.26
               198408 |         50        0.33        2.59
               198409 |         67        0.44        3.03
               198410 |         91        0.60        3.63
               198411 |         93        0.61        4.24
               198412 |        103        0.68        4.92
               198500 |          9        0.06        4.98
               198501 |        133        0.88        5.86
               198502 |        164        1.08        6.94
               198503 |        169        1.11        8.05
               198504 |        217        1.43        9.48
               198505 |        276        1.82       11.30
               198506 |        271        1.78       13.08
               198507 |        345        2.27       15.35
               198508 |        480        3.16       18.51
               198509 |        757        4.99       23.50
               198510 |        849        5.59       29.09
               198511 |        850        5.60       34.69
               198512 |        995        6.55       41.24
               198600 |          6        0.04       41.28
               198601 |      1,094        7.21       48.49
               198602 |        936        6.16       54.65
               198603 |      1,015        6.69       61.34
               198604 |        932        6.14       67.48
               198605 |        962        6.34       73.81
               198606 |        884        5.82       79.64
               198607 |        955        6.29       85.93
               198608 |        805        5.30       91.23
               198609 |        515        3.39       94.62
               198610 |        327        2.15       96.77
               198611 |        246        1.62       98.39
               198612 |        136        0.90       99.29
               198700 |          8        0.05       99.34
               198701 |         21        0.14       99.48
               198702 |         14        0.09       99.57
               198703 |         15        0.10       99.67
               198704 |         11        0.07       99.74
               198705 |          6        0.04       99.78
               198706 |          7        0.05       99.83
               198707 |          6        0.04       99.87
               198708 |         11        0.07       99.94
               198709 |          4        0.03       99.97
               198710 |          1        0.01       99.97
               198711 |          3        0.02       99.99
               198712 |          1        0.01      100.00
          ------------+-----------------------------------
                Total |     15,183      100.00

              parents^ highest level of education |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |        942        6.16        6.16
                graduated from high school or ged |      3,044       19.89       26.05
                attended 2-year school, no degree |      1,663       10.87       36.91
                     graduated from 2-year school |      1,597       10.44       47.35
               attended college, no 4-year degree |      1,758       11.49       58.83
                           graduated from college |      3,466       22.65       81.48
          completed master^s degree or equivalent |      1,785       11.66       93.15
          completed phd, md, other advanced degre |      1,049        6.85      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,304      100.00

                        mother^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      1,935       12.65       12.65
                graduated from high school or ged |      4,117       26.91       39.55
                attended 2-year school, no degree |      1,849       12.08       51.64
                     graduated from 2-year school |      1,620       10.59       62.22
               attended college, no 4-year degree |      1,589       10.38       72.61
                           graduated from college |      2,820       18.43       91.04
          completed master^s degree or equivalent |      1,060        6.93       97.97
          completed phd, md, other advanced degre |        311        2.03      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,301      100.00

                        father^s highest level of |
                              education-composite |      Freq.     Percent        Cum.
          ----------------------------------------+-----------------------------------
                       did not finish high school |      2,039       13.34       13.34
                graduated from high school or ged |      4,314       28.23       41.57
                attended 2-year school, no degree |      1,438        9.41       50.97
                     graduated from 2-year school |      1,194        7.81       58.79
               attended college, no 4-year degree |      1,417        9.27       68.06
                           graduated from college |      2,735       17.89       85.95
          completed master^s degree or equivalent |      1,282        8.39       94.34
          completed phd, md, other advanced degre |        865        5.66      100.00
          ----------------------------------------+-----------------------------------
                                            Total |     15,284      100.00

                     Income |      Freq.     Percent        Cum.
          ------------------+-----------------------------------
                       none |         80        0.50        0.50
             $1,000 or less |        178        1.10        1.60
              $1,001-$5,000 |        304        1.88        3.48
             $5,001-$10,000 |        351        2.17        5.65
            $10,001-$15,000 |        697        4.31        9.96
            $15,001-$20,000 |        781        4.83       14.80
            $20,001-$25,000 |        996        6.16       20.96
            $25,001-$35,000 |      1,887       11.68       32.64
            $35,001-$50,000 |      3,017       18.67       51.31
            $50,001-$75,000 |      3,309       20.48       71.78
           $75,001-$100,000 |      2,173       13.45       85.23
          $100,001-$200,000 |      1,806       11.18       96.40
           $200,001 or more |        581        3.60      100.00
          ------------------+-----------------------------------
                      Total |     16,160      100.00

Nested Loops
------------

You can run loops within loops, which is actually a very powerful
function. Here's a simple example:

\texttt{forvalues i = 1/10 \{\\
              for values j =1/10 \{\\ 
            di ``This is outer loop, inner loop `i'''
            \} \\
            \} \\
             }

The motivating example on missing data uses a nested loop structure. The
outer loop consists of all of the variables, while the inner loop
iterates over the possible missing value codes (-4,-8,-9).

          . forvalues i =1/10 { /* Start outer loop */
          .   forvalues j = 1/10 { /* Start inner loop */
          .     di "This is outer loop `i', inner loop `j'"
          .                       } /* End inner loop */
          .                     } /* End outer loop */
          This is outer loop 1, inner loop 1
          This is outer loop 1, inner loop 2
          This is outer loop 1, inner loop 3
          This is outer loop 1, inner loop 4
          This is outer loop 1, inner loop 5
          This is outer loop 1, inner loop 6
          This is outer loop 1, inner loop 7
          This is outer loop 1, inner loop 8
          This is outer loop 1, inner loop 9
          This is outer loop 1, inner loop 10
          This is outer loop 2, inner loop 1
          This is outer loop 2, inner loop 2
          This is outer loop 2, inner loop 3
          This is outer loop 2, inner loop 4
          This is outer loop 2, inner loop 5
          This is outer loop 2, inner loop 6
          This is outer loop 2, inner loop 7
          This is outer loop 2, inner loop 8
          This is outer loop 2, inner loop 9
          This is outer loop 2, inner loop 10
          This is outer loop 3, inner loop 1
          This is outer loop 3, inner loop 2
          This is outer loop 3, inner loop 3
          This is outer loop 3, inner loop 4
          This is outer loop 3, inner loop 5
          This is outer loop 3, inner loop 6
          This is outer loop 3, inner loop 7
          This is outer loop 3, inner loop 8
          This is outer loop 3, inner loop 9
          This is outer loop 3, inner loop 10
          This is outer loop 4, inner loop 1
          This is outer loop 4, inner loop 2
          This is outer loop 4, inner loop 3
          This is outer loop 4, inner loop 4
          This is outer loop 4, inner loop 5
          This is outer loop 4, inner loop 6
          This is outer loop 4, inner loop 7
          This is outer loop 4, inner loop 8
          This is outer loop 4, inner loop 9
          This is outer loop 4, inner loop 10
          This is outer loop 5, inner loop 1
          This is outer loop 5, inner loop 2
          This is outer loop 5, inner loop 3
          This is outer loop 5, inner loop 4
          This is outer loop 5, inner loop 5
          This is outer loop 5, inner loop 6
          This is outer loop 5, inner loop 7
          This is outer loop 5, inner loop 8
          This is outer loop 5, inner loop 9
          This is outer loop 5, inner loop 10
          This is outer loop 6, inner loop 1
          This is outer loop 6, inner loop 2
          This is outer loop 6, inner loop 3
          This is outer loop 6, inner loop 4
          This is outer loop 6, inner loop 5
          This is outer loop 6, inner loop 6
          This is outer loop 6, inner loop 7
          This is outer loop 6, inner loop 8
          This is outer loop 6, inner loop 9
          This is outer loop 6, inner loop 10
          This is outer loop 7, inner loop 1
          This is outer loop 7, inner loop 2
          This is outer loop 7, inner loop 3
          This is outer loop 7, inner loop 4
          This is outer loop 7, inner loop 5
          This is outer loop 7, inner loop 6
          This is outer loop 7, inner loop 7
          This is outer loop 7, inner loop 8
          This is outer loop 7, inner loop 9
          This is outer loop 7, inner loop 10
          This is outer loop 8, inner loop 1
          This is outer loop 8, inner loop 2
          This is outer loop 8, inner loop 3
          This is outer loop 8, inner loop 4
          This is outer loop 8, inner loop 5
          This is outer loop 8, inner loop 6
          This is outer loop 8, inner loop 7
          This is outer loop 8, inner loop 8
          This is outer loop 8, inner loop 9
          This is outer loop 8, inner loop 10
          This is outer loop 9, inner loop 1
          This is outer loop 9, inner loop 2
          This is outer loop 9, inner loop 3
          This is outer loop 9, inner loop 4
          This is outer loop 9, inner loop 5
          This is outer loop 9, inner loop 6
          This is outer loop 9, inner loop 7
          This is outer loop 9, inner loop 8
          This is outer loop 9, inner loop 9
          This is outer loop 9, inner loop 10
          This is outer loop 10, inner loop 1
          This is outer loop 10, inner loop 2
          This is outer loop 10, inner loop 3
          This is outer loop 10, inner loop 4
          This is outer loop 10, inner loop 5
          This is outer loop 10, inner loop 6
          This is outer loop 10, inner loop 7
          This is outer loop 10, inner loop 8
          This is outer loop 10, inner loop 9
          This is outer loop 10, inner loop 10
          . use plans2, clear
          . svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

                pweight: bystuwt
                    VCE: linearized
            Single unit: scaled
               Strata 1: strat_id
                   SU 1: psu
                  FPC 1: <zero>
          . recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
          (13995 differences between f1psepln and newpln)
          . label var newpln "PS Plans"
          . label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
          . label values newpln newpln
          . recode bypared (1/2 = 1) (3/5 = 2) (6 = 3) (7/8 = 4) (. = .), gen(newpared)
          (14362 differences between bypared and newpared)
          . label var newpared "Parental Education"
          . label define newpared 1 "HS or Less" 2 "Less than 4yr" 3 "4 yr" 4 "Advanced"
          . label values newpared newpared
          . local ivars byrace2 newpared
          . erase plan_tab.$ttype // Delete the table (can't append and replace)
          . foreach ivar of local ivars{
          .         estpost svy: tabulate `ivar' newpln, row percent se
          .         eststo desc_`ivar'
          . esttab desc_`ivar' using plan_tab.$ttype, ///
               nostar ///
               nostar ///
               unstack ///
               nonotes ///
               varlabels(`e(labels)') ///
               eqlabels(`e(eqlabels)') ///
                   nomtitles ///
                   nonumbers ///
                   append

          .         } // end loop over variables 
          (running tabulate on estimation sample)

          Number of strata   =       361                  Number of obs     =     13,055
          Number of PSUs     =       750                  Population size   =  2,868,334
                                                          Design df         =        389

          --------------------------------------------------
          RECODE of |
          byrace    |
          (student^ |
          s         |
          race/ethn |
          icity-com |                PS Plans               
          posite)   | No plans  VoTech/C      4 yr     Total
          ----------+---------------------------------------
            Am.Ind. |    15.44     26.37     58.19       100
                    |  (3.492)   (4.184)   (5.404)          
                    | 
           Asian/PI |    4.704     23.77     71.52       100
                    |  (.8798)   (1.797)   (1.975)          
                    | 
              Black |    7.174     29.91     62.91       100
                    |  (.7508)    (1.36)   (1.486)          
                    | 
           Hispanic |    9.427     44.15     46.42       100
                    |  (.7945)   (1.482)   (1.683)          
                    | 
           Multirac |    11.64     30.48     57.87       100
                    |  (1.622)   (2.468)   (2.537)          
                    | 
              White |    8.077     28.19     63.73       100
                    |  (.3891)   (.8186)   (.9211)          
                    | 
              Total |     8.22     30.67     61.11       100
                    |  (.3214)   (.6345)   (.7321)          
          --------------------------------------------------
            Key:  row percentage
                  (linearized standard error of row percentage)

            Pearson:
              Uncorrected   chi2(10)        =  259.9747
              Design-based  F(9.08, 3530.88)=   18.5866     P = 0.0000

          Note: Variance scaled to handle strata with a single sampling unit.

          saved vectors:
                       e(b) =  row percentages
                      e(se) =  standard errors of row percentages
                      e(lb) =  lower 95% confidence bounds for row percentages
                      e(ub) =  upper 95% confidence bounds for row percentages
                    e(deff) =  deff for variances of row percentages
                    e(deft) =  deft for variances of row percentages
                    e(cell) =  cell percentages
                     e(row) =  row percentages
                     e(col) =  column percentages
                   e(count) =  weighted counts
                     e(obs) =  number of observations

          row labels saved in macro e(labels)
          (note: file plan_tab.rtf not found)
          (output written to `"plan_tab.rtf"') 
          (running tabulate on estimation sample)

          Number of strata   =       361                  Number of obs     =     13,109
          Number of PSUs     =       750                  Population size   =  2,868,334
                                                          Design df         =        389

          --------------------------------------------------
          Parental  |                PS Plans               
          Education | No plans  VoTech/C      4 yr     Total
          ----------+---------------------------------------
           HS or Le |    13.69      41.7      44.6       100
                    |  (.7395)   (1.086)   (1.151)          
                    | 
           Less tha |    8.928     35.35     55.73       100
                    |  (.5732)   (.9667)   (.9883)          
                    | 
               4 yr |    5.053     21.74     73.21       100
                    |  (.5192)   (.9942)   (1.049)          
                    | 
           Advanced |    2.851     16.56     80.59       100
                    |   (.427)   (1.094)   (1.155)          
                    | 
              Total |     8.22     30.67     61.11       100
                    |  (.3214)   (.6345)   (.7321)          
          --------------------------------------------------
            Key:  row percentage
                  (linearized standard error of row percentage)

            Pearson:
              Uncorrected   chi2(6)         = 1001.8604
              Design-based  F(5.79, 2253.30)=  101.7709     P = 0.0000

          Note: Variance scaled to handle strata with a single sampling unit.

          saved vectors:
                       e(b) =  row percentages
                      e(se) =  standard errors of row percentages
                      e(lb) =  lower 95% confidence bounds for row percentages
                      e(ub) =  upper 95% confidence bounds for row percentages
                    e(deff) =  deff for variances of row percentages
                    e(deft) =  deft for variances of row percentages
                    e(cell) =  cell percentages
                     e(row) =  row percentages
                     e(col) =  column percentages
                   e(count) =  weighted counts
                     e(obs) =  number of observations
          (output written to `"plan_tab.rtf"') 
          . }/* End analysis section */

          . else{
          . di "Did not run analysis"
          . }

Your best friend here is `set trace=on`. Also, I've found STATA's
foreach, forvalues commands to be really tricky. If you know that your
\`\`core'' code is running fine, the main problem with loops is probably
going to be in the syntax for your forvalues or foreach command.

It's also a really good idea to build in sanity checks if you're running
complex programs. Small mistakes can really compound when you're using
these powerful tools.

In Class Exercise
-----------------

Use the plans dataset. Create an algorithm that will convert a continous
variable into a series of binary variables, one dummy variable for each
quintile. Make sure the resulting binary variables are properly labeled.

Now, run this for every continuous variable in the dataset, using a loop
structure.

Bonus challenge: can you identify continuous variables programmatically?

          . exit
