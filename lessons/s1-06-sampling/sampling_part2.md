Sampling II
================
LPO 9951 | Fall 2017

<br>

#### PURPOSE

In the last lecture, we discussed a number of ways to properly estimate the means and variances of complex survey designs. In this lecture, we'll discuss how to use Stata's internal `svy` commands and various variance estimation methods to more easily and correctly estimate what we want.

<br>

Complex survey designs: Cluster sampling and stratification
-----------------------------------------------------------

In the NCES surveys you'll be using this semester, the designers combined a design that includes multistage cluster sampling with stratification. In ECLS, for example, the designers designated counties as *PSUs*. They next stratified the sample by creating strata that combined census region with msa status, percent minority, and per capita income. They then randomly selected schools within each *PSU* (schools were the *SSUs*) and then randomly selected kindergarteners within each school (students were the *TSUs*). They then created two strata for each school with Asian and Pacific Islander students in one stratum and all other students in the other. Students were randomly sampled within this second stratum. The target number of children per school was 24.

Weights in complex survey designs such as the one employed with ECLS are calculated via the same that we discussed in the last lecture. Nothing changes except for the layers of complexity. The good news, however, is that we a researchers don't have to compute the weights ourselves. Instead, we can use information provided by the survey makers.

The *PSUs* that are provided by NCES are what is known as "analysis *PSUs*". They aren't the identifier for the actual school or student. Instead, they are allocated within strata (many times 2 *PSU* per strata). Strata themselves may be analysis strata, that is, not the same strata that were used to run the survey. Oftentimes, this is done in service of further protecting the anonimity of participants. As far your analyses go, the end result is the same, but sometimes this can be a source of confusion.

<br>

Variance estimation in complex survey designs
---------------------------------------------

There are four common options for estimating variance in complex survey designs:

1.  Taylor series linearized estimates
2.  Balanced repeated replication (BRR) estimates
3.  Jackknife estimates
4.  Bootstrap estimates

Remember that these are all estimates: you cannot directly compute the variance of quantities of interest from complex surveys. Instead, you must use one of these techniques, with trade-offs for each. We'll be using a couple of datasets for this lesson:

-   *nhanes*, which is a health survey conducted using a complex survey design that comes with a variety of weights
-   *nmihs\_bs*, which is a survey of births that comes with bootstrap replicate weights

Let's start with the *nhanes* dataset from which we'd like to get average height weight and age for the US population. First, let's get the naive estimate:

    . webuse nhanes2f, clear

    . // naive mean
    . mean age height weight

    Mean estimation                     Number of obs    =   10337

    --------------------------------------------------------------
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |    47.5637   .1693381      47.23177    47.89564
          height |   167.6512   .0950124       167.465    167.8375
          weight |   71.90088   .1510277      71.60484    72.19692
    --------------------------------------------------------------

<br>

We can also take a look at the sampling design, particularly the designation of strata and *PSUs*:

    . tab stratid psuid

       stratum |   primary sampling
    identifier |     unit, 1 or 2
        , 1-32 |         1          2 |     Total
    -----------+----------------------+----------
             1 |       215        165 |       380 
             2 |       118         67 |       185 
             3 |       199        149 |       348 
             4 |       231        229 |       460 
             5 |       147        105 |       252 
             6 |       167        131 |       298 
             7 |       270        206 |       476 
             8 |       179        158 |       337 
             9 |       143        100 |       243 
            10 |       143        119 |       262 
            11 |       120        155 |       275 
            12 |       170        144 |       314 
            13 |       154        188 |       342 
            14 |       205        200 |       405 
            15 |       189        191 |       380 
            16 |       177        159 |       336 
            17 |       180        213 |       393 
            18 |       144        215 |       359 
            20 |       158        125 |       283 
            21 |       102        111 |       213 
            22 |       173        128 |       301 
            23 |       182        158 |       340 
            24 |       202        232 |       434 
            25 |       139        115 |       254 
            26 |       132        129 |       261 
            27 |       144        139 |       283 
            28 |       135        163 |       298 
            29 |       287        215 |       502 
            30 |       166        199 |       365 
            31 |       143        165 |       308 
            32 |       239        211 |       450 
    -----------+----------------------+----------
         Total |     5,353      4,984 |    10,337 

