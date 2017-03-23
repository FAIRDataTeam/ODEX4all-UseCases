#### Step 1: Install and load the required packages 
library(httr)
library(jsonlite)
library(tm)
library(tidytext)
library(wordcloud)
library(dplyr)
library(tidytext)
library(quanteda)
library(SnowballC)

setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/Limagrain/src")
patList<-read.csv("../data/excel2016-06-21-10-09-28.csv",header = TRUE)



#### Step 2a: Load files to create dictionary

dic_key<- read.csv("../data/keywords.csv",header=FALSE)
dic_key<-as.character(dic_key[,1])




##### remove leading and training white spaces
dic_key<-trimws(dic_key)

##### remove all special characters and replace them with space
dic_key <- gsub("[[:punct:]]", " ", dic_key)

##### remove \x96 from the character vector
dic_key <- gsub("\\\x96"," ",dic_key)


##### remove \x92 from the character vector
dic_key <- gsub("\\\x92"," ",dic_key)

##### remove \xd7 from the character vector
dic_key <- gsub("\\\xd7"," ",dic_key)


##### make dictionary of crop ontologies
dic_CO<-read.csv("CO_322.csv",header=TRUE)
dic_CO<-c(as.character(dic_CO$Trait.name),as.character(dic_CO$Attribute))

##### select only unique terms
dic_CO<-unique(dic_CO)


##### Combined dictionary keywords + CO terms 
dic_CO_Key<-c(dic_key,dic_CO)



##### I create dictionary from title terms DWPI
title<-as.character(patList$Title...DWPI)
ll<-NULL
for(i in 1:length(title)){
  ll<-c(ll,unlist(strsplit(title[i]," ")))   
}

##### Combined dictionary keywords + CO terms + Title terms
dic_CO_key_title<-c(dic_CO_Key,ll)
dic_CO_key_title<-unique(gsub(",","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub(";","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("\\(e.g.","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("e.g.","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("/its","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("\\(","",dic_CO_key_title))
dic_CO_key_title<-unique(gsub("\\)","",dic_CO_key_title))
dic_CO_key_title<-dic_CO_key_title[dic_CO_key_title != ""]

##### returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
dic_CO_key_title<-trim(dic_CO_key_title)


##### transform to lower and get unique set of terms
dic_CO_key_title<-unique(tolower(dic_CO_key_title))

##### create key value pair 
val<-dic_CO_key_title
key<-gsub(" ","_",val)
dd<-cbind(key,val)
rownames(dd)<-dd[,1]
dd<-dd[,2]

##### create a key value pair to make dictionary
dfd<-dictionary(dd)

##### Dump of the dictionary consisting of keywords list, Crop Ontology terms and Title terms DWPI

print(dic_CO_key_title)

#### Step 3: Create corpus here.
abst_dwpi<- as.character(patList$Abstract...DWPI)

#### find and replace exact dictionary terms to its corpus
abst_dwpi <- phrasetotoken(abst_dwpi, dfd)



#### atleast now I have multiple words in a matrix
mydfm <- dfm(abst_dwpi, keptFeatures = "*_*")


#### now keep only the keywords from the dictionary
tidy (mydfm) %>%cast_sparse(document,term,count) -> dtm

#### get terms that exists only in dictionary
dtm<-dtm[,which(colnames(dtm)%in%key)]

#### assign documents to the dtm

rownames(dtm)<- as.character(patList$Publication.Number)



##### remove terms that occure in only 0.1% of all documents (in short less common words)
dtm<-removeSparseTerms(dtm, 0.99) # this is tunable 0.6 appears to be optimal




##### create term frequency
termFreq <- colSums(as.matrix(dtm))
head(termFreq)

tf <- data.frame(term = names(termFreq), freq = termFreq)
tf <- tf[order(-tf[,2]),]
head(tf)




#### Step 5: Visualize word cloud of terms

set.seed(1234)
wordcloud(words = tf$term, freq = tf$freq, min.freq = 1,
          max.words=8000, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))



#### Step 6 : Explore frequent terms and their associations

##### frequent terms
findFreqTerms(dt_abst_dwpi_CO_Key_Title, lowfreq = 3)


##### frequent associations
findAssocs(dt_abst_dwpi_CO_Key_Title, terms = "freedom", corlimit = 0.3)


##### plot word frequency
d<-barplot(tf[1:10,]$freq, las = 2, names.arg = tf[1:10,]$term,
           col ="lightblue", main ="Most frequent words",
           ylab = "Word frequencies")




## Reduce the number of features and the only way is to eliminate corelated features  as we do not know class

require(mlbench)
require(caret)

# calculate correlation matrix
correlationMatrix <- cor(d[,1:229])
# summarize the correlation matrix

# find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.2)

## Remove highly correlated terms
d<-d[,-highlyCorrelated]


# print indexes of highly correlated attributes
print(highlyCorrelated)

d<-dd[,colSums(dd)>700]

findFreqTerms(dt_abst_dwpi_CO_Key_Title, 200)

findAssocs(dt_abst_dwpi_CO_Key_Title, "kernel", 0.1)


# to do intersect with dictionary 



## Find terms that occure atleast 5 times or more
## findFreqTerms(dtm_abst, 5)


### find associations for a given term for example "germplasm"
## findAssocs(dtm_abst, "germplasm", 0.5)



