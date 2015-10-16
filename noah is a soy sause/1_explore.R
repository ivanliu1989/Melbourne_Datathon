##########################################################################
## 1. setup ##############################################################
##########################################################################
setwd("/Volumes/Data Science/Google Drive/data_science_competition/melbourne_datathon/Melbourne_Datathon/")
require(data.table)
require(bit64)

##########################################################################
## 2. read ###############################################################
##########################################################################
dt <- fread("data/DSMDatathon_samplefile.txt"
            , na.strings = c("NA", "")
            , colClasses = c("interger","interger","interger","interger","character","interger","interger",
                              "character","character","character","character","character","character","character",
                              "character","character","character","character","character","numeric","numeric",
                              "character","numeric","numeric"))

##########################################################################
## 3. inspect ############################################################
##########################################################################
View(dt)
## number of NAs
apply(dt
      , 2
      , function(x){sum(is.na(x))})
# MATCH_BET_ID 5755
# TAKEN_DATE 5755
# CANCELLED_DATE 18190
# PERSISTENCE_TYPE 22702
# PRICE_TAKEN 5755
# PROFIT_LOSS 5755

## number of unique values (a snap of the relationship among cols)
apply(dt
      , 2
      , function(x){length(unique(x))})
# BET_ID              BET_TRANS_ID              MATCH_BET_ID 
# 14479                      23691                     12359 
# ACCOUNT_ID COUNTRY_OF_RESIDENCE_NAME           PARENT_EVENT_ID 
# 2523                              19                         1 
# EVENT_ID                     MATCH                EVENT_NAME 
# 1                                1                         1 
# EVENT_DT                    OFF_DT                   BID_TYP 
# 1                                1                         2 
# STATUS_ID               PLACED_DATE                TAKEN_DATE 
# 3                              1419                      1133 
# SETTLED_DATE            CANCELLED_DATE            SELECTION_NAME 
# 1                                  913                         2 
# PERSISTENCE_TYPE                 BET_PRICE               PRICE_TAKEN 
# 2                                      274                       205 
# INPLAY_BET                  BET_SIZE               PROFIT_LOSS 
# 2                               5973                      7681
dim(dt)
