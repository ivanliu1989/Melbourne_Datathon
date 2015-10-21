setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()
load('../Datathon_Full_Dataset/Datathon_WC_Data_Complete.RData')

################
### Measures ###
################ 1006045

# 0. RFM
# 4. Recency | lastest TRANSACTION_DATE - LAST_DATE
# 5. Frequency | count(distinct TRANSACTION_ID) group by ACCOUNT_ID
# 6. Monetary | average(BET_SIZE * PRICE_TAKEN/BET_PRICE) group by ACCOUNT_ID
# dt$amounts <- dt$PRICE_TAKEN * dt$BET_SIZE
dt$amounts <- abs(ifelse(dt$BID_TYP == "L", (dt$PRICE_TAKEN-1)*-dt$BET_SIZE, -dt$BET_SIZE))
dt$TRANSACTION_DATE <- strptime(format(dt$PLACED_DATE, "%d/%m/%Y"),"%d/%m/%Y")
dt <- dt[order(dt$TRANSACTION_DATE,decreasing = TRUE),]
dt <- dt[dt$STATUS_ID %in% c('S','C'),]
dt$FREQ_ID <- paste0(dt$BET_ID, dt$ACCOUNT_ID)
# dt2$FREQ_ID <- paste0(ifelse(dt2$BID_TYP == 'B', dt2$BET_ID, dt2$MATCH_BET_ID), dt2$ACCOUNT_ID)
dates <- unique(dt$TRANSACTION_DATE)
source('ivan is a tomato sause/3_RFM_Model.R')

newDF <- getRFMDataFrame(dt, startDate="2014-12-16 15:55:43 AEDT" ,endDate="2015-03-21 07:33:44 AEDT", tIDColName="ACCOUNT_ID", tDateColName="TRANSACTION_DATE", tAmountColName="amounts")
newDF2 <- getRFMIndependentScore(newDF, r=min(5, nrow(newDF)), f=min(5, nrow(newDF)), m=min(6, nrow(newDF)))
# drawHistograms(newDF2, r=5, f=5, m=5)
dat <- newDF2[,c(3, 4, 32:39)]
write.csv(dat, file=paste0('data/ivan_rfm/RFM_overall_seg.csv'))
save(dat, file='data/ivan_rfm/RFM_overall_seg.RData')

# Create bands
r_seg <- dat$Recency[order(dat$Recency, decreasing = F)]
f_seg <- dat$Frequency[order(dat$Frequency, decreasing = T)]
m_seg <- dat$Monetary[order(dat$Monetary, decreasing = T)]

# segments
dat$rfm <- ifelse(dat$Monetary<=100 & dat$Frequency <= 2, '9. Try Person',
                  ifelse(dat$Monetary>100 & dat$Frequency <= 2, '8. Event Focused Player',
                         ifelse(dat$Monetary<=100 & dat$Frequency <= 50, '7. Casual Entertainer',
                                ifelse(dat$Monetary<=1000 & dat$Frequency <= 50, '6. Frequent Gambler',
                                       ifelse(dat$Monetary>1000 & dat$Frequency <= 50, '3. Professional gambler',
                                              ifelse(dat$Monetary<=45 & dat$Frequency <= 500, '5. Opportunism',
                                                     ifelse(dat$Monetary<=290 & dat$Frequency <= 500, '4. Strategy Driven Gambler',
                                                            ifelse(dat$Monetary>290 & dat$Frequency <= 500, '3. Professional gambler',
                                                                   ifelse(dat$Monetary<=100 & dat$Frequency > 500, '2. Small Casual Group',
                                                                          ifelse(dat$Monetary>100 & dat$Frequency > 500, '1. Large Gambling Group or Business', 'None'))))))))))
seg_list <- dat[,c(1,11)]
save(dat, file='data/ivan_rfm/SEG_list.RData')

# 1. Large Gambling Group or Business               2. Small Casual Group             3. Professional gambler          4. Strategy Driven Gambler 
# 505                                 196                                2859                                1657 
# 5. Opportunism                 6. Frequent Gambler               7. Casual Entertainer             8. Event Focused Player 
# 892                                3312                                5946                                1298 
# 9. Try Person 
# 4309                                        

# dat_all <- c()
# for (d in as.character(dates)){
#     newDF <- getRFMDataFrame(dt2, startDate=strptime(d,"%Y-%m-%d")-6*24*3600, endDate=strptime(d,"%Y-%m-%d"), tIDColName="ACCOUNT_ID", tDateColName="TRANSACTION_DATE", tAmountColName="amounts")
#     newDF2 <- getRFMIndependentScore(newDF, r=min(5, nrow(newDF)), f=min(5, nrow(newDF)), m=min(5, nrow(newDF)))
#     # drawHistograms(newDF2, r=5, f=5, m=5)
#     dat <- newDF2[,c(3, 4, 31:38)]
#     write.csv(dat, file=paste0('RFM_',d,'_fix.csv'))
#     dat_all <- rbind(dat_all, dat)
#     print(d)
# }
# write.csv(dat_all, file=paste0('RFM_all_fix.csv'))
# save(dat_all, file='RFM_all_fix.RData')

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