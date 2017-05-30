library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)
detach(package:RMySQL)

setwd("~/ODEX4all-UseCases/DSM/src")
date()
## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.


### Load the API scripts with login credentials

source("../src/EuretosInfrastructure.R")
options(warn=-1)

### DSM workflow starts here: 
### Load Input data provided by DSM this data consists of a list of yeast genes and a list of terms that represent butanol tolerance

#yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)
yeast_genes<-read.csv("20170119_GeneList_DSM.txt",header=TRUE,sep="\t")
#phenotype <- read.csv("Resistance_terms.txt",header=FALSE)
# separate onto columns
#phenotype <- separate(data = phenotype, col = V1, into = c("terms", "class"), sep = "\tequals\t")


## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))

start<-getConceptID(tolower(as.character(yeast_genes[,"SGD_ID"])))

start<-start[,"EKP_Concept_Id"]
#start <- paste0('"', paste(start, collapse="\", \""), '"')


## Step 1b: Get the ending concept identifiers for "resistance to chemicals"
end <- unlist(getResistanceEKPID())
end<-end["content.id"] #EKP ID of resistance to chemicals


## Step 1c: Get the ending concept identifiers for "butanol tolerance"
end2<- unlist(getButanolID())
end2<-end2["content.id"] # EKP ID of butanol


## Step 2a: Get Indirect relationships between "yeast genes"(start) and "resistance to chemicals"(end)
resistance2Chemicals<-getIndirectRelation(start,end)
#r2C <- fromJSON(txt="resistance2Chemicals.json",flatten=TRUE)$content
save(resistance2Chemicals, file = "resistance2Chemicals.rda")




## Step 2b: Get Indirect relationships between "yeast genes"(start) and "resistance to Butanol"(end)
resistance2Butanol<-getIndirectRelation(start,end2)
#r2B <- fromJSON(txt="resistance2Butanol.json",flatten=TRUE)$content
save(resistance2Butanol, file = "resistance2Butanol.rda")


load("resistance2Chemicals.rda")
### Formatting and data cleaning
dfs1<-as.matrix(getTableFromJson(resistance2Chemicals))
dfs1<- data.frame(dfs1, stringsAsFactors=FALSE)


load("resistance2Butanol.rda")
### Formatting and data cleaning
dfs2<-as.matrix(getTableFromJson(resistance2Butanol))
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

pbs<-getPubMedId(dfs$Publications)

tripleName<-cbind(subject_name[,"name"],as.character(predicate_name[,"names"]),object_name[,"name"],dfs[,"Publications"],dfs[,"Score"])
colnames(tripleName)<-c("Subject","Predicate","Object","Provenance","Score")

write.table(tripleName,file="~/ODEX4all-UseCases/DSM/src/ConceptsRelatedwithButanolTriples.csv",sep=",",row.names = FALSE)



#### Post processing: Results ################

### Summaring the result for the data #####

gr2c<-filter(dfs1,Subject==start)  ## genes involving resistance to chemicals 

gr2b<-filter(dfs2,Subject==start)  ## genes involving resistance to chemicals 


interRC_RB<-intersect(gr2c[,1],gr2b[,1])

### Genes pre9



DSM_Genes <- getConceptName(gr2b[,"Subject"])

relationship <- sqldf('select * from gr2b left join pred on pred.pred=gr2b.Predicate')
relationship<- relationship$names

represent<-cbind(DSM_Genes,gr2b$Score,relationship)
pubmedID<-getPubMedId(gr2b$Publications)

represent<-cbind(represent,relationship,pubmedID)

represent<-represent[,c("name","gr2b$Score","relationship","V2")]

names(represent)<-c("DSMGenes","AssociationScoreButanol","RelationshipBtwGenesButanol","Publications")

                
