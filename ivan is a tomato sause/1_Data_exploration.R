setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
require(data.table); require(bit64)

# samples <- fread('data/DSMDatathon_samplefile.txt', data.table = F, stringsAsFactors = F, 
#                colClasses = c('interger','interger','interger','interger','character','interger','interger',
#                               'character','character','character','character','character','character','character',
#                               'character','character','character','character','character','numeric','numeric',
                              # 'character','numeric','numeric'))

####################
### 1. Read Data ###
####################
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
dt_1[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 1)]
dt_2[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 2)]
dt_3[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 3)]
dt_4[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 4)]
dt_5[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(gsub(" *$", "", BID_TYP) == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(gsub(" *$", "", BID_TYP) == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 5)]

# 2.3 Merge Datasets
dt <- rbind(dt_1, dt_2, dt_3, dt_4, dt_5)
dim(dt_1); dim(dt_2); dim(dt_3); dim(dt_4); dim(dt_5); dim(dt)

# 2.4 Regular Expression
dt[, c('BID_TYP', 'STATUS_ID') := list(gsub(" *$", "", BID_TYP), gsub(" *$", "", STATUS_ID))]
str(dt)

# 2.5 Null values & Unique values
apply(dt, 2, function(x) mean(is.na(x)))
apply(dt, 2, function(x) length(unique(x)))

# 2.6 Imputation


# 2.7 Date Format Transformation


#################
### 3. Output ###
#################
save(dt, file = '../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')
