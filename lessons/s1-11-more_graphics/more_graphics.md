More Graphics Options
---------------------

Today we'll go over a few more things you can do in creating
descriptives. We'll focus on categorical and binary data since many of
you are using categorical predictors.

          . capture log close                       // closes any logs, should they be open

          . set linesize 90

          . log using "more_graphics.log", replace    // open new log
          -----------------------------------------------------------------------------------------------
                name:  <unnamed>
                 log:  /Users/doylewr/lpo_prac/lessons/s1-11-more_graphics/more_graphics.log
            log type:  text
           opened on:  11 Nov 2020, 11:03:19

          . clear all                               // clear memory


          . set more off                            // turn off annoying "__more__" feature

          . global datadir "../data/"

          . global plotdir "../plots/"

          . global tabsdir "../tables/"

          . global gtype eps

          . global ttype html

          . set scheme s1color

          . use ../s1-10-programming/plans_b, clear

          . recode f1psepln (1=1 "No Plans") ///
                                           (2=2 "Don't Know'") ///
                                           (3=3 "Vo-tech") ///
                                           (4=4 "CC") ///
                                           (5=5 "4 yr") ///
                                           (6=6 "Early grad"), ///
                                           gen(f1psepln2)

          (0 differences between f1psepln and f1psepln2)

          . recode bystexp (-1=-1 "Don't Know") ///
                                           (1=1 "Less than HS") ///
                                           (2=2 "HS/GED") ///
                                           (3=3 "2 yr") ///
                                           (4=4 "4 yr/ not graduate") ///
                                           (5=5 "Bachelor's") ///
                                           (6=6 "Master's") ///
                                           (7=7 "PhD/Advanced"), ///                               
                                           gen(bystexp2)           

          (0 differences between bystexp and bystexp2)

          . la var bystexp2 " "                             

          . recode bysex(1=1 "Male") ///
                                   (2=2 "Female"), ///
                                   gen(bysex2)                             

          (0 differences between bysex and bysex2)

Catplot
-------

Catplot is an add-on function that's designed for plotting categorical
variables. If we do a basic catplot it would look like this:

          . catplot bystexp, name(cat1, replace)


          . graph export cat1.png, name(cat1) replace
          (file /Users/doylewr/lpo_prac/lessons/s1-11-more_graphics/cat1.png written in PNG format)

![](cat1.png)

<br> Where catplot can really come into its own is when using two
categorical variables, for example plotting expectations by sex.

          . catplot bystexp, over(bysex) name(cat2, replace) blabel(bar,format(%9.2f)) percent


          . graph export cat2.png, name(cat2) replace
          (file /Users/doylewr/lpo_prac/lessons/s1-11-more_graphics/cat2.png written in PNG format)

!()\[cat2.png\]

You can also include weights (here I'm using importance weights)

          . catplot bystexp2 [iw=bystuwt], over(bysex2) ///
                                           name(cat2, replace) ///
                                           blabel(bar,format(%9.1f)) ///
                                           percent ///
                                           ytitle("")  ///
                                           note("")



          . graph export expectations1.png  , replace       
          (file /Users/doylewr/lpo_prac/lessons/s1-11-more_graphics/expectations1.png written in PNG format)

The "yvars" trick
-----------------

If you use the options yvars, then you can individually manipulate each
different element of the bar graph.

          . catplot bystexp2, over(bysex2) ///                                 asyvars ///                                bar(1, bcolor(blue*.5)) ///                                bar(2, bcolor(yellow*.5)) ///                                bar(3, bcolor(green*.5)) ///                                bar(4, bcolor(orange*.5)) ///                                bar(5, bcolor(purple*.5)) ///                                bar(6, bcolor(gray*.5)) ///                                bar(7, bcolor(red*.5)) ///                                                              bar(8, bcolor(mint*.5)) ///                                percent ///                                name(yvars_cat,replace)

Schemes
-------

There are a wide variety of different schemes. Don't use Stata's default
scheme. Really. Please use anything else.

          . set scheme economist

          . catplot bystexp2, over(bysex2) ///                                 asyvars 



          . set scheme s1color                              

*Quick Exercise*

Create a catplot for plans by ses quartile, using asyvars

          . catplot bystexp2 , var1opts(sort(1) descending)


          . catplot bystexp , var1opts(sort(1) descending) asyvars


          . catplot bystexp2 , var1opts(sort(1) descending) recast(dot)


          . catplot f1psepln , over(bysex) var2opts(sort(1) descending) recast(dot) 

CI Plot
-------

CI plot is another add on that can be really useful. As advertised, it
plots confidence intervals around estimates.

          . ciplot bynels2m , by(bystexp2)


          . ciplot bynels2r, by(f1psepln) msymbol(circle) xlabel( , angle(45) labsize(vsmall)) ///                         ytitle(" Math Scores")  horiz 



          . cibar bynels2m, over1(bystexp2) over2(bysex2) ciopts(msize(*0)) 


          . local myvar f2ps1sec

          . foreach i of numlist -4 -8 -9 { /* Start inner loop */
          .                      replace `myvar'=. if `myvar'== `i'
          .                                             }  /* End inner loop */
          (1,689 real changes made, 1,689 to missing)
          (359 real changes made, 359 to missing)
          (49 real changes made, 49 to missing)

          . graph twoway scatter foury byses1               


          . xtile byses_p =byses1, nquantiles(100)

          . preserve

          . collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(byses_p)

          . graph twoway scatter mean_four byses_p [w=total_four], msymbol(circle_hollow) name(coll_attend)
          (analytic weights assumed)
          (analytic weights assumed)
          (analytic weights assumed)


          . restore 

          . gen twoyr =0 

          . replace twoyr=1 if f2ps1sec==4|f2ps1sec==5|f2ps1sec==6
          (3,688 real changes made)

          . replace twoyr=. if f2ps1sec==. 
          (2,097 real changes made, 2,097 to missing)

          . xtile bynels2m_p =bynels2m, nquantiles(100)

          . preserve

          . collapse (mean) mean_two=twoyr (count) total_two=twoyr, by(bynels2m_p)

          . graph twoway scatter mean_two bynels2m_p [w=total_two], msymbol(circle_hollow) name(coll_attend2,replace)
          (analytic weights assumed)
          (analytic weights assumed)
          (analytic weights assumed)


          . restore 

          . gen math2=round(bynels2m)
          (276 missing values generated)

          . preserve

          . collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(math2)

          . graph twoway scatter mean_four math2 [w=total_four], msymbol(circle_hollow) msize(*.5) name(coll_attend3, replace)
          (analytic weights assumed)
          (analytic weights assumed)
          (analytic weights assumed)


          . restore

          . gen read2=round(bynels2r)
          (276 missing values generated)

          . preserve

          . collapse (mean) mean_two=twoyr (count) total_two=twoyr, by(read2)

          . graph twoway scatter mean_two read2 [w=total_two], ///
                                   msymbol(circle_hollow) ///
                                   msize(*.5)  ///
                                   name(coll_attend3, replace) ///
                                   ytitle("Proportion Attending Two Year") ///
                                   xtitle("Reading Score (rounded)")

          (analytic weights assumed)
          (analytic weights assumed)
          (analytic weights assumed)


          . restore
