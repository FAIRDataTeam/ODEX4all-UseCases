library(dplyr)
library(tidyr)
library(sqldf)
setwd("/home/anandgavai/AARestructure/ODEX4all-UseCases/DSM/src")

## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.


### Load the API scripts with login credentials

source("EuretosInfrastructure.R")
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



## Step 2: Get Indirect relationships from EKP for ending terms "resistance to chemicals"
resistance2Chemicals<-getIndirectRelation(start,end)

df<-fromJSON(toJSON(resistance2Chemicals),flatten=TRUE)

do.call(rbind,df) %>% as.data.frame ->b

### parse only the relationships
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

tt%>% mutate(pred=strsplit(as.character(pred),",")) %>% unnest(pred) -> tripleId
row.names(tt)<-NULL
tripleId<-tripleId[,c(1,3,2)]



### Step 3: Map human redable triples from the reference database 
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")

subject<-getConceptName(tripleId[,1])
object<-getConceptName(tripleId[,3])
predicate<-sqldf('select * from tripleId left join pred on pred.Pred=tripleId.Pred')

tripleName<-cbind(subject[,2],as.character(predicate[,5]),object[,2])


write.table(tripleName,file="/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM/triple/app/triple.csv",sep=";")

















