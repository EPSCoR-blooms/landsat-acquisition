# landsat-acquisition
gathering future Landsat acquisition dates for the EPSCoR Blooms lakes

scripts by B. Steele (steeleb@caryinstitute.org)

## Output files

'EPSCoRBlooms_2022_LandsatAcquisitionSchedule.csv' is the primary output for this repository. It lists all 2022 LS7-9 acquisition dates for the EPSCoRBloooms lakes

Column Definitions

|   Column Name |   Definition  |   Units   |   Notes   |
|   ----    |   ----    |   ----    |   ----    |
|   LakeName |  Common name of the waterbody, as used in this project   |   character string    |   |
|   LakeID  |   Short 3-letter idenitity of the lake, as used in this project   |   character string    |   |
|   PATH    |   WRS path number that the lake falls in  |   numberic    |   |
|   ROW |   WRS row number that the lake falls in   |   numeric|    |
|	PR  |   Landsat path-row value  |   character string    |  3-digit path number followed by 3-digit row number |
|   pct_coverage    |   approximate coverage of the LS path-row for the lake |  numeric, percent    |   if coverage is less than 99%, at least some portion of the lake will not be obtained by imagery |
|	acq_date    |	date of planned acquisition |   yyyy-mm-dd  |   |
|   sat	    |   satellite mission obtaining data    |   character string    |   LS7, LS8, LS9; LS7 has been decommissioned as of April 2022, data may not be valid after that date  |
|   OBJECTID	| ArcGIS identifier from the shapefiles in the provided .gdb    |   numeric |   |
|   Permanent_	|   NHD Permanent ID provided by the USGS NHD Best Resolution dataset   |   alpha-numeric string    |   aka NHDID, PermID   |
|   GNIS_Name	|   Name of the waterbody, as stored in the NHD |   character string    |   this may not be the same as the common name of the lake |


## Workflow:
- get_pathrow.R: this script uses the WRS2 descending (daytime) dataset from the USGS to find overlapping path-rows for the EPSCoRBlooms lakes using the NHDShapefiles from the USGS NHD Best Resolution dataset. 
- grab_landsat_dates.R: this script gets all LS7-LS9 acqusition dates for 2022. 


## Additional folders and files:

- shapefiles
    - WRS2 downloaded from https://www.usgs.gov/media/files/landsat-wrs-2-descending-path-row-shapefile 28Jun2022
    - NHD file is a copy of the NHD file in the DartFS system. 