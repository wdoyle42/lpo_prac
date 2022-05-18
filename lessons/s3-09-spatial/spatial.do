// Spatial Stats
// Will Doyle
// 2021-05-19

// ssc install shp2dta
// ssc install spmap
//ssc install mif2dta

// mqtime
// geodist
// geonear


/* 

Spatial Data Files

A spatial data file contains a unique identifier for each geography and a "shape" for that particular geography.
The shape consists of a series of points identifying the boundaries of each given geography. Let's take a look
at a spaital data file for all of the counties in the United States. 

The census bureau maintains a large and up-to-date set of spatial data files for almost every 
political geography,  including states, counties and cities. It also has its own special hierarchy, available here:

https://www2.census.gov/geo/pdfs/reference/geodiagram.pdf


*/

/* Let's grab th shapefile for counties and get it preppd*/

//Shapefile from:https://www.census.gov/cgi-bin/geo/shapefiles/index.php

unzipfile tl_2020_us_county.zip

// Convert to stata format 

spshape2dta tl_2020_us_county, replace

// Open up relevant data file

use tl_2020_us_county, clear

// generate correct id

/* It's unfortunantely almost always necessary to do some manipulation to get geographic identifiers
to work */

generate long fips = real(STATEFP +  COUNTYFP)

// Set for spatial data

spset fips, modify replace

// Set coord system and distances

spset, modify coordsys(latlong, miles)

// just TN
keep if STATEFP=="47"

save tl_2020_tn_county, replace

//

use tl_2020_tn_county, clear

merge 1:1 fips using county_stats.dta


spmap college_educ using tl_2020_us_county_shp , /// 
		id(_ID) 


spmap college_educ using tl_2020_us_county_shp , /// 
		id(_ID) ///
		clmethod(custom) clbreaks(0(10)100)  /// 
		fcolor(Terrain)  ///
		ocolor(white ..) osize(*0.15 ..)  ///
		ndocolor(black) ndfcolor(gs14) /// 
		ndlabel("No data")  ndsize(*0.15 ..)  ///
		legend(pos(8) size(*2)) legstyle(2)  ///
		point(data(inst) xcoord(longitud) ycoord(latitude) ///
		by(sector) fcolor(Set1) )
		

spmap income_75 using tl_2020_us_county_shp , /// 
		id(_ID) ///
		clmethod(custom) clbreaks(0(13)100)  /// 
		fcolor(PuBu)  ///
		ocolor(white ..) osize(*0.15 ..)  ///
		ndocolor(black) ndfcolor(gs14) /// 
		ndlabel("No data")  ndsize(*0.15 ..)  ///
		legend(pos(8) size(*2)) legstyle(2)  
						
// Spatial weight matrix

spmatrix create contiguity cont1, norm(none) replace

spmatrix summarize cont1		

spmatrix matafromsp W id = cont1

mata: st_matrix("W",W) 

mat li W	

// Spatial inverse distance  matrix	

spmatrix create idistance idist1

spmatrix summarize idist1	

spmatrix matafromsp D id = idist1

mata: st_matrix("D",D) 

mat li D	

		
// Point data

// zip code centroids

// https://www-nber-org.proxy.library.vanderbilt.edu/research/data/zip-code-distance-database

use gaz2016zcta5centroid.dta, clear		

rename zcta zip

save centroids.dta, replace

use inst.dta, clear

replace zip=substr(zip,1,5)

merge m:1 zip using centroids, keep(match)

// Distance from specified location
geodist latitud longitud intptlat intptlon, gen(v)

// Nearest neighbors

use inst.dta, clear

geonear unitid latitud longitud using centroids.dta, neighbors(zip intptlat intptlon) nearcount(10)


// Travel time

use inst.dta, clear

replace zip=substr(zip,1,5)

merge m:1 zip using centroids, keep(match)

mqtime, start_x(longitud) start_y(latitud) end_x(intptlon) end_y(intptlat)

//  inverse distance matrix

use inst.dta, clear

spset unitid, coord(longitud latitud) coordsys(latlong)

spmatrix create idistance W, replace norm(none)

spmatrix matafromsp W id = W

mata: st_matrix("output",W) 

svmat output


// https://www.census.gov/geographies/reference-files/2010/geo/relationship-files.html#par_textimage_674173622

insheet using "zip_county.csv", comma clear

keep if state==47

keep zcta5 state county geoid

rename zcta5 zip

format zip %9.0f 

collapse (first)  state county geoid ,by(zip)

save zip_county_tn, replace

use inst.dta , clear

destring zip, replace force

merge m:1 zip using zip_county_tn

keep instnm latitud longitud geoid

rename geoid fips

save inst2, replace


use tl_2020_tn_county, clear

merge 1:1 fips using county_stats.dta, nogen

merge 1:m fips using inst2, nogen




