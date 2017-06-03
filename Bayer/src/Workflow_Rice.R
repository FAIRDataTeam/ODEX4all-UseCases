
## Objective: To identify genotype-phenotype trait association in Rice
### Develop a workflow to identify genes indirectly associated with rice traits (Grain Size, Grain number etc) using EKP and visualize them in an interactive knowledge graph.


## Load necessary libraries
library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)




## Set working environment and load EKP api
setwd("~/ODEX4all-UseCases/Bayer/data")

source("..//src/EuretosInfrastructure.R")
options(warn=-1)


#### Load selected genes from Qtaro database found at qtaro.abr.affrc.go.jp/qtab/table
rice_genes <-read.csv("GeneInformationTable_Qtaro_Selected.csv",header=TRUE)


#### Here we consider only the following morphological trait as specified in the input provided
#### "grain size" (EKP concept id : 5899980)
#### "grain thickness" (EKP concept id  :5900661)
#### "grain number" (EKP concept id (rice specific) :4343608)
#### "kernel number" (EKP concept id:5900190)
#### "GRNB" (EKP concept:5900394)
#### "fruit number" (EKP concept:5900077)
#### "grain number per plant" (EKP concept (exact): 5900828)
#### "GN" (EKP concept:(vague many hits within EKP))

head(rice_genes)



## Step 1a : Get the starting concept identifiers for genes

start<-getConceptID(rice_genes[,"locus_id"])
start<-start[,"EKP_Concept_Id"]

head(start)


## Step 1b: Get the ending concept identifiers for  traits

traits<-c("TO:0000590","TO:0000382","TO:0000396","TO:0000397","TO:0000734","TO:0000402","TO:0002759","TO:0000447")



### Get Trait ekp ids for ending concepts 
end<-NULL
for (i in 1:length(traits)){
  tmp <- getTraitEKPID(traits[i])
  tmpContent<-cbind(traits[i],tmp)
  end<-rbind(end,tmpContent)
}
end<-end[,c(2,3,4)]
colnames(end)<-c("TOid","TOEKPid","TOContentName")

head(end)


### Step 2a: Get indirect relationship for connected traits
### for the traits that exists within EKP and save intermediate results

genes2Trait<-getIndirectRelation(start,end[c(3,7,8),"TOEKPid"])
save(genes2Trait, file = "genes2Trait.rda")

head(genes2Trait)



### Step 2b: Get Indirect relationships for "Trait Neighbours"(end) and save intermediate results

neig<-read.csv("NeighbouringTraitEKPid.csv",stringsAsFactors = FALSE,header=TRUE)
genes2TraitNeighbours<-getIndirectRelation(start,end[c(3,7,8),"TOEKPid"])
save(genes2TraitNeighbours, file = "genes2TraitNeighbours.rda")

head(genes2TraitNeighbours)



### Step 2c: Now get the relationship between Traits and their Neighbours and save intermediate results
Trait2TraitNeighbours<-getIndirectRelation(unique(neig[,1]),unique(neig[,2]))
save(Trait2TraitNeighbours, file = "Trait2TraitNeighbours.rda")

head(Trait2TraitNeighbours)



### Step 2d: Get Direct relationship between genes and traits and save intermediate results
genes2TraitsDirect<-getIndirectRelation(start,end[,"TOEKPid"])
save(genes2TraitsDirect, file = "genes2TraitsDirect.rda")

head(genes2TraitsDirect)



### Step 3: Combine the results together
load("genes2Trait.rda")
load("genes2TraitNeighbours.rda")
load("Traits_and_their_neighbours.rda")
load("genes2TraitsDirect.rda")

genes2Trait<-as.matrix(getTableFromJson(genes2Trait))

genes2TraitNeighbours<-as.matrix(getTableFromJson(genes2TraitNeighbours))

Traits_and_their_neighbours<-as.matrix(getTableFromJson(a))

genes2TraitsDirect <- as.matrix(getTableFromJson(genes2TraitsDirect))



dfs<-data.frame(unique(rbind(genes2Trait,genes2TraitNeighbours,Traits_and_their_neighbours,genes2TraitsDirect)))

head(dfs)


### Step 4: Map human redable triples from the reference database 
### reference list is collected from EKP
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")


subject_name<-getConceptName(dfs[,"Subject"])
dfs<-cbind(dfs,subject_name[,1])

object_name<-getConceptName(dfs[,"Object"])
dfs<-cbind(dfs,object_name[,1])

predicate_name<-sqldf('select * from dfs left join pred on pred.pred=dfs.Predicate')

pbs<-getPubMedId(dfs$Publications)

tripleName<-cbind(subject_name,as.character(predicate_name[,"names"]),object_name,pbs,as.character(dfs[,"Score"]))
colnames(tripleName)<-c("Subject","Predicate","Object","Provenance","Score")

write.table(tripleName,file="~/ODEX4all-UseCases/Bayer/data/Results_Genes_Traits.csv",sep=",",row.names = FALSE)

