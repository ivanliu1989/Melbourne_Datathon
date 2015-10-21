

# start visulization, from the account(represent user) perspective
head(act_features)
# 1.1 relationship between expected winning money and actual profit

pct_celling <- 0.9
pct_floor <- 0.00
plot_data <- act_features[pot_win > quantile(act_features$pot_win, pct_floor)
                          & pot_win <= quantile(act_features$pot_win, pct_celling)]

g <- ggplot(plot_data, aes( actual_profit,pot_win))
p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
     xlab("The Net Profit for each Account") +
     ylab("Expected Total Potential Winning Profit(Invest Money)")+
     ggtitle('The correlations Between Total Expected Profits and Actual Net Profits ')

print(p)

# 1.2 relationship between risk losing money and actual profit
plot_data1 <- act_features[ -pot_lose > quantile(-act$pot_lose, pct_floor) & 
                           -pot_lose <= quantile(-act$pot_lose, pct_celling)]


g <- ggplot(plot_data1, aes( actual_profit,-pot_lose))
p <- g + geom_point(color = "#FF9999",size = 2, alpha = 1/2) +
    xlab("The Net Profit for each Account") +
    ylab(" Total Potential Lose (Invest Money)") +
    ggtitle('The correlations Between Total Risky Lose and Actual Net Profits ')

print(p)

# note the for 90% quantile of expceted winning value, and risky losing value,
# it slight affect the actual earning net profits.
# only some few account can have a correlationship between the invest money and actual profit

# 2. The distribution of Bet counts accros Account
head(act_features)
plot_data2 <- sqldf("select ACCOUNT_ID, total_cnt, 'Total' from act_features
                   union
                   select  ACCOUNT_ID, back_cnt, 'Back' from act_features
                   union
                   select  ACCOUNT_ID, lay_cnt, 'Lay' from act_features")
names(plot_data2) <- c('ACCOUNT_ID', 'Count', 'Type')
plot_data2 <- data.table(plot_data2)
plot_data2 <- plot_data2[Count <= quantile(plot_data2$Count,0.9) ]
qplot( Count, data=plot_data2, fill=Type, 
       xlab = 'The number of Bets(Transactions) for Accounts',
       ylab = 'The number of Account',
       main = 'The Distribution of Bets(Transactions) Made for Majory Accounts')

nrow(act_features[total_cnt<=50])/nrow(act_features)

# most of account have less than 50 bets in total

# 3. The relationship between bet count and total net profits
plot_data3 <- act_features[total_cnt<= quantile(act_features$total_cnt,0.9)]
    
g <- ggplot(plot_data3, aes( total_cnt, actual_profit))
p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("The Number of Bet for Account") +
    ylab("The Net Profit for Account")

print(p)

# no relationship between cnt and profit


# 4. Average expected win or lose Versus Match Rate
g <- ggplot(plot_data, aes( avg_pot_win, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Average Expected Winning Value") +
    ylab("Account Match Rate") +
    ggtitle('The correlations Between Average Amount Invested Money and Matched Rate ')

print(p)

g <- ggplot(plot_data1, aes( -avg_pot_lose, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Average Expected Losing Value") +
    ylab("Account Match Rate")


print(p)


# standard deviation relationship
# 5. sd_pt_win vs match rate
plot_date_sd1 <- act_features[sd_pot_win <= quantile(act_features$sd_pot_win,0.9)]

g <- ggplot(plot_date_sd1, aes( sd_pot_win, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Expected Winning Money on Different Event") +
    ylab("Match Rate") +
    ggtitle('Standard Deviation of Invested Money on Different Event and Matched Rate ')


print(p)

# std_pt_win vs profit
g <- ggplot(plot_date_sd1, aes( sd_pot_win, actual_profit))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Expected Winning Value for Account") +
    ylab("The Net Profits for Accounts")


print(p)

# note standard devation increase, the profit lose deviation increase 

#* 6. sd_pt_lose vs match rate
plot_date_sd2 <- act_features[sd_pot_lose <= quantile(act_features$sd_pot_win,0.90)]
g <- ggplot(plot_date_sd2, aes( sd_pot_lose, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Expected Winning Value for Account") +
    ylab("Match Rate")


print(p)

# std_pt_win vs profit
g <- ggplot(plot_date_sd2, aes( sd_pot_lose, actual_profit))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Expected Winning Value for Account") +
    ylab("The Net Profits for Accounts")


print(p)
    
# 7 sd_total_cnt vs match_rate  
plot_date_sd3 <- act_features[sd_total_cnt <= quantile(act_features$sd_total_cnt,0.99)]
g <- ggplot(plot_date_sd3, aes( sd_total_cnt, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Number of Bets for Account") +
    ylab("Match Rate")+
    ggtitle('Standard Deviation of Bets on Different Event and Matched Rate ')

print(p)
# negative correlation, 

g <- ggplot(plot_date_sd3, aes( sd_total_cnt, actual_profit))

#sd_total_cnt vs total_profit  (no relationship)
p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Standard Deviation of Number of Bets for Accoun") +
    ylab("The Net Profits for Accounts")

print(p)


#########################################
plot_date4 <- act_features
g <- ggplot(plot_date4, aes( cancel_rate, match_rate))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Cancel Rate for Account") +
    ylab("Match Rate")

print(p)

g <- ggplot(plot_date4, aes( cancel_rate, actual_profit))

p <- g + geom_point(color = "steelblue",size = 2, alpha = 1/2) +
    geom_smooth(method = "lm") +
    xlab("Cancel Rate for Account") +
    ylab("The Net Profits")

print(p)

# cancel rate 

