rm(list = ls()); gc()
load("../Datathon_Full_Dataset/full_data.RData")

require(data.table)
require(dplyr)
##########################################################################
## 1. subset #############################################################
##########################################################################
## 1.1 subset account winrate #######
length(unique(dt$ACCOUNT_ID))
# 21020

subsetCntAccount <- dt[!is.na(PROFIT_LOSS)] %>%
    group_by(ACCOUNT_ID, COUNTRY_OF_RESIDENCE_NAME, WIN) %>%
    summarise(count = n(), PROFIT_LOSS = sum(PROFIT_LOSS)/n())

dim(subsetCntAccount)[1]
# 35386

subsetRateAccount <- merge(x = subsetCntAccount[WIN == "L"]
                           , y = subsetCntAccount[WIN == "W"]
                           , by = c("ACCOUNT_ID", "COUNTRY_OF_RESIDENCE_NAME")
                           , all = T)

subsetRateAccount$WINRATE <- ifelse(is.na(subsetRateAccount$count.x)
                                    , 1
                                    , ifelse(is.na(subsetRateAccount$count.y)
                                             , 0
                                             , subsetRateAccount$count.y / (subsetRateAccount$count.x + subsetRateAccount$count.y)))

setnames(subsetRateAccount, c("count.x", "count.y", "PROFIT_LOSS.x", "PROFIT_LOSS.y"), c("CNT_L", "CNT_W", "PROFIT_LOSS_L", "PROFIT_LOSS_W"))
subsetRateAccount[is.na(CNT_L)]$CNT_L <- 0
subsetRateAccount[is.na(CNT_W)]$CNT_W <- 0
subsetRateAccount[is.na(PROFIT_LOSS_L)]$PROFIT_LOSS_L <- 0
subsetRateAccount[is.na(PROFIT_LOSS_W)]$PROFIT_LOSS_W <- 0
subsetRateAccount <- subsetRateAccount[, !c("WIN.x", "WIN.y"), with = F]

## it makes sense to remove the tails (CNT_L + CNT_W is small)
subsetRateAccount_noTail <- subsetRateAccount[CNT_L + CNT_W >= 10]
# ACCOUNT_ID COUNTRY_OF_RESIDENCE_NAME CNT_L PROFIT_LOSS_L CNT_W
# 1:    1000002            United Kingdom   176    -90.451622   163
# 2:    1000004            United Kingdom    23    -24.101345     6
# 3:    1000005            United Kingdom    74    -64.204561    83
# 4:    1000006                 Australia    46    -12.472325    58
# 5:    1000010            United Kingdom    57    -95.624550    29
# ---                                                               
#     10443:    1024179            United Kingdom     8     -1.116754     8
# 10444:    1024180            United Kingdom    13   -115.958754    15
# 10445:    1024181            United Kingdom     5    -21.691170    14
# 10446:    1024186            United Kingdom     5    -50.797901     5
# 10447:    1024189            United Kingdom 14732   -891.862592  3888
# PROFIT_LOSS_W   WINRATE
# 1:     105.45982 0.4808260
# 2:      20.65885 0.2068966
# 3:      44.55122 0.5286624
# 4:      15.25430 0.5576923
# 5:     169.64830 0.3372093
# ---                        
#     10443:       3.36358 0.5000000
# 10444:     115.05946 0.5357143
# 10445:      47.71853 0.7368421
# 10446:     149.01511 0.5000000
# 10447:    3259.36846 0.2088077

dim(subsetRateAccount_noTail)[1]
# 10447

save(subsetRateAccount_noTail, file = "../Datathon_Full_Dataset/subsetRateAccount_noTail.RData")

## 1.2 subset loc winrate #######
subsetRateLoc <- subsetRateAccount_noTail %>%
    group_by(COUNTRY_OF_RESIDENCE_NAME) %>%
    summarise(CNT_ACCOUNT = n()
              , CNT_TRANS_L = sum(CNT_L)
              , CNT_TRANS_W = sum(CNT_W)
              , PROFIT_LOSS_L = sum(PROFIT_LOSS_L)
              , PROFIT_LOSS_W = sum(PROFIT_LOSS_W)
              , CNT_TRANS_PER_ACCT = (sum(CNT_L + CNT_W)) / n()
              , PROFIT_LOSS_PER_ACCT = (sum(PROFIT_LOSS_L + PROFIT_LOSS_W)) / n()
              , WINRATE = (sum(CNT_W))/ (sum(CNT_W) + sum(CNT_L)))
# COUNTRY_OF_RESIDENCE_NAME CNT_ACCOUNT CNT_TRANS_L CNT_TRANS_W PROFIT_LOSS_L
# 1            United Kingdom        3686      388811      379408    -530837.51
# 2                 Australia        1113       57090       53681    -159823.67
# 3                     Malta        1244      138808      133294    -280696.41
# 4                     India         448       30726       24912     -30856.33
# 5   Virgin Islands, British         579      191407      212364    -203651.85
# 6                Seychelles         811      155870      161389    -214330.65
# PROFIT_LOSS_W PROFIT_LOSS_PER_ACCT   WINRATE
# 1     569546.36            10.501588 0.4938800
# 2     176693.57            15.157143 0.4846124
# 3     285856.24             4.147772 0.4898678
# 4      41052.29            22.758826 0.4477515
# 5     188121.65           -26.822455 0.5259516
# 6     204039.61           -12.689326 0.5086979

dim(subsetRateLoc)[1]
# 58

save(subsetRateLoc, file = "../Datathon_Full_Dataset/subsetRateLoc.RData")
