# this script gets the future Landsat acquisition dates for the EPSCoRBlooms lakes

library(rjson)
library(tidyverse)

lakes_meta = read.csv('EPSCoRBlooms_Lake_LS_Path_Row.csv')

#create temp folder
tmp = 'tmp/'
dir.create(tmp)

#point to landsat acq cycles json file
file = 'https://landsat.usgs.gov/sites/default/files/landsat_acq/assets/json/cycles_full.json'

#download json to tmp folder
download.file(file, destfile = file.path(tmp, 'datejson.json'))

#load json
datejson = fromJSON(file = file.path(tmp, 'datejson.json'))

unlink(tmp, recursive = T)

# LANDSAT 7 ----
ls7 <- datejson$landsat_7
ls7 <- as.data.frame(unlist(ls7)) %>% 
  rownames_to_column() %>% 
  filter(grepl('path', rowname))

datelist = unlist(strsplit(as.character(ls7$rowname), '\\.'))

ls7$date=as.Date(datelist[datelist != 'path'], '%m/%d/%Y')

colnames(ls7) = c('', 'PATH', 'date')

ls7 <- ls7[,2:3]  

ls7$sat = 'LS7'

# LANDSAT 8 ----
ls8 <- datejson$landsat_8
ls8 <- as.data.frame(unlist(ls8)) %>% 
  rownames_to_column() %>% 
  filter(grepl('path', rowname))

datelist = unlist(strsplit(as.character(ls8$rowname), '\\.'))

ls8$date=as.Date(datelist[datelist != 'path'], '%m/%d/%Y')

colnames(ls8) = c('', 'PATH', 'date')

ls8 <- ls8[,2:3]  

ls8$sat = 'LS8'

# LANDSAT 9 ----
ls9 <- datejson$landsat_9
ls9 <- as.data.frame(unlist(ls9)) %>% 
  rownames_to_column() %>% 
  filter(grepl('path', rowname))

datelist = unlist(strsplit(as.character(ls9$rowname), '\\.'))

ls9$date=as.Date(datelist[datelist != 'path'], '%m/%d/%Y')

colnames(ls9) = c('', 'PATH', 'date')

ls9 <- ls9[,2:3]  

ls9$sat = 'LS9'

#JOIN THE MISSIONS ----
acq_dates = full_join(ls7, ls8) %>% 
  full_join(., ls9)

dates_2022 = acq_dates %>% 
  filter(date >= as.Date('2022-01-01') & date < as.Date('2023-01-01'))

# GET OVERLAPPING DATES ----
for(i in 1:nrow(PRlist)){
  search = paste0(',', PRlist$PATH[i], ',')
  match = dates_2022[grepl(search, dates_2022$PATH),]
  match$path = PRlist$PATH[i]
  match = subset(match, select = -(PATH))
  if(i == 1){
    allmatches = match
  } else {
    allmatches = full_join(allmatches, match)
  }
}

allmatches <- allmatches %>% 
  rename(PATH = path)

# join with lakes metadata ----
LS_acq_2022 <- full_join(lakes_meta, allmatches) %>% 
  arrange(date) %>% 
  select(LakeName, LakeID, PATH, ROW, PR, pct_coverage, date, sat, OBJECTID, Permanent_, GNIS_Name) %>% 
  rename(acq_date = date)

write.csv(LS_acq_2022, 'EPSCoRBlooms_2022_LandsatAcquisitionSchedule.csv', row.names = F)
