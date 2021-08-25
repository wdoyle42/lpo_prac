          . version 16 /* Can set version here, use version 13 as default */

          . capture log close /* Closes any logs, should they be open */

          . log using "introduction.log",replace /*Open up new log */ 
          ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                name:  <unnamed>
                 log:  /Users/doylewr/lpo_prac/lessons/s1-01-introduction/introduction.log
            log type:  text
           opened on:  25 Aug 2021, 10:39:03

          . clear

          . clear mata // Clears any fluff that might be in mata 

          . estimates clear // Clears any estimates hanging around 

          . set more off // Get rid of annoying "more" feature 

          . set scheme s1color // My  preferred graphics scheme 

          . use ad, clear    /*filename of dataset */

statistical
areas\](https://www.census.gov/programs-surveys/metro-micro/about.html\#:\~:text=The%20general%20concept%20of%20a,social%20integration%20with%20that%20core.)
in the United States. It includes characteristics of these areas,
include education, i ncome, home ownership and others as described
below.

  ---------
  Name Desc
       ript
       ion
  ---- ----
  name Name
       of
       Micr
       o/Me
       tro
       Area

  coll Perc
  ege\ ent
  _edu of
  c    popu
       lati
       on
       with
       at
       leas
       t
       a
       bach
       elor
       's
       degr
       ee

  perc Perc
  \_co ent
  mmut of
  e\_3 popu
  0p   lati
       on
       with
       comm
       ute
       to
       work
       of
       30
       minu
       tes
       or
       more

  perc Perc
  \_in ent
  sure of
  d    popu
       lati
       on
       with
       heal
       th
       insu
       ranc
       e

  perc Perc
  \_ho ent
  meow of
  n    hous
       ing
       unit
       s
       owne
       d
       by
       occu
       pier

  geoi Geog
  d    raph
       ic
       FIPS
       Code
       (id)

  inco Perc
  me\_ ent
  75   of
       popu
       lati
       on
       with
       inco
       me
       over
       75,0
       00

  perc Perc
  \_mo ent
  ved\ of
  _in  popu
       lati
       on
       that
       move
       d
       from
       anot
       her
       stat
       e
       in
       last
       year

  perc Perc
  \_in ent
  \_la of
  bor  popu
  forc lati
  e    on
       in
       labo
       r
       forc
       e

  metr Metr
  o    opol
       itan
       Area
       ?
       Yes/
       No

  stat Stat
  e    e
       Abbr
       evia
       tion

  regi Cens
  on   us
       Regi
       on

  divi Cens
  sion us
       Divi
       sion
  ---------

          . exit
