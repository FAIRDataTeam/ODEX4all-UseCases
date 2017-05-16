library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)
detach(package:RMySQL)


## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.

#### qtaro.abr.affrc.go.jp/qtab/table
setwd("~/odex4all_usecases/ODEX4all-UseCases/Bayer/data")


source("..//src/EuretosInfrastructure.R")
options(warn=-1)


rice_genes <-read.csv("GeneInformationTable_Qtaro.csv",header=TRUE)


### Select only morphological trait as these are associated with concept ids are dynamic (snapsnot date: 08-05-2017)
# "grain size" (EKP concept id : 5899980)
#"grain thickness" (EKP concept id  :5900661)
#"grain number" (EKP concept id (rice specific) :4343608)
#"kernel number" (EKP concept id:5900190)
#"GRNB" (EKP concept:5900394)
#"fruit number" (EKP concept:5900077)
#"grain number per plant" (EKP concept (exact): 5900828)
#"GN" (EKP concept:(vague many hits within EKP))


rice_genes <- select(rice_genes,locus_id,character_major)  
rice_genes <- filter(rice_genes, character_major == "Morphological trait")
rice_genes <- tolower(as.character(rice_genes[,"locus_id"]))
rice_genes <- unique(rice_genes)
rice_genes <- rice_genes[!is.na(rice_genes)]
rice_genes <-rice_genes[rice_genes != "-"]


## Filter for grain size and grain number is not done yet 
### terms_selected<- c("grain size","grain thickness","grain number","kernel number","GRNB","fruit number","grain number per plant","GN")

## Step 1a : Get the starting concept identifiers

start<-getConceptID(rice_genes)
start<-start[,"EKP_Concept_Id"]


## Step 1b: Get the ending concept identifiers for "resistance to chemicals"

trait<-c("TO:0000590","TO:0000382","TO:0000396","TO:0000397","TO:0000734","TO:0000402","TO:0002759","TO:0000447")
traits<-c("grain number","grain size","grain weight","seed yield","grain length","grain width")

### manually curated traid ekp ids in the absensce of taxonomy


end<-NULL
for (i in 1:length(traits)){
  tmp <- getTraitEKPID(traits[i])
  tmpContent<-tmp[,"content.id"]
  end<-rbind(end,tmpContent)
}


end<-end[2]

#end<-end["content.id"] #EKP ID TO terms from Bayer



## Step 2a: Get Indirect relationships between "rice genes"(start) and "grain number"(end)
genes2GrainNumber<-getIndirectRelation(start,end)
save(genes2GrainNumber, file = "genes2GrainNumber.rda")


load("genes2GrainNumber.rda")

### Formatting and data cleaning
dfs<-as.matrix(getTableFromJson(genes2GrainNumber))
dfs[,"Predicate"]<-str_replace_all(dfs[,"Predicate"], "[^[:alnum:]]","")
dfs[,"Predicate"]<-str_replace_all(dfs[,"Predicate"], "c","")
dfs[,"Publications"]<-str_replace_all(dfs[,"Publications"], "[^[:alnum:]]","")
dfs[,"Publications"]<-str_replace_all(dfs[,"Publications"], "c","")
dfs<- data.frame(dfs, stringsAsFactors=FALSE)


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

write.table(tripleName,file="/home/anandgavai/odex4all_usecases/ODEX4all-UseCases/Bayer/src/triples.csv",sep=",",row.names = FALSE)


### cross validation