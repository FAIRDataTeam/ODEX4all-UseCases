library(solr)
library(httr)
library(jsonlite)
library(tm)


setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/Limagrain/src")

## Step 1a: I have created a dictionary in Solr using 3 ontologies located here 

url<-"http://localhost:8983/solr/terms/select"

## Step 1b: I extract this dictionalry from Solr here
dic<-solr_search(q='*:*', base=url)


## Step 2a: I create corpus here.

patList<-read.csv("../data/patent_list.csv",header=TRUE)

abst<- as.character(patList$Abstract)

dfCorpus = Corpus(VectorSource(abst)) 

## inspect the overall corpus summary
VCorpus(VectorSource(abst))


## Eliminating extra white spaces

reuters<-tm_map(dfCorpus,stripWhitespace)


## convert to lower case

reuters <- tm_map(reuters, content_transformer(tolower))

## remove stopwords

reuters <- tm_map(reuters, removeWords, stopwords("english"))


## Stemming

stem_reuters<-tm_map(reuters, stemDocument)
