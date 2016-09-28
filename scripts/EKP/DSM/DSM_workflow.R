library(dplyr)
library(tidyr)
setwd("/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM")

## Introduction: To identify genotype-phenotype relationships for yeast genes related to butanol tolerance using the Euretos Knowledge platform 



### Setup the workflow Infrastructure

source("EuretosInfrastructure.R")
options(warn=-1)

#### DSM workflow starts here 
##### Load Input data provided by DSM this data consists of a list of yeast genes and a list of terms that represent butanol tolerance

yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)
phenotype <- read.csv("/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM/dropbox/Resistance_terms.txt",header=FALSE)
# separate onto columns
phenotype <- separate(data = phenotype, col = V1, into = c("terms", "class"), sep = "\tequals\t")




## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))

query = "/external/concepts/search"
start<-getConceptID(as.character(yeast_genes[,1]))



## Step 1b: Get the ending concept identifiers for "resistance to chemicals"

query = "/external/concepts/search"
end <- getConceptID("resistance to chemicals")



## Step 2a: Get Indirect relationships from EKP for ending terms "resistance to chemicals"
query = "/external/concept-to-concept/indirect"
resistance2Chemicals<-getIndirectRelation(start,end)

df<-fromJSON(toJSON(resistance2Chemicals),flatten=TRUE)

do.call(rbind,df) %>% as.data.frame ->b

### Get only the relationships

rel<-b[,2]

### collapse into a list
dfs<-do.call(rbind,rel)


tt<-fromJSON(toJSON(dfs),flatten = TRUE)
row.names(tt)<-NULL
colnames(tt)<-NULL

tt[,1]<-unlist(tt[,1])
tt[,2]<-unlist(tt[,2])
tt[,3]<-sapply(tt[,3], paste0, collapse=",")
colnames(tt)<-c("sub","obj","pred")

tt%>% mutate(pred=strsplit(as.character(pred),",")) %>% unnest(pred) -> predSplit
row.names(tt)<-NULL



### Get Predicate names #########
query = "/external/predicates"
predicates<- getPredicateName()

pred<-fromJSON(toJSON(predicates),flatten = TRUE)

mat<-NULL
for (i in 1:length(pred)){
  id<-unlist(pred[[i]]$id)  
  name<-unlist(pred[[i]]$name)
  t<-cbind(id,name)
  mat<-rbind(mat,t)
}
mat<-as.data.frame(mat)
merge(predSplit,mat,by="id")


#### Create predicate list for future reference
write.csv(mat,file="Reference_Predicate_List.csv")





write.table(predSplit,file="/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM/triple/app/triple.csv",sep=";")

















