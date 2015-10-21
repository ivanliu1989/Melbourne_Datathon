rm(list = ls()); gc()
require(data.table)
require(dplyr)
require(lubridate)
load("../Datathon_Full_Dataset/full_data.RData")
##########################################################################
## 1. subset #############################################################
##########################################################################
## 1.1 subset account winrate #######
length(unique(dt$ACCOUNT_ID))
# 21020

# any unmatched or cancelled P/L are set to 0
dt[, EXP_PROFIT_LOSS_W := ifelse(BID_TYP == "B", (BET_PRICE - 1) * BET_SIZE, BET_SIZE)]
dt[, EXP_PROFIT_LOSS_L := ifelse(BID_TYP == "L", (BET_PRICE - 1) * BET_SIZE, BET_SIZE)]

dt$PROFIT_LOSS[is.na(dt$PROFIT_LOSS)] <- 0

# basic account oriented subset
subsetAcct <- dt %>%
    group_by(ACCOUNT_ID, COUNTRY_OF_RESIDENCE_NAME) %>%
    summarise(
              # TTL_NO_OF_TRANS = n()
              AVG_NO_OF_TRANS_PER_BET = n() / n_distinct(BET_ID)
              # , AVG_NO_OF_TRANS_PER_MATCH = n() / n_distinct(MATCH)
              
              # , TTL_NO_OF_BETS = n_distinct(BET_ID)
              , AVG_NO_OF_BETS_PER_MATCH = n_distinct(BET_ID) / n_distinct(MATCH)
              
              , TTL_NO_OF_MATCH = n_distinct(MATCH)
              
              # , MIN_EXP_WIN = min(EXP_PROFIT_LOSS_W)
              # , MAX_EXP_WIN = max(EXP_PROFIT_LOSS_W)
              # , TTL_EXP_WIN = sum(EXP_PROFIT_LOSS_W)
              
              , AVG_EXP_WIN_PER_TRAN = sum(EXP_PROFIT_LOSS_W) / n()
              # , AVG_EXP_WIN_PER_BET = sum(EXP_PROFIT_LOSS_W) / n_distinct(BET_ID)
              # , AVG_EXP_WIN_PER_MATCH = sum(EXP_PROFIT_LOSS_W) / n_distinct(MATCH)
              
              # , MIN_EXP_LOSS = min(EXP_PROFIT_LOSS_L)
              # , MAX_EXP_LOSS = max(EXP_PROFIT_LOSS_L)
              # , TTL_EXP_LOSS = sum(EXP_PROFIT_LOSS_L)
              
              , AVG_EXP_LOSS_PER_TRAN = sum(EXP_PROFIT_LOSS_L) / n()
              # , AVG_EXP_LOSS_PER_BET = sum(EXP_PROFIT_LOSS_L) / n_distinct(BET_ID)
              # , AVG_EXP_LOSS_PER_MATCH = sum(EXP_PROFIT_LOSS_L) / n_distinct(MATCH)
              
              # , TTL_PROFIT_LOSS = sum(PROFIT_LOSS)
              # , AVG_TTL_PROFIT_LOSS_PER_TRAN = sum(PROFIT_LOSS) / n()
              , AVG_TTL_PROFIT_LOSS_PER_BET = sum(PROFIT_LOSS) / n_distinct(BET_ID)
              , AVG_TTL_PROFIT_LOSS_PER_MATCH = sum(PROFIT_LOSS) / n_distinct(MATCH)
              
              , TTL_RATE_CANCEL = sum(!is.na(CANCELLED_DATE)) / n()
              , AVG_RATE_CANCEL_PER_BET = sum(!is.na(CANCELLED_DATE)) / n_distinct(BET_ID)
              , AVG_RATE_CANCEL_PER_MATCH = sum(!is.na(CANCELLED_DATE)) / n_distinct(MATCH)
              
              , TTL_RATE_WIN = sum(ifelse(PROFIT_LOSS > 0, 1, 0)) / n()
              , AVG_RATE_WIN_PER_BET = sum(ifelse(PROFIT_LOSS > 0, 1, 0)) / n_distinct(BET_ID)
              , AVG_RATE_WIN_PER_MATCH = sum(ifelse(PROFIT_LOSS > 0, 1, 0)) / n_distinct(MATCH)
              )

