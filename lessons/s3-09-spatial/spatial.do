// Spatial Stats
// Will Doyle
// 2021-05-19

ssc install shp2dta
ssc install spmap
ssc install mif2dta

//Shapefile from:https://www.census.gov/cgi-bin/geo/shapefiles/index.php

unzipfile tl_2020_us_county.zip

// Convert to stata format 

spshape2dta tl_2020_us_county, replace

// Open up relevant data file

use tl_2020_us_county, clear

// generate correct id

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
		legend(pos(7) size(*2)) legstyle(2)  
		
		
// Spatial weight matrix

spmatrix create contiguity cont1

spmatrix summarize cont1		
				
		
// Point data

// zip code centroids

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

spmatrix create idistance W in 1/5, replace norm(none)

spmatrix matafromsp W id = W

mata: st_matrix("output",W) 

svmat output

