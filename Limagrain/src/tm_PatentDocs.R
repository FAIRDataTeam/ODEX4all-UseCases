library(solr)
library(httr)
library(jsonlite)
library(tm)
library(tidytext)


setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/Limagrain/src")

## Step 1a: I have created a dictionary in Solr using 3 ontologies located here 

## url<-"http://localhost:8983/solr/terms/select"

patList<-read.csv("../data/excel2016-06-21-10-09-28.csv",header = TRUE)


## Step 1b: I extract this dictionary from Solr here
## dic_key<-solr_search(q='*:*', base=url)

dic_key<- read.csv("../data/keywords.csv",header=FALSE)
dic_key<-as.character(dic_key[,1])

## remove leading and training white spaces
dic_key<-trimws(dic_key)

## remove all special characters and replace them with space
dic_key <- gsub("[[:punct:]]", " ", dic_key)

## remove \x96 from the character vector
dic_key <- gsub("\\\x96"," ",dic_key)


## remove \x92 from the character vector
dic_key <- gsub("\\\x92"," ",dic_key)

## remove \xd7 from the character vector
dic_key <- gsub("\\\xd7"," ",dic_key)


## make dictionary of crop ontologies
dic_CO<-read.csv("CO_322.csv",header=TRUE)
dic_CO<-c(as.character(dic_CO$Trait.name),as.character(dic_CO$Attribute))

## select only unique terms
dic_CO<-unique(dic_CO)


## Combined dictionary keywords + CO terms 
dic_CO_Key<-c(dic_key,dic_CO)



## I create dictionary from title terms
title<-as.character(patList$Title...DWPI)
ll<-NULL
for(i in 1:length(title)){
  ll<-c(ll,unlist(strsplit(title[i]," ")))   
}

## Combined dictionary keywords + CO terms + Title terms
dic_CO_key_title<-c(dic_CO_Key,ll)
dic_CO_key_title<-unique(gsub(",","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub(";","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("\\(e.g.","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("e.g.","",dic_CO_key_title))


## Step 2a: I create corpus here.
abst_dwpi<- as.character(patList$Abstract...DWPI)


## create corpus
dfCorpus_abst_dwpi = Corpus(VectorSource(abst_dwpi)) 


## inspect the overall corpus summary
## VCorpus(VectorSource(abst_dwpi))


## Eliminating extra white spaces

reuters_abst_dwpi<-tm_map(dfCorpus_abst_dwpi,stripWhitespace)
reuters_abst_dwpi<-tm_map(reuters_abst_dwpi,stemDocument)



## convert to lower case
reuters_abst_dwpi <- tm_map(reuters_abst_dwpi, content_transformer(tolower))


## remove stopwords
reuters_abst_dwpi <- tm_map(reuters_abst_dwpi, removeWords, stopwords("english"))


## create a document term matrix with (keywords, CO terms, title terms combined together)
dtm_abst_dwpi_CO_Key_Title <- DocumentTermMatrix(reuters_abst_dwpi,list(dictionary=dic_CO_key_title))




## remove terms that occure in only 0.1% of all documents (in short less common words)
dt_abst_dwpi_CO_Key_Title<-removeSparseTerms(dtm_abst_dwpi_CO_Key_Title, 0.99) # this is tunable 0.6 appears to be optimal


row.names(dt_abst_dwpi_CO_Key_Title)<-patList$Publication.Number



write.csv(as.matrix(dt_abst_dwpi_CO_Key_Title),file="dtm_Abstracts_dwpi_CO_Key_Title.csv")



findFreqTerms(dt_abst_dwpi_CO_Key_Title, 200)

findAssocs(dt_abst_dwpi_CO_Key_Title, "kernel", 0.1)


# to do intersect with dictionary 



## Find terms that occure atleast 5 times or more
## findFreqTerms(dtm_abst, 5)


### find associations for a given term for example "germplasm"
## findAssocs(dtm_abst, "germplasm", 0.5)



