Melbourne Datathon 2015 
==============================

The Melbourne Datathon is a Hackathon for Data Science.
Teams have one week to analyse a dataset and come up with exciting new insights. Can you convince our panel to invest money in your analytics?

### Self Defined Dictionary
1. **BET_ID**: ID of a Bet
2. **BET_TRANS_ID**: ID of a Transaction in a Bet
3. **MATCH_BET_ID**: ID of a Match
4. **ACCOUNT_ID**: ID of a User
5. **COUNTRY_OF_RESIDENCE_NAME**: Country of User ACCOUNT
6. **PARENT_EVENT_ID**: ID of a Parent Match Event
7. **EVENT_ID**: ID of a Match Event
8. **MATCH**: Name of a Match
9. **EVENT_NAME**: Name of a Match Event
10. **EVENT_DT**: Date of a Match Event
11. **OFF_DT**: The time the match actually started, i.e. when the bowler bowled the first ball 
12. **BID_TYP**: B = Back, L = Lay (bet it won't happen) 
13. **STATUS_ID**: S = settled (outcome of match known), C = cancelled, V = void (e.g. match rained out), L = lapsed (no match
                   between backer and layer - NULL taken date cancelled date)
14. **PLACED_DATE**: Date when the Bet was placed
15. **TAKEN_DATE**: Date when the Bet was taken/accepted (Bet matched to a corresponding Lay)
16. **SETTLED_DATE**: Date when the Bet was settled/officially kept
17. **CANCELLED_DATE**: Date when the Bet was cancelled
18. **SELECTION_NAME**: Name of the team was bidded
19. **PERSISTENCE_TYPE**: IP = in play (bet can be matched after the game started up till it finishes. otherwise it will lapse
                          if not settled by the start of the game.)
20. **BET_PRICE**: Price of the Bet
21. **PRICE_TAKEN**: Actual price when the Bet is Matched with a Lay.  May not be equal to PRICE_TAKEN 
22. **INPLAY_BET**: Whether the Bet is placed during the match or prior to the match
23. **BET_SIZE**: Number of units Bet/Lay at the given BET_PRICE (eg. 100 BET_SIZE at 1.20 BET_PRICE = $120.  If they chose right, they win $20)
24. **PROFIT_LOSS**: Loss of the Bet from BetFair (always a postive number?)

### Notes
- Betfair is a UK company, they take bets on global events from around the world
- They do not do bookmaking, they just match Bets to Lays like a stock exchange
- Bet/back = "sell".  Lay = "buy" (bet that the specified outcome WON'T happen)
- Eg 1 Bet for 100 units can be matched to 5 Lays for 20 units.
- If there are only 50 units of lay available at the price, then only 50 will be made (partial matching)
- The biggest customers use custom applications via API rather than website or mobile app
- Many bets are from tax havens like Virgin Islands etc because big gamblers store their money there
- Country of residence is the country of ACCOUNT, not the actual person 
- No USA Country of residence because it is illegal there
- They do not have a margin, but make a commission on winnings.  So prices are much closer to actual probability.
- Prices are determined by customer Bets/Lays
- Semifinal and final data are saved for Kaggle competition

### Thoughts
1. If time & dates (holiday, weekday) have impacts on people's behaviour (e.g. Bet_size)
2. If players behaviour different between different countries, event_type?
3. If players can be segmented based on their transactions history including (frequency, size, recency, favorates to particular events?) and in turn, target the most valuable segments to BetFair.
4. If the data is capable to segment customers into groups like (aggresive/defensive customers) and we are able to see who are always the winners/losers to gambling, also the overall profitabilities of those groups so BetFair may develop an machine learning algorithm to predict those winners behavior and then adjust the bet ratios to maximize/minimize profit/risks of each event.


## Summary of Data Walkthrough
### Data Dictionary

1. **BET_ID**: Bet ID. Two types: Back Bet ID(customer who Back a bet, raise a bet); Lay Bet ID, are "MATHC_BET_ID" to corresponding Back BET_ID. 
2. **BET_TRANS_ID**: Transaction ID, Primary key for the dataset
3. **MATCH_BET_ID**: Matched Bet ID, corresponding to Bet ID. (appears as BET_ID for Lay BET_ID)
4. **ACCOUNT_ID**: ID of a User
5. **COUNTRY_OF_RESIDENCE_NAME**: Country of User ACCOUNT
6. **PARENT_EVENT_ID**: (Not important)
7. **EVENT_ID**: (Not important)
8. **MATCH**: Gambling Match Name
9. **EVENT_NAME**: One value : Match Odds (not important)
10. **EVENT_DT**: Scheduled Event Time (GMT)
11. **OFF_DT**: The time the match actually started, i.e. when the bowler bowled the first ball 
12. **BID_TYP**: B = Back, L = Lay (bet it won't happen) 
13. **STATUS_ID**: S = settled (outcome of match known), C = cancelled, V = void (e.g. match rained out), L = lapsed (no match
                   between backer and layer - NULL taken date cancelled date)
14. **PLACED_DATE**: Date when the Bet was placed
15. **TAKEN_DATE**: Date when the Bet was taken/accepted (Bet matched to a corresponding Lay)
16. **SETTLED_DATE**: Date when the Bet was settled/officially kept (When the game outcome is settled)
17. **CANCELLED_DATE**: Date when the Bet was cancelled
18. **SELECTION_NAME**: Name of the team was bidded
19. **PERSISTENCE_TYPE**: IP = in play (bet can be matched after the game started up till it finishes. otherwise it will lapse
                          if not settled by the start of the game.)
20. **BET_PRICE**: Price of the Bet. Customer who rasie the bet can request any price they like. This request price like stock market will affect the Back and Lay price
21. **PRICE_TAKEN**: Actual price when the Bet is Matched with a Lay. Mathced pair of Back and Lay bets are always have same PRICE_TAKEN, this is an automatica assignment according to the best market price.
22. **INPLAY_BET**: Whether the Bet is placed during the match or prior to the match
23. **BET_SIZE**: Number of units Bet/Lay at the given BET_PRICE (eg. 100 BET_SIZE at 1.20 BET_PRICE = $120.  If they chose right, they win $20)
24. **PROFIT_LOSS**: Profit Customer who win the bet or Loss who lose the bet. (Calculation of the Profit = BET_SIZE * (PRICE_TAKE - 1))

### Summary and Thought
Betfair as the platform unlike the traditional bookmarker does not invovle in the bet. Customers do not bet against the Betfair, customers bet each other. Betfair charge the commission from bet winners.

1. A successful bet can alwasy considered as a paris of matched bet transactions. 
    - BET_ID(B1)  MATCH_BET_ID(M1)   Back
    - BET_ID(M1)  MATCH_BET_ID(B1)   Lay
For matched bet, Back and Lay have the same PRICE_TAKEN, which is automatically assigned based on the PLACED_PRICE and market price(best price). The profit loss calculate as: BET_SIZE * (PRICE_TAKEN - 1)

2. One BET_ID can be matched to multiple distinct MATCHED_BET_ID. (different unique pair Bets)

3. A huge amount of transactions that are not matched,(cancelled or lappsed) which do not have MATCH_BET_ID, TAKEN_DATE, PRICE_TAKEN AND PROFIT_LOSS. I think, some of the reason may be the inappropriate BET_PRICE or BET_SIZE. Findings and suggestions can lead a higher bet match will be interesting.

4. Total sum of profit loss will approximate to be 0

5. Betfair cares more about getting more people to play; getting more bets to be matched, then they can get certain percent of commission from the winners.

6. They can provide discounts for big customers. (not quite sure, I think valuable customers are the one who raise bet). How could we provide suggestions for valuable customers to make best decisions(bet size, bet price etc) to win more profits. And Betfair can get more commission. 

7. Any questions please contact Robert.Linsley@Betfair.com.au , Analytics Lead of Betfair.