<br>

We can use the weights supplied with *nhanes* to get accurate estimates of the means, but the variance estimates will be off:

    . mean age height weight [pw = finalwgt] 

    Mean estimation                     Number of obs    =   10337

    --------------------------------------------------------------
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   42.23732   .1617236      41.92031    42.55433
          height |   168.4625   .1139787      168.2391     168.686
          weight |   71.90869   .1802768      71.55532    72.26207
    --------------------------------------------------------------

<br>

`svyset` and `svy: <command>`
-----------------------------

To aid in the analysis of complex survey data, Stata has incorporated the `svyset` command and the `svy:` prefix, with its suite of commands. With `svyset`, you can set the *PSU* (and *SSU* and *TSU* if applicable), the weights, and the type of variance estimation along with the variance weights (if applicable). Once set, most Stata estimation commands such as `mean` can be combined with `svy:` in order to produce correct estimates.

<br>

Variance estimators
-------------------

### Taylor series linearized estimates

Taylor series linearized estimates are based on the general strategy of Taylor series estimation, which is used to linearize a non-linear function in order to describe the function in question. In this case, a Taylor series is used to approximate the function, and the variance of the result is the estimate of the variance.

The basic intuition behind a linearized estimate is that the variance in a complex survey will be a nonlinear function of the set of variances calculated within each stratum. We can calculate these, then use the first derivative of the function that would calculate the actual variance as a first order approximation of the actual variance. This works well enough in practice. To do this, you absolutely must have multiple *PSUs* in each stratum so you can calculate variance within each stratum.

This is the most common method and is used as the default by Stata. You must, however, have within-stratum variance among *PSUs* for this to work, which means that you must have at least two *PSUs* per stratum. This lonely PSU problem is common and difficult to deal with. We'll return the lonely PSU later.

To set up a dataset to use linearized estimates in Stata, we use the `svyset` command:

    . // set survey characteristics with svyset
    . svyset psuid [pweight = finalwgt], strata(stratid)

          pweight: finalwgt
              VCE: linearized
      Single unit: missing
         Strata 1: stratid
             SU 1: psuid
            FPC 1: <zero>

<br>

Now that we've set the data, every time we want estimates that reflect the sampling design, we use the `svy: <command>` format:

    . svy: mean age height weight
    (running mean on estimation sample)

    Survey: Mean estimation

    Number of strata =      31       Number of obs    =      10337
    Number of PSUs   =      62       Population size  =  117023659
                                     Design df        =         31

    --------------------------------------------------------------
                 |             Linearized
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   42.23732   .3034412      41.61844    42.85619
          height |   168.4625   .1471709      168.1624    168.7627
          weight |   71.90869   .1672315      71.56762    72.24976
    --------------------------------------------------------------

<br>

As you can see, the parameter estimates (means) are exactly the same as using the weighted sample, but the standard errors are quite different: nearly twice as large for age, but actually smaller for weight.

<br>

### Balanced repeated replication (BRR) estimates

In a balanced repeated replication (BRR) design, the quantity of interests is estimated repeatedly by using half the sample at a time. In a survey which is designed with BRR in mind, each sampling stratum contains two *PSUs*. BRR proceeds by estimating the quantity of interest from one of the *PSUs* within each stratum. For *H* strata, 2<sup>*H*</sup> replications are done, and the variance of the quantity of interest across these strata forms the basis for the estimate.

BRR weights are usually supplied with a survey. These weights result in appropriate half samples being formed across strata. BRR weights should generally be used when the sample was designed with them in mind, and not elsewhere. This can be a serious complication when survey data are subset.

