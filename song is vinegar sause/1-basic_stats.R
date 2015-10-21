setwd('C:/Users/InfoCentric/desktop/datathon/datathon full dataset')
library(sqldf)
library(data.table)
library(gdata)
library(rpart)
library(rpart.plot)
library(randomForest)
library(ggplot2)
data1 <- read.csv('Datathon WC Data Games 1-10.csv', sep=',', header =T)
data2 <- read.csv('Datathon WC Data Games 11-20.csv', sep=',', header =T)
data3 <- read.csv('Datathon WC Data Games 21-30.csv', sep=',', header =T)
data4 <- read.csv('Datathon WC Data Games 31-40.csv', sep=',', header =T)
data_final <- read.csv('Datathon WC Data Games QTR Finals.csv', sep=',', header =T)

trans <- rbind(data1, data2,data3,data4, data_final)
names(trans)[1] <- 'BET_ID'
rm(data1)
rm(data2)
rm(data3)
rm(data4)
rm(data_final)


# trim the space for character(factor) variables
dt <- lapply(trans, function(x) { if (!is.numeric(x) )trim(x) else x })
dt <- data.frame(dt)
dt <- data.table(dt)

## list the number of distinct values for each colmns
lapply(dt, function(x) {length(unique(x))})

# construct match, unmatch column for transactions
dt[, IS_MATCHED := ifelse(!is.na(MATCH_BET_ID), 'Yes','No')]
dt$IS_MATCHED <- as.factor(dt$IS_MATCHED)
names(dt)


# Fix the Profit Loss calculations
dt$FIX_PROFIT_LOSS <- 0

dt[!is.na(PROFIT_LOSS), FIX_PROFIT_LOSS := 
       ifelse(BID_TYP == 'B', ifelse(PROFIT_LOSS >0, BET_SIZE*(PRICE_TAKEN - 1), -BET_SIZE), 
              ifelse(PROFIT_LOSS >0, BET_SIZE, -BET_SIZE*(PRICE_TAKEN - 1 )) )] 


# add POTENTIAL Loss 
dt[, POTENTIAL_LOSS :=
       ifelse(BID_TYP == 'B', -BET_SIZE, -BET_SIZE*(BET_PRICE - 1))]

# add Potential Win
dt[,  POTENTIAL_WIN :=
       ifelse(BID_TYP == 'B', BET_SIZE*(BET_PRICE - 1), BET_SIZE) ]


##################################################
############### 1.Account profit / Loss############
##################################################

# 1. account potential win, potential lose and actual profit
act <- dt[, list(pot_win = sum(POTENTIAL_WIN), pot_lose = sum(POTENTIAL_LOSS), actual_profit = sum(FIX_PROFIT_LOSS)), by=ACCOUNT_ID]


## explore:
# 1.1 plot actual profit and potential win relationship
pct_celling <- 0.80
pct_floor <- 0.00
plot(act$actual_profit, act$pot_win)
plot(act[pot_win > quantile(act$pot_win, pct_floor)& pot_win <= quantile(act$pot_win, pct_celling)]$actual_profit, 
     act[pot_win > quantile(act$pot_win, pct_floor)& pot_win <= quantile(act$pot_win, pct_celling)]$pot_win)

# 1.2 plot actual profit and potential lose relationship
plot(act$actual_profit, -act$pot_lose)
plot(act[ -pot_lose > quantile(-act$pot_lose, pct_floor) & -pot_lose <= quantile(-act$pot_lose, pct_celling)]$actual_profit, 
     -act[ -pot_lose > quantile(-act$pot_lose, pct_floor) & -pot_lose <= quantile(-act$pot_lose, pct_celling)]$pot_lose)

## note: as can be seen the 90% of potential win or lose value have a sysmetric actual win or lose profits,
## which means, and it shows a sparse V shape. still most of people weather they take more risk or get more
## potential wins values, can only slightly affect the profits. And only a small amount of account Can Win or lose big amount of profit


#######################################################
############### 2.Account Transaction count ############
#######################################################
# 2 Transactions number per account
#  Account bet cnt, Back bet cnt, Lay bet cnt
dt$CNT <- 1
cnt <- dt[,list(total_cnt = sum(CNT), 
                back_cnt = sum(ifelse(BID_TYP=='B',1,0)),
                lay_cnt = sum(ifelse(BID_TYP=='L',1,0)) ), by= ACCOUNT_ID]


#explore: 
# 2.1 Lay bet has 1.6 % more than back bet
sum(cnt$back_cnt) / sum(cnt$lay_cnt)

#2.2 check the bet count distribution for different account ID
hist(cnt$total_cnt)
hist(cnt[total_cnt <= quantile(cnt$total_cnt,0.8)]$total_cnt, breaks = 300)

# 2.3
nrow(cnt[total_cnt<=10])/nrow(cnt)
nrow(cnt[total_cnt<=50])/nrow(cnt)
# about 48.7% accounts have less equal to 10 bets in total
# 70% of accounts have less than equal to 50 bets in total

#* 2.4 top 10% of transaction counts distribution
hist(cnt[total_cnt > quantile(cnt$total_cnt,0.9)&total_cnt < quantile(cnt$total_cnt,0.99)]$total_cnt, breaks = 100)

