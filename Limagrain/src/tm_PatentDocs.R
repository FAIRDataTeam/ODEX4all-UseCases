library(solr)
library(httr)
library(jsonlite)
library(tm)
library(tidytext)


setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/Limagrain/src")

## Step 1a: I have created a dictionary in Solr using 3 ontologies located here 

## url<-"http://localhost:8983/solr/terms/select"

## Step 1b: I extract this dictionary from Solr here
## dic<-solr_search(q='*:*', base=url)

dic<- read.csv("../data/keywords.csv",header=FALSE)
dic<-as.character(dic[,1])

## remove leading and training white spaces
dic<-trimws(dic)

## remove all special characters and replace them with space
dic <- gsub("[[:punct:]]", " ", dic)

## remove \x96 from the character vector
dic <- gsub("\\\x96"," ",dic)


## remove \x92 from the character vector
dic <- gsub("\\\x92"," ",dic)

## remove \xd7 from the character vector
dic <- gsub("\\\xd7"," ",dic)


## make dictionary of crop ontologies
dic_CO<-read.csv("CO_322.csv",header=TRUE)
dic_CO<-c(as.character(dic_CO$Trait.name),as.character(dic_CO$Attribute))

## select only unique terms
dic_CO<-unique(dic_CO)

## Step 2a: I create corpus here.

patList<-read.csv("../data/excel2016-06-21-10-09-28.csv",header = TRUE)


abst<- as.character(patList$Abstract)
abst_dwpi<- as.character(patList$Abstract...DWPI)

title_terms_dwpi<-as.character(patList$Title.Terms...DWPI)



## create corpus
dfCorpus_abst = Corpus(VectorSource(abst)) 
dfCorpus_abst_dwpi = Corpus(VectorSource(abst_dwpi)) 

dfCorpus_title_terms_dwpi = Corpus(VectorSource(title_terms_dwpi)) 


## inspect the overall corpus summary
## VCorpus(VectorSource(abst_dwpi))


## Eliminating extra white spaces

reuters_abst<-tm_map(dfCorpus_abst,stripWhitespace)
reuters_abst<-tm_map(reuters_abst,stemDocument)


reuters_abst_dwpi<-tm_map(dfCorpus_abst_dwpi,stripWhitespace)
reuters_abst_dwpi<-tm_map(reuters_abst_dwpi,stemDocument)



reuters_title_terms_dwpi<-tm_map(dfCorpus_title_terms_dwpi,stripWhitespace)
reuters_title_terms_dwpi<-tm_map(reuters_title_terms_dwpi,stemDocument)


## convert to lower case

reuters_abst <- tm_map(reuters_abst, content_transformer(tolower))
reuters_abst_dwpi <- tm_map(reuters_abst_dwpi, content_transformer(tolower))

reuters_title_terms_dwpi <- tm_map(reuters_title_terms_dwpi, content_transformer(tolower))

## remove stopwords

reuters_abst <- tm_map(reuters_abst, removeWords, stopwords("english"))
reuters_abst_dwpi <- tm_map(reuters_abst_dwpi, removeWords, stopwords("english"))
reuters_title_terms_dwpi <- tm_map(reuters_title_terms_dwpi, removeWords, stopwords("english"))


## create a document term matrix with dic (keywords)
dtm_abst <- DocumentTermMatrix(reuters_abst,list(dictionary=dic))
dtm_abst_dwpi <- DocumentTermMatrix(reuters_abst_dwpi,list(dictionary=dic))
dtm_title_terms_dwpi<-DocumentTermMatrix(reuters_title_terms_dwpi,list(dictionary=dic))



## create a document term matrix with dic_CO (CO terms based on "trait name" and "attribute" terms)
dtm_abst_CO <- DocumentTermMatrix(reuters_abst,list(dictionary=dic_CO))
dtm_abst_dwpi_CO <- DocumentTermMatrix(reuters_abst_dwpi,list(dictionary=dic_CO))
dtm_title_terms_dwpi_CO<-DocumentTermMatrix(reuters_title_terms_dwpi,list(dictionary=dic_CO))




## remove terms that occure in only 0.1% of all documents (in short less common words)
dt_abst<-removeSparseTerms(dtm_abst, 0.99) # this is tunable 0.6 appears to be optimal
dt_abst_dwpi<-removeSparseTerms(dtm_abst_dwpi, 0.99) # this is tunable 0.6 appears to be optimal
dt_title_terms_dwpi<-removeSparseTerms(dtm_title_terms_dwpi, 0.99) # this is tunable 0.6 appears to be optimal

## remove terms that occure in only 0.1% of all documents (in short less common words)
dt_abst_CO<-removeSparseTerms(dtm_abst_CO, 0.99) # this is tunable 0.6 appears to be optimal
dt_abst_dwpi_CO<-removeSparseTerms(dtm_abst_dwpi_CO, 0.99) # this is tunable 0.6 appears to be optimal
dt_title_terms_dwpi_CO<-removeSparseTerms(dtm_title_terms_dwpi_CO, 0.99) # this is tunable 0.6 appears to be optimal




row.names(dt_abst)<-patList$Publication.Number
row.names(dt_abst_dwpi)<-patList$Publication.Number
row.names(dt_title_terms_dwpi)<-patList$Publication.Number

row.names(dt_abst_CO)<-patList$Publication.Number
row.names(dt_abst_dwpi_CO)<-patList$Publication.Number
row.names(dt_title_terms_dwpi_CO)<-patList$Publication.Number


intersect(colnames(as.matrix(dt_abst_dwpi)),colnames(as.matrix(dt_abst_dwpi_CO)))


write.csv(as.matrix(dt_abst),file="dtm_Abstracts_CO.csv")
write.csv(as.matrix(dt_abst_dwpi),file="dtm_Abstracts_dwpi_CO.csv")
write.csv(as.matrix(dt_title_terms_dwpi),file="dtm_title_terms_dwpi_CO.csv")



findFreqTerms(dt_abst, 5)

findAssocs(dt_abst_dwpi, "locus", 0.1)


# to do intersect with dictionary 



## Find terms that occure atleast 5 times or more
## findFreqTerms(dtm_abst, 5)


### find associations for a given term for example "germplasm"
## findAssocs(dtm_abst, "germplasm", 0.5)



