setwd('/Users/ivanliu/Google Drive/Melbourne Datathon/Melbourne_Datathon')
rm(list=ls()); gc()

require(data.table); require(bit64)

trans <- fread('data/DSMDatathon_samplefile.txt', data.table = F, stringsAsFactors = F, 
               colClasses = c('interger','interger','interger','interger','character','interger','interger',
                              'character','character','character','character','character','character','character',
                              'character','character','character','character','character','numeric','numeric',
                              'character','numeric','numeric'))
head(trans); dim(trans); str(trans)
attach(trans)
table(COUNTRY_OF_RESIDENCE_NAME)