################################################################
############## 3. Add events into considerations ################
################################################################

# 3 first see in general the distribution of bets for each event and absoulte profits
event <- dt[, list(bet_cnt = sum(CNT), 
                   abs_profit=sum(abs(FIX_PROFIT_LOSS)),
                   avg_abs_profit = sum(abs(FIX_PROFIT_LOSS))/sum(CNT),
                   event_name =MATCH[1] ), by=EVENT_ID]

hist(event$bet_cnt)
hist(event$abs_profit)
hist(event$avg_abs_profit)

# 3.1 get the value for each account and event combination
act_event <- dt[, list(pot_win = sum(POTENTIAL_WIN), 
                       pot_lose = sum(POTENTIAL_LOSS), 
                       actual_profit = sum(FIX_PROFIT_LOSS),
                       total_cnt = sum(CNT), 
                       back_cnt = sum(ifelse(BID_TYP=='B',1,0)),
                       lay_cnt = sum(ifelse(BID_TYP=='L',1,0)) ,
                       avg_bet_price = mean(BET_PRICE),
                       avg_bet_size = mean(BET_SIZE)),  by=list(ACCOUNT_ID,EVENT_ID)]

#3.2 get the variables variance across the event, for potential win, lose, actual profit, bet cnt, bet price and bet size
act_event_variance <- act_event[,list(sd_pot_win = ifelse(length(total_cnt)==1,0, sd(pot_win)), 
                                      sd_pot_lose = ifelse(length(total_cnt)==1,0, sd(pot_lose)), 
                                      sd_actual_profit = ifelse(length(total_cnt)==1,0, sd(actual_profit)),
                                      sd_total_cnt = ifelse(length(total_cnt)==1,0, sd(total_cnt)), 
                                      sd_back_cnt = ifelse(length(total_cnt)==1,0, 
                                                           ifelse(length(back_cnt) %in% c(0,1), 0, sd(back_cnt) ) )  ,
                                      sd_lay_cnt = ifelse(length(total_cnt)==1,0,
                                                          ifelse(length(back_cnt) %in% c(0,1), 0,sd(lay_cnt)) ) ,
                                      sd_avg_bet_price = ifelse(length(total_cnt)==1,0, sd(avg_bet_price)),
                                      sd_avg_bet_size = ifelse(length(total_cnt)==1,0, sd(avg_bet_size)))
                                ,  by=ACCOUNT_ID]

#lapply(act_event, function(x){sum(is.na(x))})
#lapply(act_event_variance, function(x){sum(is.na(x))})

act_event_variance

#################################################################################
############## 3. consider match, match rate, cancel rate, lapse rate ###########
#################################################################################
#4. get matched bet count for each account, and unmatched, cancel, lapsed
match <- dt[, list(matched_cnt = sum(ifelse(IS_MATCHED=='Yes',1,0)),
                   unmatched_cnt = sum(ifelse(IS_MATCHED=='No',1,0)),
                   cancel_cnt = sum(ifelse(STATUS_ID=='C',1,0)),
                   lapsed_cnt =  sum(ifelse(STATUS_ID=='L',1,0))), by=ACCOUNT_ID ]





# combine dataset
setkey(act, ACCOUNT_ID)
setkey(cnt, ACCOUNT_ID)
setkey(match, ACCOUNT_ID)
setkey(act_event_variance,ACCOUNT_ID)

act_features <- merge(act, cnt, all=T)
act_features <- merge(act_features, match, all=T)
act_features <- merge(act_features, act_event_variance, all=T)

# calculate match related rate features
act_features[, match_rate:= matched_cnt/ total_cnt] 
act_features[, unmatch_rate:= unmatched_cnt/ total_cnt] 
act_features[, cancel_rate:= cancel_cnt/ total_cnt] 
act_features[, lapsed_rate:= lapsed_rate/ total_cnt]
# calculate average profits related features
act_features[, avg_pot_win:= pot_win/ total_cnt] 
act_features[, avg_pot_lose:= pot_lose/ total_cnt]
act_features[, avg_actual_profit:= actual_profit/ total_cnt]



#####################################
########     Summary    #############
####################################
lapply(dt, function(x) {length(unique(x))})

# Total Bets: 3461173
# Total Event: 44 (1 Event cancel)
# Total Account: 21020 unique accounts in 69 differnt countries
#  Total Matched bet: 2812898 with 81.2% (high this point)matched rate 
nrow(dt[IS_MATCHED=='Yes'])
nrow(dt[IS_MATCHED=='Yes'])/nrow(dt)
# In play Bet : 2534654, with 73.2% , and all matched(highlight this) for in play bet
nrow(dt[INPLAY_BET=='Y'])
nrow(dt[INPLAY_BET=='Y'])/nrow(dt)
# Total postifve profits(can generate commission) :706,808,897
# Total Loss (should approximately equal to total profits): -706823612
sum(dt[FIX_PROFIT_LOSS>=0]$FIX_PROFIT_LOSS)
sum(dt[FIX_PROFIT_LOSS<0]$FIX_PROFIT_LOSS)





#fit <- rpart(actual_profit~.-ACCOUNT_ID, data=act_features )
