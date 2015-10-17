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
dt_1[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(BID_TYP == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(BID_TYP == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 1)]
dt_2[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(BID_TYP == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(BID_TYP == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 2)]
dt_3[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(BID_TYP == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(BID_TYP == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 3)]
dt_4[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(BID_TYP == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(BID_TYP == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 4)]
dt_5[,c('PROFIT_LOSS_FIX','table_num') := list(ifelse(as.numeric(PROFIT_LOSS) > 0, ifelse(BID_TYP == "B", (as.numeric(PRICE_TAKEN)-1)*as.numeric(BET_SIZE), as.numeric(BET_SIZE)),0) + 
                                                   ifelse(as.numeric(PROFIT_LOSS) < 0, ifelse(BID_TYP == "L", (as.numeric(PRICE_TAKEN)-1)*-as.numeric(BET_SIZE), -as.numeric(BET_SIZE)),0), 5)]

# 2.3 Merge Datasets
dt <- rbind(dt_1, dt_2, dt_3, dt_4, dt_5)
dim(dt_1); dim(dt_2); dim(dt_3); dim(dt_4); dim(dt_5); dim(dt)
View(dt)

# 2.3 Null values & Unique values
apply(dt, 2, function(x) mean(is.na(x)))
# BET_ID              BET_TRANS_ID              MATCH_BET_ID                ACCOUNT_ID COUNTRY_OF_RESIDENCE_NAME           PARENT_EVENT_ID                  EVENT_ID 
# 0.0000000                 0.0000000                 0.1872992                 0.0000000                 0.0000000                 0.0000000                 0.0000000 
# MATCH                EVENT_NAME                  EVENT_DT                    OFF_DT                   BID_TYP                 STATUS_ID               PLACED_DATE 
# 0.0000000                 0.0000000                 0.0000000                 0.0000000                 0.0000000                 0.0000000                 0.0000000 
# TAKEN_DATE              SETTLED_DATE            CANCELLED_DATE            SELECTION_NAME          PERSISTENCE_TYPE                 BET_PRICE               PRICE_TAKEN 
# 0.1872992                 0.0000000                 0.8182610                 0.0000000                 0.9757013                 0.0000000                 0.1872992 
# INPLAY_BET                  BET_SIZE               PROFIT_LOSS           PROFIT_LOSS_FIX                 table_num 
# 0.0000000                 0.0000000                 0.1881458                 0.1881458                 0.0000000
apply(dt, 2, function(x) length(unique(x)))
# BET_ID              BET_TRANS_ID              MATCH_BET_ID                ACCOUNT_ID COUNTRY_OF_RESIDENCE_NAME           PARENT_EVENT_ID                  EVENT_ID 
# 2095220                   3461173                   1516071                     21020                        69                        44                        44 
# MATCH                EVENT_NAME                  EVENT_DT                    OFF_DT                   BID_TYP                 STATUS_ID               PLACED_DATE 
# 44                         1                        44                        44                         2                         4                    765423 
# TAKEN_DATE              SETTLED_DATE            CANCELLED_DATE            SELECTION_NAME          PERSISTENCE_TYPE                 BET_PRICE               PRICE_TAKEN 
# 499108                        88                    345605                        14                         2                       350                       350 
# INPLAY_BET                  BET_SIZE               PROFIT_LOSS           PROFIT_LOSS_FIX                 table_num 
# 2                    653641                   1136568                    795364                         5 

# 2.4 Imputation

#################
### 3. Output ###
#################
save(dt, file = '../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')