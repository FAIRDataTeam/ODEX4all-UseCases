library(dplyr)
library(tidyr)
library(sqldf)
setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src")

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



## Step 1b: Get the ending concept identifiers for "resistance to chemicals"
end <- getConceptID("resistance to chemicals")

## filter only the information related to chemicals
end <- end[which(end$name=="chemicals"),]


## Step 1c: Get the ending concept identifiers for "butanol tolerance"
end2<- getConceptID("butanol tolerance")

## Step 2a: Get Indirect relationships from EKP for ending terms "resistance to chemicals"
resistance2Chemicals<-getIndirectRelation(start,end)

df<-fromJSON(toJSON(resistance2Chemicals),flatten=TRUE)

do.call(rbind,df) %>% as.data.frame ->b

### parse only the relationships
rel<-b[,2]

### collapse into a data frame
dfs<-do.call(rbind,rel)



colnames(dfs)<-c("Subject","Object","ekpTripleID","publicationIds","Predicate")
tt<-fromJSON(toJSON(dfs),flatten = TRUE)
row.names(tt)<-NULL
colnames(tt)<-NULL

tt[,1]<-unlist(tt[,1])
tt[,2]<-unlist(tt[,2])
tt[,5]<-sapply(tt[,5], paste0, collapse=",")
colnames(tt)<-c("sub","obj","ekpid","pubmedid","pred")

tt%>% mutate(pred=strsplit(as.character(pred),",")) %>% unnest(pred) -> tripleId
row.names(tt)<-NULL
tripleId<-tripleId[,c(1,3,2)]



### Step 3: Map human redable triples from the reference database 
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")

subject_name<-getConceptName(dfs[,"Subject"])
dfs<-cbind(dfs,subject_name[,2])

object_name<-getConceptName(dfs[,"Object"])
dfs<-cbind(dfs,object_name[,2])

predicate_name<-sqldf('select * from dfs left join pred on pred.Pred=dfs.predicateIds')

tripleName<-cbind(subject[,2],as.character(predicate[,5]),object[,2])


write.table(tripleName,file="/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/triple/app/triple.csv",sep=";")

