To get variance estimates using BRR in stata, you either need to have a set of replicate weights set up or you need to create a set of balanced replicates yourself. If the data has BRR weights it's simple:

    . webuse nhanes2brr, clear

    . // svyset automagically
    . svyset

          pweight: finalwgt
              VCE: brr
              MSE: off
        brrweight: brr_1 brr_2 brr_3 brr_4 brr_5 brr_6 brr_7 brr_8 brr_9 brr_10 brr_11
                   brr_12 brr_13 brr_14 brr_15 brr_16 brr_17 brr_18 brr_19 brr_20 brr_21
                   brr_22 brr_23 brr_24 brr_25 brr_26 brr_27 brr_28 brr_29 brr_30 brr_31
                   brr_32
      Single unit: missing
         Strata 1: <one>
             SU 1: <observations>
            FPC 1: <zero>

    . // compute mean using svy pre-command and brr weights
    . svy: mean age height weight
    (running mean on estimation sample)

    BRR replications (32)
    ----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
    ................................

    Survey: Mean estimation          Number of obs    =      10351
                                     Population size  =  117157513
                                     Replications     =         32
                                     Design df        =         31

    --------------------------------------------------------------
                 |                 BRR
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   42.25264   .3013406      41.63805    42.86723
          height |   168.4599     .14663      168.1608    168.7589
          weight |   71.90064   .1656452       71.5628    72.23847
    --------------------------------------------------------------

<br>

If you don't have the data set up this way, you need to create a Hadamard with dimensions equal to the number of strata. Hadamard matrices are special in that they are square matrices comprised of 1s and -1s that arranged in such a way that each row and column sums to zero (equal numbers of ones and negative ones) and adjacent rows/columns are orthogonal (correlation of zero).

    . webuse nhanes2, clear

    . // create Hadamard matrix in Mata
    . mata: h2 = (1, 1 \ 1, -1)

    . mata: h4 = h2 # h2

    . mata: h8 = h2 # h4

    . mata: h16 = h2 # h8

    . mata: h32 = h2 # h16

    . // check row and column sums
    . mata: rowsum(h32)
             1
         +------+
       1 |  32  |
       2 |   0  |
       3 |   0  |
       4 |   0  |
       5 |   0  |
       6 |   0  |
       7 |   0  |
       8 |   0  |
       9 |   0  |
      10 |   0  |
      11 |   0  |
      12 |   0  |
      13 |   0  |
      14 |   0  |
      15 |   0  |
      16 |   0  |
      17 |   0  |
      18 |   0  |
      19 |   0  |
      20 |   0  |
      21 |   0  |
      22 |   0  |
      23 |   0  |
      24 |   0  |
      25 |   0  |
      26 |   0  |
      27 |   0  |
      28 |   0  |
      29 |   0  |
      30 |   0  |
      31 |   0  |
      32 |   0  |
         +------+

    . mata: colsum(h32)
            1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16
        +---------------------------------------------------------------------------------
      1 |  32    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0
        +---------------------------------------------------------------------------------
           17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32
         ---------------------------------------------------------------------------------+
      1     0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0  |
         ---------------------------------------------------------------------------------+

    . // save Mata matrix in Stata matrix form
    . mata: st_matrix("h32", h32)

<br>

Now that we've made our matrix, we can use it with the BRR command to get our estimates:

    . svy brr, hadamard(h32): mean age height weight 
    (running mean on estimation sample)

    BRR replications (32)
    ----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
    ................................

    Survey: Mean estimation

    Number of strata =      31       Number of obs    =      10351
    Number of PSUs   =      62       Population size  =  117157513
                                     Replications     =         32
                                     Design df        =         31

    --------------------------------------------------------------
                 |                 BRR
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   42.25264   .2779063      41.68585    42.81944
          height |   168.4599   .1411963      168.1719    168.7479
          weight |   71.90064   .1620071      71.57022    72.23105
    --------------------------------------------------------------

<br>

### Jackknife estimates

The Jackknife is a general strategy for variance estimation, so named by Tukey because of its general usefulness. The strategy for creating a jackknifed estimate is to delete every observation save one, then estimate the quantity of interest. This is repeated for every single observation in the dataset. The variance of every estimate computed provides an estimate of the variance for the quantity of interest.

In a complex sample, this is done by *PSUs*, deleting each *PSU* one at a time and re-weighting the observations within the stratum, then calculating the parameter of interest. The variance of these parameters estimates is the within-stratum variance estimate. The within stratum variances calculated this way are then averaged across strata to give the final variance estimate.

The jackknife is best used when Taylor series estimation cannot be done, for instance in the case of lonely *PSUs*.

