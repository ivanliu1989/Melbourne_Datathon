##########################################################################
## 1. setup ##############################################################
##########################################################################
## thanks to Ivan!
rm(list = ls()); gc()
require(data.table)
setwd("/Volumes/Data Science/Google Drive/data_science_competition/melbourne_datathon/Melbourne_Datathon/")

##########################################################################
## 2. prepare, ref:ivan ##################################################
##########################################################################
## ivan is the data science god! #######
system("ls ../Datathon_Full_Dataset/")
system("head ../Datathon_Full_Dataset/*.csv")

colClasses <- c(rep('interger',4),'character',rep('interger',2),rep('character',12),rep('numeric',2),'character',rep('numeric',2))
dt_1 <- fread('../Datathon_Full_Dataset/Datathon WC Data Games 1-10.csv', colClasses=colClasses, na.strings = c("NA","N/A",""))
dt_2 <- fread('../Datathon_Full_Dataset/Datathon WC Data Games 11-20.csv', colClasses=colClasses, na.strings = c("NA","N/A",""))
dt_3 <- fread('../Datathon_Full_Dataset/Datathon WC Data Games 21-30.csv', colClasses=colClasses, na.strings = c("NA","N/A",""))
dt_4 <- fread('../Datathon_Full_Dataset/Datathon WC Data Games 31-40.csv', colClasses=colClasses, na.strings = c("NA","N/A",""))
dt_5 <- fread('../Datathon_Full_Dataset/Datathon WC Data Games QTR Finals.csv',colClasses=colClasses, na.strings = c("NA","N/A",""))

########################
### 2. Data Cleasing ###
########################
# 2.1 Clean up column names
identical(names(dt_1), names(dt_3))
setnames(dt_1, names(dt_1), c('BET_ID', names(dt_1)[-1]))
setnames(dt_2, names(dt_2), c('BET_ID', names(dt_2)[-1]))
setnames(dt_3, names(dt_3), c('BET_ID', names(dt_3)[-1]))
setnames(dt_4, names(dt_4), c('BET_ID', names(dt_4)[-1]))
setnames(dt_5, names(dt_5), c('BET_ID', names(dt_5)[-1]))
str(dt_1)

# 2.2 Fix PROFIT_LOSS Calc
dt_1[,c('PROFIT_LOSS','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                               ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 1)]
dt_2[,c('PROFIT_LOSS','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                               ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 2)]
dt_3[,c('PROFIT_LOSS','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                               ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 3)]
dt_4[,c('PROFIT_LOSS','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                               ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 4)]
dt_5[,c('PROFIT_LOSS','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                               ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 5)]

# 2.3 Merge Datasets
dt <- rbind(dt_1, dt_2, dt_3, dt_4, dt_5)
dim(dt_1); dim(dt_2); dim(dt_3); dim(dt_4); dim(dt_5); dim(dt)

# 2.4 Regular Expression
dt[, c('BID_TYP', 'STATUS_ID') := 
       list(gsub(" *$", "", BID_TYP), gsub(" *$", "", STATUS_ID))]
str(dt)
## ivan is the data science god! #######


dt <- data.table(dt)
##########################################################################
## 3. inspect ############################################################
##########################################################################
head(dt)
tail(dt)
str(dt)
dim(dt)
# [1] 3461173      26

require(sqldf)
dt_successTrans <- sqldf("SELECT * FROM dt A JOIN dt B ON A.BET_ID = B.MATCH_BET_ID AND A.MATCH_BET_ID = B.BET_ID")