str(subsetAcct)
# $ ACCOUNT_ID                   : chr  "1009306" "1005119" "1018472" "1018768" ...
# $ COUNTRY_OF_RESIDENCE_NAME    : chr  "UAE" "UAE" "UAE" "Malta" ...
# $ TTL_NO_OF_TRANS              : int  8189 188 220 176 597 58 529 432 218 2154 ...
# $ AVG_NO_OF_TRANS_PER_BET      : num  9.74 1.04 1.11 1.01 1.89 ...
# $ AVG_NO_OF_TRANS_PER_MATCH    : num  292.46 11.06 13.75 4.76 17.06 ...
# $ TTL_NO_OF_BETS               : int  841 180 198 174 316 47 438 415 187 1015 ...
# $ AVG_NO_OF_BETS_PER_MATCH     : num  30.04 10.59 12.38 4.7 9.03 ...
# $ TTL_NO_OF_MATCH              : int  28 17 16 37 35 12 32 37 21 19 ...
# $ MIN_EXP_WIN                  : num  0.00624 0.59722 0.03477 10.79864 0.28328 ...
# $ MAX_EXP_WIN                  : num  199638 485 1644 779 7726 ...
# $ TTL_EXP_WIN                  : num  12871657 7516 28755 18955 344077 ...
# $ AVG_EXP_WIN_PER_TRAN         : num  1572 40 131 108 576 ...
# $ AVG_EXP_WIN_BET              : num  15305.2 41.8 145.2 108.9 1088.9 ...
# $ AVG_EXP_WIN_PER_MATCH        : num  459702 442 1797 512 9831 ...
# $ MIN_EXP_LOSS                 : num  -152760 -279 -1299 -379 -8840 ...
# $ MAX_EXP_LOSS                 : num  -0.0127 -0.216 -0.1159 -1.471 -0.0256 ...
# $ TTL_EXP_LOSS                 : num  -14689420 -5962 -19345 -6492 -361758 ...
# $ AVG_EXP_LOSS_PER_TRAN        : num  -1793.8 -31.7 -87.9 -36.9 -606 ...
# $ AVG_EXP_LOSS_PER_BET         : num  -17466.6 -33.1 -97.7 -37.3 -1144.8 ...
# $ AVG_EXP_LOSS_PER_MATCH       : num  -524622 -351 -1209 -175 -10336 ...
# $ TTL_PROFIT_LOSS              : num  -39853.4 -129.7 -536.4 -66.8 2826.5 ...
# $ AVG_TTL_PROFIT_LOSS_PER_TRAN : num  -4.87 -0.69 -2.44 -0.38 4.73 ...
# $ AVG_TTL_PROFIT_LOSS_PER_BET  : num  -47.388 -0.72 -2.709 -0.384 8.945 ...
# $ AVG_TTL_PROFIT_LOSS_PER_MATCH: num  -1423.33 -7.63 -33.52 -1.81 80.76 ...
# $ TTL_RATE_CANCEL              : num  0.0259 0.1383 0.15 0.2273 0.0871 ...
# $ AVG_RATE_CANCEL_PER_BET      : num  0.252 0.144 0.167 0.23 0.165 ...
# $ AVG_RATE_CANCEL_PER_MATCH    : num  7.57 1.53 2.06 1.08 1.49 ...
# $ TTL_RATE_WIN                 : num  0.54 0.511 0.282 0.216 0.461 ...
# $ AVG_RATE_WIN_PER_BET         : num  5.253 0.533 0.313 0.218 0.87 ...
# $ AVG_RATE_WIN_PER_MATCH       : num  157.79 5.65 3.88 1.03 7.86 ...

## first bet placers per MATCH
tempSubAcct <- dt %>%
    group_by(MATCH, ACCOUNT_ID) %>%
    summarise(MIN_PLCAED_DT_PER_MATCH = min(PLACED_DATE)) %>%
    group_by(MATCH) %>%
    mutate(rank = rank(MIN_PLCAED_DT_PER_MATCH)) %>%
    filter(rank <= ceiling(n_distinct(ACCOUNT_ID) * .05))

tempSubAcctTopPlacer <- tempSubAcct %>%
    group_by(ACCOUNT_ID) %>%
    summarise(TOP = n())

subsetAcct <- merge(x = subsetAcct
                            , y = tempSubAcctTopPlacer
                            , all.x = T
                            , by = "ACCOUNT_ID")

subsetAcct$TOP[is.na(subsetAcct$TOP)] <- 0

## left join the basic one

dim(subsetAcct)[1]
# 21020

save(subsetAcct, file = "../Datathon_Full_Dataset/subsetAcct.RData")

## 1.2 subset loc winrate #######
# subsetRateLoc <- subsetRateAccount_noTail %>%
#     group_by(COUNTRY_OF_RESIDENCE_NAME) %>%
#     summarise(CNT_ACCOUNT = n()
#               , NO_OF_BETS_L = sum(NO_OF_BETS_L)
#               , NO_OF_BETS_W = sum(NO_OF_BETS_W)
#               , PROFIT_LOSS_L = sum(PROFIT_LOSS_L)
#               , PROFIT_LOSS_W = sum(PROFIT_LOSS_W)
#               , NO_OF_BETS_PER_ACCT = (sum(NO_OF_BETS_L + NO_OF_BETS_W)) / n()
#               , PROFIT_LOSS_PER_ACCT = (sum(PROFIT_LOSS_L + PROFIT_LOSS_W)) / n()
#               , WINRATE = (sum(NO_OF_BETS_W))/ (sum(NO_OF_BETS_W) + sum(NO_OF_BETS_L)))
# # COUNTRY_OF_RESIDENCE_NAME CNT_ACCOUNT CNT_TRANS_L CNT_TRANS_W PROFIT_LOSS_L
# # 1            United Kingdom        3686      388811      379408    -530837.51
# # 2                 Australia        1113       57090       53681    -159823.67
# # 3                     Malta        1244      138808      133294    -280696.41
# # 4                     India         448       30726       24912     -30856.33
# # 5   Virgin Islands, British         579      191407      212364    -203651.85
# # 6                Seychelles         811      155870      161389    -214330.65
# # PROFIT_LOSS_W PROFIT_LOSS_PER_ACCT   WINRATE
# # 1     569546.36            10.501588 0.4938800
# # 2     176693.57            15.157143 0.4846124
# # 3     285856.24             4.147772 0.4898678
# # 4      41052.29            22.758826 0.4477515
# # 5     188121.65           -26.822455 0.5259516
# # 6     204039.61           -12.689326 0.5086979
# 
# dim(subsetRateLoc)[1]
# # 58
# 
# save(subsetRateLoc, file = "../Datathon_Full_Dataset/subsetRateLoc.RData")