In Stata, the command is:

    . webuse nhanes2jknife, clear

    . // set svyset using jackknife weigts
    . svyset [pweight = finalwgt], jkrweight(jkw_*) vce(jackknife)

          pweight: finalwgt
              VCE: jackknife
              MSE: off
        jkrweight: jkw_1 jkw_2 jkw_3 jkw_4 jkw_5 jkw_6 jkw_7 jkw_8 jkw_9 jkw_10 jkw_11
                   jkw_12 jkw_13 jkw_14 jkw_15 jkw_16 jkw_17 jkw_18 jkw_19 jkw_20 jkw_21
                   jkw_22 jkw_23 jkw_24 jkw_25 jkw_26 jkw_27 jkw_28 jkw_29 jkw_30 jkw_31
                   jkw_32 jkw_33 jkw_34 jkw_35 jkw_36 jkw_37 jkw_38 jkw_39 jkw_40 jkw_41
                   jkw_42 jkw_43 jkw_44 jkw_45 jkw_46 jkw_47 jkw_48 jkw_49 jkw_50 jkw_51
                   jkw_52 jkw_53 jkw_54 jkw_55 jkw_56 jkw_57 jkw_58 jkw_59 jkw_60 jkw_61
                   jkw_62
      Single unit: missing
         Strata 1: <one>
             SU 1: <observations>
            FPC 1: <zero>

<br>

Now we can compare the naive estimates with the `svyset` estimates:

    . mean age weight height

    Mean estimation                     Number of obs    =   10351

    --------------------------------------------------------------
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   47.57965   .1692044      47.24798    47.91133
          weight |   71.89752   .1509381      71.60165    72.19339
          height |   167.6509   .0949079      167.4648    167.8369
    --------------------------------------------------------------

    . // compute mean with jackknife weights
    . svy: mean age weight height
    (running mean on estimation sample)

    Jackknife replications (62)
    ----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
    ..................................................    50
    ............

    Survey: Mean estimation

    Number of strata =      31       Number of obs    =      10351
                                     Population size  =  117157513
                                     Replications     =         62
                                     Design df        =         31

    --------------------------------------------------------------
                 |              Jackknife
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
             age |   42.25264   .3026765      41.63533    42.86995
          weight |   71.90064   .1654453      71.56321    72.23806
          height |   168.4599   .1466141      168.1609    168.7589
    --------------------------------------------------------------

<br>

### Bootstrap estimates

The bootstrap is a more general method than the jackknife. Bootstrapping involves repeatedly resampling within the sample itself and generating estimates of the quantity of interest. The variance of these replications (usually many, many replications) provides an estimate of the total variance. In NCES surveys, within stratum bootstrapping can be used, with the sum of the variances obtained used as an estimate of the population variance. Bootstrapping is an accurate, but computationally intense method of variance estimation.

