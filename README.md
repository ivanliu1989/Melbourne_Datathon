Melbourne Datathon 2015 
==============================

The Melbourne Datathon is a Hackathon for Data Science.
Teams have one week to analyse a dataset and come up with exciting new insights. Can you convince our panel to invest money in your analytics?

![alt tag](http://m.c.lnkd.licdn.com/mpr/mpr/shrink_200_200/p/8/000/1f2/006/28181a6.jpg)

### Self Defined Dictionary
1. **BET_ID**: ID of a Bet
2. **BET_TRANS_ID**: ID of a Transaction in a Bet
3. **MATCH_BET_ID**: ID of a Match
4. **ACCOUNT_ID**: ID of a User
5. **COUNTRY_OF_RESIDENCE_NAME**: Country of a User
6. **PARENT_EVENT_ID**: ID of a Parent Match Event
7. **EVENT_ID**: ID of a Match Event
8. **MATCH**: Name of a Match
9. **EVENT_NAME**: Name of a Match Event
10. **EVENT_DT**: Date of a Match Event
11. **OFF_DT**: ? (What is this date about? from the sample it is the same as EVENT DT)
12. **BID_TYP**: ? (What do they stand for?, e.g. "B ", "L ")
13. **STATUS_ID**: ? (What do they stand for?, e.g. "S " "C " "L ")
14. **PLACED_DATE**: Date when the Bet was placed
15. **TAKEN_DATE**: Date when the Bet was taken/accepted
16. **SETTLED_DATE**: Date when the Bet was settled/officially kept
17. **CANCELLED_DATE**: Date when the Bet was cancelled
18. **SELECTION_NAME**: Name of the team was bidded
19. **PERSISTENCE_TYPE**: ? (What do they stand for?, e.g. NA   "IP")
20. **BET_PRICE**: Price of the Bet
21. **PRICE_TAKEN**: ? (actual Price of the Bet when taken/accepted?)
22. **INPLAY_BET**: Whether the Bet is placed during the match or prior to the match
23. **BET_SIZE**: ? (PRICE_TAKE * Number of Buys?)
24. **PROFIT_LOSS**: Loss of the Bet from BetFair (always a postive number?)

### Questions
1. What are BID_TYP, STATUS_ID, SELECTION_NAME, PERSISTENCE_TYPE and INPLAY_BET

### Thoughts
1. If time & dates (holiday, weekday) have impacts on people's behaviour (e.g. Bet_size)
2. If players behaviour different between different countries, event_type?
3. If players can be segmented based on their transactions history including (frequency, size, recency, favorates to particular events?) and in turn, target the most valuable segments to BetFair.
4. If the data is capable to segment customers into groups like (aggresive/defensive customers) and we are able to see who are always the winners/losers to gambling, also the overall profitabilities of those groups so BetFair may develop an machine learning algorithm to predict those winners behavior and then adjust the bet ratios to maximize/minimize profit/risks of each event.