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
dt <- dt[order(dt$TRANSACTION_DATE,decreasing = TRUE),]
dt2 <- dt[dt$STATUS_ID=='S',]
dt2$FREQ_ID <- paste0(dt2$BET_ID, dt2$ACCOUNT_ID)
dt2$FREQ_ID <- paste0(ifelse(dt2$BID_TYP == 'B', dt2$BET_ID, dt2$MATCH_BET_ID), dt2$ACCOUNT_ID)
dates <- unique(dt$TRANSACTION_DATE)
source('ivan is a tomato sause/3_RFM_Model.R')

# newDF <- getRFMDataFrame(dt2, startDate="2014-12-16 15:55:43 AEDT" ,endDate="2015-03-21 07:33:44 AEDT", tIDColName="ACCOUNT_ID", tDateColName="TRANSACTION_DATE", tAmountColName="amounts")
# newDF2 <- getRFMIndependentScore(newDF, r=min(5, nrow(newDF)), f=min(5, nrow(newDF)), m=min(5, nrow(newDF)))
# # drawHistograms(newDF2, r=5, f=5, m=5)
# dat <- newDF2[,c(3, 4, 31:38)]
# write.csv(dat, file=paste0('RFM_overall.csv'))
# save(dat, file='RFM_overall.RData')

dat_all <- c()
for (d in as.character(dates)){
    newDF <- getRFMDataFrame(dt2, startDate=strptime(d,"%Y-%m-%d")-6*24*3600, endDate=strptime(d,"%Y-%m-%d"), tIDColName="ACCOUNT_ID", tDateColName="TRANSACTION_DATE", tAmountColName="amounts")
    newDF2 <- getRFMIndependentScore(newDF, r=min(5, nrow(newDF)), f=min(5, nrow(newDF)), m=min(5, nrow(newDF)))
    # drawHistograms(newDF2, r=5, f=5, m=5)
    dat <- newDF2[,c(3, 4, 31:38)]
    write.csv(dat, file=paste0('RFM_',d,'.csv'))
    dat_all <- rbind(dat_all, dat)
    print(d)
}
write.csv(dat_all, file=paste0('RFM_all.csv'))
save(dat_all, file='RFM_all.RData')

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
dt2 %>% group_by(ACCOUNT_ID) %>% 
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
load('data/RFM_all.RData')
library(googleVis)
dat_all$LAST_DATE <- as.Date(dat_all$LAST_DATE, '%Y-%m-%d')
data_all <- aggregate(ACCOUNT_ID ~ ACCOUNT_ID, data=dt, sum, na.action = na.omit)

Motion=gvisMotionChart(data = dat_all, idvar="COUNTRY_OF_RESIDENCE_NAME", timevar="LAST_DATE",
                       xvar='R_Score', yvar='F_Score',
                       sizevar='M_Score', colorvar="COUNTRY_OF_RESIDENCE_NAME", 
                       date.format = "%Y-%m-%d",
                       options=list(width=1200, height=600))
plot(Motion)
print(Motion,'chart',file='motionChart.html')
# x: frequency | y: recency | z: monetory