As with the jackknife, bootstrapping must be accomplished by deleting each *PSU* within the stratum one at a time, re-weighting, calculating the estimate, than calculating the bootstrap variance estimate from the compiled samples.

    . webuse nmihs_bs, clear

    . // svyset 
    . svyset idnum [pweight = finwgt], vce(bootstrap) bsrweight(bsrw*)

          pweight: finwgt
              VCE: bootstrap
              MSE: off
        bsrweight: bsrw1 bsrw2 bsrw3 bsrw4 bsrw5 bsrw6 bsrw7 bsrw8 bsrw9 bsrw10 bsrw11
                   bsrw12 bsrw13 bsrw14 bsrw15 bsrw16 bsrw17 bsrw18 bsrw19 bsrw20 bsrw21
                   bsrw22 bsrw23 bsrw24 bsrw25 bsrw26 bsrw27 bsrw28 bsrw29 bsrw30 bsrw31
                   bsrw32 bsrw33 bsrw34 bsrw35 bsrw36 bsrw37 bsrw38 bsrw39 bsrw40 bsrw41
                   bsrw42 bsrw43 bsrw44 bsrw45 bsrw46 bsrw47 bsrw48 bsrw49 bsrw50 bsrw51
                   bsrw52 bsrw53 bsrw54 bsrw55 bsrw56 bsrw57 bsrw58 bsrw59 bsrw60 bsrw61
                   bsrw62 bsrw63 bsrw64 bsrw65 bsrw66 bsrw67 bsrw68 bsrw69 bsrw70 bsrw71
                   bsrw72 bsrw73 bsrw74 bsrw75 bsrw76 bsrw77 bsrw78 bsrw79 bsrw80 bsrw81
                   bsrw82 bsrw83 bsrw84 bsrw85 bsrw86 bsrw87 bsrw88 bsrw89 bsrw90 bsrw91
                   bsrw92 bsrw93 bsrw94 bsrw95 bsrw96 bsrw97 bsrw98 bsrw99 bsrw100 bsrw101
                   bsrw102 bsrw103 bsrw104 bsrw105 bsrw106 bsrw107 bsrw108 bsrw109 bsrw110
                   bsrw111 bsrw112 bsrw113 bsrw114 bsrw115 bsrw116 bsrw117 bsrw118 bsrw119
                   bsrw120 bsrw121 bsrw122 bsrw123 bsrw124 bsrw125 bsrw126 bsrw127 bsrw128
                   bsrw129 bsrw130 bsrw131 bsrw132 bsrw133 bsrw134 bsrw135 bsrw136 bsrw137
                   bsrw138 bsrw139 bsrw140 bsrw141 bsrw142 bsrw143 bsrw144 bsrw145 bsrw146
                   bsrw147 bsrw148 bsrw149 bsrw150 bsrw151 bsrw152 bsrw153 bsrw154 bsrw155
                   bsrw156 bsrw157 bsrw158 bsrw159 bsrw160 bsrw161 bsrw162 bsrw163 bsrw164
                   bsrw165 bsrw166 bsrw167 bsrw168 bsrw169 bsrw170 bsrw171 bsrw172 bsrw173
                   bsrw174 bsrw175 bsrw176 bsrw177 bsrw178 bsrw179 bsrw180 bsrw181 bsrw182
                   bsrw183 bsrw184 bsrw185 bsrw186 bsrw187 bsrw188 bsrw189 bsrw190 bsrw191
                   bsrw192 bsrw193 bsrw194 bsrw195 bsrw196 bsrw197 bsrw198 bsrw199 bsrw200
                   bsrw201 bsrw202 bsrw203 bsrw204 bsrw205 bsrw206 bsrw207 bsrw208 bsrw209
                   bsrw210 bsrw211 bsrw212 bsrw213 bsrw214 bsrw215 bsrw216 bsrw217 bsrw218
                   bsrw219 bsrw220 bsrw221 bsrw222 bsrw223 bsrw224 bsrw225 bsrw226 bsrw227
                   bsrw228 bsrw229 bsrw230 bsrw231 bsrw232 bsrw233 bsrw234 bsrw235 bsrw236
                   bsrw237 bsrw238 bsrw239 bsrw240 bsrw241 bsrw242 bsrw243 bsrw244 bsrw245
                   bsrw246 bsrw247 bsrw248 bsrw249 bsrw250 bsrw251 bsrw252 bsrw253 bsrw254
                   bsrw255 bsrw256 bsrw257 bsrw258 bsrw259 bsrw260 bsrw261 bsrw262 bsrw263
                   bsrw264 bsrw265 bsrw266 bsrw267 bsrw268 bsrw269 bsrw270 bsrw271 bsrw272
                   bsrw273 bsrw274 bsrw275 bsrw276 bsrw277 bsrw278 bsrw279 bsrw280 bsrw281
                   bsrw282 bsrw283 bsrw284 bsrw285 bsrw286 bsrw287 bsrw288 bsrw289 bsrw290
                   bsrw291 bsrw292 bsrw293 bsrw294 bsrw295 bsrw296 bsrw297 bsrw298 bsrw299
                   bsrw300 bsrw301 bsrw302 bsrw303 bsrw304 bsrw305 bsrw306 bsrw307 bsrw308
                   bsrw309 bsrw310 bsrw311 bsrw312 bsrw313 bsrw314 bsrw315 bsrw316 bsrw317
                   bsrw318 bsrw319 bsrw320 bsrw321 bsrw322 bsrw323 bsrw324 bsrw325 bsrw326
                   bsrw327 bsrw328 bsrw329 bsrw330 bsrw331 bsrw332 bsrw333 bsrw334 bsrw335
                   bsrw336 bsrw337 bsrw338 bsrw339 bsrw340 bsrw341 bsrw342 bsrw343 bsrw344
                   bsrw345 bsrw346 bsrw347 bsrw348 bsrw349 bsrw350 bsrw351 bsrw352 bsrw353
                   bsrw354 bsrw355 bsrw356 bsrw357 bsrw358 bsrw359 bsrw360 bsrw361 bsrw362
                   bsrw363 bsrw364 bsrw365 bsrw366 bsrw367 bsrw368 bsrw369 bsrw370 bsrw371
                   bsrw372 bsrw373 bsrw374 bsrw375 bsrw376 bsrw377 bsrw378 bsrw379 bsrw380
                   bsrw381 bsrw382 bsrw383 bsrw384 bsrw385 bsrw386 bsrw387 bsrw388 bsrw389
                   bsrw390 bsrw391 bsrw392 bsrw393 bsrw394 bsrw395 bsrw396 bsrw397 bsrw398
                   bsrw399 bsrw400 bsrw401 bsrw402 bsrw403 bsrw404 bsrw405 bsrw406 bsrw407
                   bsrw408 bsrw409 bsrw410 bsrw411 bsrw412 bsrw413 bsrw414 bsrw415 bsrw416
                   bsrw417 bsrw418 bsrw419 bsrw420 bsrw421 bsrw422 bsrw423 bsrw424 bsrw425
                   bsrw426 bsrw427 bsrw428 bsrw429 bsrw430 bsrw431 bsrw432 bsrw433 bsrw434
                   bsrw435 bsrw436 bsrw437 bsrw438 bsrw439 bsrw440 bsrw441 bsrw442 bsrw443
                   bsrw444 bsrw445 bsrw446 bsrw447 bsrw448 bsrw449 bsrw450 bsrw451 bsrw452
                   bsrw453 bsrw454 bsrw455 bsrw456 bsrw457 bsrw458 bsrw459 bsrw460 bsrw461
                   bsrw462 bsrw463 bsrw464 bsrw465 bsrw466 bsrw467 bsrw468 bsrw469 bsrw470
                   bsrw471 bsrw472 bsrw473 bsrw474 bsrw475 bsrw476 bsrw477 bsrw478 bsrw479
                   bsrw480 bsrw481 bsrw482 bsrw483 bsrw484 bsrw485 bsrw486 bsrw487 bsrw488
                   bsrw489 bsrw490 bsrw491 bsrw492 bsrw493 bsrw494 bsrw495 bsrw496 bsrw497
                   bsrw498 bsrw499 bsrw500 bsrw501 bsrw502 bsrw503 bsrw504 bsrw505 bsrw506
                   bsrw507 bsrw508 bsrw509 bsrw510 bsrw511 bsrw512 bsrw513 bsrw514 bsrw515
                   bsrw516 bsrw517 bsrw518 bsrw519 bsrw520 bsrw521 bsrw522 bsrw523 bsrw524
                   bsrw525 bsrw526 bsrw527 bsrw528 bsrw529 bsrw530 bsrw531 bsrw532 bsrw533
                   bsrw534 bsrw535 bsrw536 bsrw537 bsrw538 bsrw539 bsrw540 bsrw541 bsrw542
                   bsrw543 bsrw544 bsrw545 bsrw546 bsrw547 bsrw548 bsrw549 bsrw550 bsrw551
                   bsrw552 bsrw553 bsrw554 bsrw555 bsrw556 bsrw557 bsrw558 bsrw559 bsrw560
                   bsrw561 bsrw562 bsrw563 bsrw564 bsrw565 bsrw566 bsrw567 bsrw568 bsrw569
                   bsrw570 bsrw571 bsrw572 bsrw573 bsrw574 bsrw575 bsrw576 bsrw577 bsrw578
                   bsrw579 bsrw580 bsrw581 bsrw582 bsrw583 bsrw584 bsrw585 bsrw586 bsrw587
                   bsrw588 bsrw589 bsrw590 bsrw591 bsrw592 bsrw593 bsrw594 bsrw595 bsrw596
                   bsrw597 bsrw598 bsrw599 bsrw600 bsrw601 bsrw602 bsrw603 bsrw604 bsrw605
                   bsrw606 bsrw607 bsrw608 bsrw609 bsrw610 bsrw611 bsrw612 bsrw613 bsrw614
                   bsrw615 bsrw616 bsrw617 bsrw618 bsrw619 bsrw620 bsrw621 bsrw622 bsrw623
                   bsrw624 bsrw625 bsrw626 bsrw627 bsrw628 bsrw629 bsrw630 bsrw631 bsrw632
                   bsrw633 bsrw634 bsrw635 bsrw636 bsrw637 bsrw638 bsrw639 bsrw640 bsrw641
                   bsrw642 bsrw643 bsrw644 bsrw645 bsrw646 bsrw647 bsrw648 bsrw649 bsrw650
                   bsrw651 bsrw652 bsrw653 bsrw654 bsrw655 bsrw656 bsrw657 bsrw658 bsrw659
                   bsrw660 bsrw661 bsrw662 bsrw663 bsrw664 bsrw665 bsrw666 bsrw667 bsrw668
                   bsrw669 bsrw670 bsrw671 bsrw672 bsrw673 bsrw674 bsrw675 bsrw676 bsrw677
                   bsrw678 bsrw679 bsrw680 bsrw681 bsrw682 bsrw683 bsrw684 bsrw685 bsrw686
                   bsrw687 bsrw688 bsrw689 bsrw690 bsrw691 bsrw692 bsrw693 bsrw694 bsrw695
                   bsrw696 bsrw697 bsrw698 bsrw699 bsrw700 bsrw701 bsrw702 bsrw703 bsrw704
                   bsrw705 bsrw706 bsrw707 bsrw708 bsrw709 bsrw710 bsrw711 bsrw712 bsrw713
                   bsrw714 bsrw715 bsrw716 bsrw717 bsrw718 bsrw719 bsrw720 bsrw721 bsrw722
                   bsrw723 bsrw724 bsrw725 bsrw726 bsrw727 bsrw728 bsrw729 bsrw730 bsrw731
                   bsrw732 bsrw733 bsrw734 bsrw735 bsrw736 bsrw737 bsrw738 bsrw739 bsrw740
                   bsrw741 bsrw742 bsrw743 bsrw744 bsrw745 bsrw746 bsrw747 bsrw748 bsrw749
                   bsrw750 bsrw751 bsrw752 bsrw753 bsrw754 bsrw755 bsrw756 bsrw757 bsrw758
                   bsrw759 bsrw760 bsrw761 bsrw762 bsrw763 bsrw764 bsrw765 bsrw766 bsrw767
                   bsrw768 bsrw769 bsrw770 bsrw771 bsrw772 bsrw773 bsrw774 bsrw775 bsrw776
                   bsrw777 bsrw778 bsrw779 bsrw780 bsrw781 bsrw782 bsrw783 bsrw784 bsrw785
                   bsrw786 bsrw787 bsrw788 bsrw789 bsrw790 bsrw791 bsrw792 bsrw793 bsrw794
                   bsrw795 bsrw796 bsrw797 bsrw798 bsrw799 bsrw800 bsrw801 bsrw802 bsrw803
                   bsrw804 bsrw805 bsrw806 bsrw807 bsrw808 bsrw809 bsrw810 bsrw811 bsrw812
                   bsrw813 bsrw814 bsrw815 bsrw816 bsrw817 bsrw818 bsrw819 bsrw820 bsrw821
                   bsrw822 bsrw823 bsrw824 bsrw825 bsrw826 bsrw827 bsrw828 bsrw829 bsrw830
                   bsrw831 bsrw832 bsrw833 bsrw834 bsrw835 bsrw836 bsrw837 bsrw838 bsrw839
                   bsrw840 bsrw841 bsrw842 bsrw843 bsrw844 bsrw845 bsrw846 bsrw847 bsrw848
                   bsrw849 bsrw850 bsrw851 bsrw852 bsrw853 bsrw854 bsrw855 bsrw856 bsrw857
                   bsrw858 bsrw859 bsrw860 bsrw861 bsrw862 bsrw863 bsrw864 bsrw865 bsrw866
                   bsrw867 bsrw868 bsrw869 bsrw870 bsrw871 bsrw872 bsrw873 bsrw874 bsrw875
                   bsrw876 bsrw877 bsrw878 bsrw879 bsrw880 bsrw881 bsrw882 bsrw883 bsrw884
                   bsrw885 bsrw886 bsrw887 bsrw888 bsrw889 bsrw890 bsrw891 bsrw892 bsrw893
                   bsrw894 bsrw895 bsrw896 bsrw897 bsrw898 bsrw899 bsrw900 bsrw901 bsrw902
                   bsrw903 bsrw904 bsrw905 bsrw906 bsrw907 bsrw908 bsrw909 bsrw910 bsrw911
                   bsrw912 bsrw913 bsrw914 bsrw915 bsrw916 bsrw917 bsrw918 bsrw919 bsrw920
                   bsrw921 bsrw922 bsrw923 bsrw924 bsrw925 bsrw926 bsrw927 bsrw928 bsrw929
                   bsrw930 bsrw931 bsrw932 bsrw933 bsrw934 bsrw935 bsrw936 bsrw937 bsrw938
                   bsrw939 bsrw940 bsrw941 bsrw942 bsrw943 bsrw944 bsrw945 bsrw946 bsrw947
                   bsrw948 bsrw949 bsrw950 bsrw951 bsrw952 bsrw953 bsrw954 bsrw955 bsrw956
                   bsrw957 bsrw958 bsrw959 bsrw960 bsrw961 bsrw962 bsrw963 bsrw964 bsrw965
                   bsrw966 bsrw967 bsrw968 bsrw969 bsrw970 bsrw971 bsrw972 bsrw973 bsrw974
                   bsrw975 bsrw976 bsrw977 bsrw978 bsrw979 bsrw980 bsrw981 bsrw982 bsrw983
                   bsrw984 bsrw985 bsrw986 bsrw987 bsrw988 bsrw989 bsrw990 bsrw991 bsrw992
                   bsrw993 bsrw994 bsrw995 bsrw996 bsrw997 bsrw998 bsrw999 bsrw1000
      Single unit: missing
         Strata 1: <one>
             SU 1: idnum
            FPC 1: <zero>

    . // convert birth weight grams to lbs for the Americans
    . gen birthwgtlbs = birthwgt * 0.0022046
    (7 missing values generated)

    . // compute naive mean birthweight
    . mean birthwgtlbs

    Mean estimation                     Number of obs    =    9946

    --------------------------------------------------------------
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
     birthwgtlbs |   6.272294   .0217405      6.229678     6.31491
    --------------------------------------------------------------

    . // compute mean with svy bootstrap
    . svy: mean birthwgtlbs
    (running mean on estimation sample)

    Bootstrap replications (1000)
    ----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
    ..................................................    50
    ..................................................   100
    ..................................................   150
    ..................................................   200
    ..................................................   250
    ..................................................   300
    ..................................................   350
    ..................................................   400
    ..................................................   450
    ..................................................   500
    ..................................................   550
    ..................................................   600
    ..................................................   650
    ..................................................   700
    ..................................................   750
    ..................................................   800
    ..................................................   850
    ..................................................   900
    ..................................................   950
    ..................................................  1000

    Survey: Mean estimation            Number of obs    =     9946
                                       Population size  =  3895562
                                       Replications     =     1000

    --------------------------------------------------------------
                 |   Observed   Bootstrap         Normal-based
                 |       Mean   Std. Err.     [95% Conf. Interval]
    -------------+------------------------------------------------
     birthwgtlbs |    7.39743   .0143754      7.369255    7.425606
    --------------------------------------------------------------

<br>

Lonely *PSUs*
-------------

The most common problem that students have with complex surveys is what is known as "lonely *PSUs*." When you subset the data, you may very well end up with a sample that does not have mutliple *PSUs* per stratum. There are several options for what do in this case:

-   Eliminate the offending data by dropping strata with singleton *PSUs*. This is a terrible idea.
-   Reassign the *PSU* to a neighboring stratum. This is okay, but you must have a reason why you're doing this.
-   Assign a variance to the stratum with a singleton *PSU*. This could be the average of the variance across the other strata. This process is also known as "scaling" and generally is okat, but you should take a look at how different this stratum is from the others before proceeding.

The svyset command includes three possible options for dealing with loney *PSUs*. Based on the above, I recommend you use the `singleunit(scaled)` command, but with caution and full knowledge of the implications for your estimates.

<br> <br>

*Init: 23 August 2015; Updated: 09 October 2017*

<br>
