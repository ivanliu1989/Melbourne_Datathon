setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')

################
### Measures ###
################

# 0. RFM
# 4. Recency | lastest TRANSACTION_DATE - LAST_DATE
# 5. Frequency | count(distinct TRANSACTION_ID) group by ACCOUNT_ID
# 6. Monetary | average(BET_SIZE * PRICE_TAKEN/BET_PRICE) group by ACCOUNT_ID
dt$amounts <- dt$PRICE_TAKEN * dt$BET_SIZE
dt$TRANSACTION_DATE <- strptime(format(dt$PLACED_DATE, "%d/%m/%Y"),"%d/%m/%Y")
dates <- unique(dt$TRANSACTION_DATE)
source('ivan is a tomato sause/3_RFM_Model.R')

dat_all <- c()
for (d in as.character(dates)){
    newDF <- getRFMDataFrame(dt, startDate=min(dates), endDate=strptime(d,"%Y-%m-%d"), tIDColName="ACCOUNT_ID", tDateColName="PLACED_DATE", tAmountColName="amounts")
    newDF2 <- getRFMIndependentScore(newDF, r=5, f=5, m=5)
    # drawHistograms(newDF2, r=5, f=5, m=5)
    dat <- newDF2[,c(3, 4, 31:38)]
    write.csv(dat, file=paste0('RFM_',d,'.csv'))
    dat_all <- rbind(dat_all, dat)
    print(d)
}


# 1. Rate of loss | count(distinct BET_ID) group by ACCOUNT_ID, PROFIT_LOSS (-)
# 2. Prob of profit | count(distinct BET_ID) group by ACCOUNT_ID, PROFIT_LOSS (+)
# 3. Net profit	| sum(PROFIT_LOSS) group by ACCOUNT_ID
# Exclude dates 
library(dplyr)
dt2 <- tbl_df(dt[, -c(8,9,12:15)])
glimpse(dt2)
distinct(dt2)

dt2 %>% group_by(ACCOUNT_ID) %>% 
    summarise(bet_num=length(unique(BET_ID)),
              win_num=length(unique(BET_ID[PROFIT_LOSS>0])),
              loss_num=length(unique(BET_ID[PROFIT_LOSS<0])),
              net_profit=sum(PROFIT_LOSS))
# loss_profit <- aggregate(PROFIT_LOSS ~ ACCOUNT_ID, data=dt, sum, na.action = na.omit)

# 7. Bet Prices | BET_PRICE / PRICE_TAKEN
dt2 %>% group_by(ACCOUNT_ID, ) %>% 
    summarise(odds_mean=mean(BET_PRICE),
              odds_med=median(BET_PRICE))

# 8. Buy inverval | TAKEN_DATE - PLACED_DATE
dt2 %>% group_by(ACCOUNT_ID) %>% 
    summarise(odds_mean=mean(BET_PRICE),
              odds_med=median(BET_PRICE))

##################
### Dimensions ###
##################
# 1. Location
# 2. Event
# 3. Status -> cancel -> reason of cancel (too large bet_size, cstr segments)
# 4. Inplay
# 5. Hour, Month, Weekdays


################
### Segments ###
################
# 1. RFM
# 2. Clustering
# 3. PCA/2-dim scatter plot


#############
### Plots ###
#############