# this script gathers the WRS2 path-row combinations to download future Landsat acqiuistion dates

library(tidyverse)
library(sf)
library(terra)

# LOAD WRS2 DESCENDING GRID ----
wrs_grid <- st_read(file.path('shapefiles/WRS2/WRS2_descending.shp')) %>% 
  select(PATH, ROW, PR)

# LAKE FILES PROCESSING ----
me_lakes=read_sf(file.path('shapefiles/NHDLakeShapefiles.gdb'), 'me_lakes')
nh_lakes=read_sf(file.path('shapefiles/NHDLakeShapefiles.gdb'), 'nh_lakes')
ri_lakes=read_sf(file.path('shapefiles/NHDLakeShapefiles.gdb'), 'ri_lakes')
sc_lakes=read_sf(file.path('shapefiles/NHDLakeShapefiles.gdb'), 'sc_lakes')

epscor_lakes = rbind(me_lakes, nh_lakes) %>% 
  rbind(., ri_lakes) %>% 
  rbind(., sc_lakes) %>% 
  select(OBJECTID, Permanent_, GNIS_Name) 

epscor_lakes = st_transform(epscor_lakes,crs = 'EPSG:4326')

epscor_lakes$area_m2 = st_area(epscor_lakes)

epscor_lakes_meta = st_drop_geometry(epscor_lakes) %>% 
  select('OBJECTID', 'Permanent_', 'GNIS_Name', 'area_m2') %>% 
  mutate(LakeName = case_when(GNIS_Name == 'The Basin' ~ 'Lake Auburn',
                              GNIS_Name == 'Custer Pond' ~ 'Sabattus Pond',
                              GNIS_Name == 'Sunapee Lake' ~ 'Lake Sunapee',
                              GNIS_Name == 'Wateree Lake' ~ 'Lake Wateree',
                              TRUE ~ GNIS_Name),
         LakeID = case_when(LakeName == 'Lake Auburn' ~ 'AUB',
                            LakeName == 'Great Pond' ~ 'GRT',
                            LakeName == 'Long Pond' ~ 'LNG',
                            LakeName == 'Panther Pond' ~ 'PAN',
                            LakeName == 'Sabattus Pond' ~ 'SAB',
                            LakeName == 'China Lake' ~ 'CHN',
                            LakeName == 'Lake Sunapee' ~ 'SUN',
                            LakeName == 'Indian Lake' ~ 'IND',
                            LakeName == 'Yawgoo Pond' ~ 'YAW',
                            LakeName == 'Barber Pond' ~ 'BAR',
                            LakeName == 'Lake Murray' ~ 'MUR',
                            LakeName == 'Lake Wateree' ~ 'WAT',
                            TRUE ~ NA_character_)) 

# FILTER WRS2 GRID ----
WRS2_overlap = st_intersection(wrs_grid, epscor_lakes)

WRS2_overlap$area_m2_WRS = st_area(WRS2_overlap)

PR_EPSCoRBlooms = st_drop_geometry(WRS2_overlap) %>% 
  full_join(epscor_lakes_meta, .)

PR_EPSCoRBlooms <- PR_EPSCoRBlooms %>% 
  mutate(pct_coverage = (area_m2_WRS/area_m2)*100) 

write.csv(PR_EPSCoRBlooms, 'EPSCoRBlooms_Lake_LS_Path_Row.csv', row.names = F)

PRlist = PR_EPSCoRBlooms[!duplicated(PR_EPSCoRBlooms$PR),] %>% 
  select(PATH, ROW)

write.csv(PRlist, 'PRonly_for_download.csv', row.names = F)  
