library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)
setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src")
date()
## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.


### Load the API scripts with login credentials

source("/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src/EuretosInfrastructure.R")
options(warn=-1)

### DSM workflow starts here: 
### Load Input data provided by DSM this data consists of a list of yeast genes and a list of terms that represent butanol tolerance

yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)
#phenotype <- read.csv("Resistance_terms.txt",header=FALSE)
# separate onto columns
#phenotype <- separate(data = phenotype, col = V1, into = c("terms", "class"), sep = "\tequals\t")




## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))

query = "/external/concepts/search"
start<-getConceptID(as.character(yeast_genes[,1]))


## remove this head when testing is over
start<-start[,"EKP_Concept_Id"]
## start<-start[1:3]


## Step 1b: Get the ending concept identifiers for "resistance to chemicals"
end <- unlist(getResistanceEKPID())
end<-end["content.id"] #EKP ID of resistance to chemicals


## Step 1c: Get the ending concept identifiers for "butanol tolerance"
end2<- unlist(getButanolID())
end2<-end2["content.id"] # EKP ID of butanol


## Step 2a: Get Indirect relationships between "yeast genes"(start) and "resistance to chemicals"(end)
resistance2Chemicals<-getIndirectRelation(start,end)

## Step 2c: Get Indirect relationships between "yeast genes"(start) and "resistance to Butanol"(end)
resistance2Butanol<-getIndirectRelation(start,end2)


### unconventional way to format strings, but it works
dfs1<-as.matrix(getTableFromJson(resistance2Chemicals))
dfs1[,"Predicate"]<-str_replace_all(dfs1[,"Predicate"], "[^[:alnum:]]","")
dfs1[,"Predicate"]<-str_replace_all(dfs1[,"Predicate"], "c","")
dfs1[,"Publications"]<-str_replace_all(dfs1[,"Publications"], "[^[:alnum:]]","")
dfs1[,"Publications"]<-str_replace_all(dfs1[,"Publications"], "c","")
dfs1<- data.frame(dfs1, stringsAsFactors=FALSE)


### unconventional way to format strings, but it works
dfs2<-as.matrix(getTableFromJson(resistance2Butanol))
dfs2[,"Predicate"]<-str_replace_all(dfs2[,"Predicate"], "[^[:alnum:]]","")
dfs2[,"Predicate"]<-str_replace_all(dfs2[,"Predicate"], "c","")
dfs2[,"Publications"]<-str_replace_all(dfs2[,"Publications"], "[^[:alnum:]]","")
dfs2[,"Publications"]<-str_replace_all(dfs2[,"Publications"], "c","")
dfs2<- data.frame(dfs2, stringsAsFactors=FALSE)


### Step 3: Intersect "resistance to chemicals" and "1-butanol" concepts
comparison <- compare(dfs1,dfs2,allowAll=TRUE)
dfs<-comparison$tM




### Step 4: Map human redable triples from the reference database 
### reference list is collected from EKP
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")


subject_name<-getConceptName(dfs[,"Subject"])
dfs<-cbind(dfs,subject_name[,2])

object_name<-getConceptName(dfs[,"Object"])
dfs<-cbind(dfs,object_name[,2])

predicate_name<-sqldf('select * from dfs left join pred on pred.pred=dfs.Predicate')

tripleName<-cbind(subject_name[,"name"],as.character(predicate_name[,"names"]),object_name[,"name"])


write.table(tripleName,file="/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/triple/app/triple.csv",sep=";")

date()















