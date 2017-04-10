library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)
setwd("/home/anandgavai/odex4all_usecases/ODEX4all-UseCases/DSM/src")
date()
## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.


### Load the API scripts with login credentials

source("/home/anandgavai/odex4all_usecases/ODEX4all-UseCases/DSM/src/EuretosInfrastructure.R")
options(warn=-1)

### DSM workflow starts here: 
### Load Input data provided by DSM this data consists of a list of yeast genes and a list of terms that represent butanol tolerance

#yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)
yeast_genes<-read.csv("20170119_GeneList_DSM.txt",header=TRUE,sep="\t")
yeast_genes<-head(yeast_genes)
#phenotype <- read.csv("Resistance_terms.txt",header=FALSE)
# separate onto columns
#phenotype <- separate(data = phenotype, col = V1, into = c("terms", "class"), sep = "\tequals\t")




## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))

start<-getConceptID(tolower(as.character(yeast_genes[,"SGD_ID"])))

start<-start[,"EKP_Concept_Id"]
start<-head(start)
## start<-start[1:3]


## Step 1b: Get the ending concept identifiers for "butanols :- 2479403"

end <- getConceptID("butanols")
end<-end[,"EKP_Concept_Id"] #EKP ID of resistance to chemicals

## Step 2a: Get Indirect relationships between "yeast genes"(start) and "resistance to chemicals"(end)
indirectRelationButanol<-getIndirectRelation(start[1],end)


### Formatting and data cleaning
dfs1<-as.matrix(getTableFromJson(indirectRelationButanol))






### Step 4: Map human redable triples from the reference database 
### reference list is collected from EKP
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")


subject_name<-getConceptName(dfs1[,"Subject"])
dfs<-cbind(dfs1,subject_name[,2])

object_name<-getConceptName(dfs[,"Object"])
dfs<-cbind(dfs,object_name[,2])

predicate_name<-sqldf('select * from dfs left join pred on pred.pred=dfs.Predicate')

pbs<-getPubMedId(dfs$Publications)

tripleName<-cbind(subject_name[,"name"],as.character(predicate_name[,"names"]),object_name[,"name"],dfs[,"Publications"],dfs[,"Score"])
colnames(tripleName)<-c("Subject","Predicate","Object","Provenance","Score")

write.table(tripleName,file="/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src/triples.csv",sep=",",row.names = FALSE)

date()

#### Post processing: Results ################
setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src")
start<-as.data.frame(start)

triples<-read.csv("triples.csv",header=TRUE)

freqSubject<-table(triples$Subject)

freqObject<-table(triples$Object)
concept_Subject<-names(freqSubject)  
idxSub<-which (concept_Subject %in% start$content.name)

s<-as.data.frame(sort(freqSubject[idxSub],decreasing = TRUE))
o<-as.data.frame(as.matrix(freqObject))

freqObject[idxObj]







