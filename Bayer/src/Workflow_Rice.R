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

traits<-c("TO:0000590","TO:0000382","TO:0000396","TO:0000397","TO:0000734","TO:0000402","TO:0002759","TO:0000447")
#                                                "5899980"
#traits<-c("grain number","grain size","grain weight","seed yield","grain length","grain width")

#                   EKP_Id
# grain size            : 5899980
# grain thickness       : 5900661
# grain number          : 4343608
# kernal number         : 5900190
# GRNB                  : 5900394
#fruit number           : 5900077
#grain number per plant : 5900828



### Trait ekp ids 
end<-NULL
for (i in 1:length(traits)){
  tmp <- getTraitEKPID(traits[i])
  tmpContent<-cbind(traits[i],tmp)
  end<-rbind(end,tmpContent)
}
end<-end[,c(2,3,4)]
colnames(end)<-c("TOid","TOEKPid","TOContentName")

head(end)


### Now get the neighbours of traits because there have no indirect relations between genes and traits that can be found within EKP
neighbours<-NULL
for (i in 1:length(end)){
  tmp <- unlist(getNeighbours(end[i]))
  tmp<-tmp[which(names(unlist(tmp))%in% "content.neighbour.id"==TRUE)]
  addEKPId<-cbind(end[i],tmp)
  neighbours<-rbind(neighbours,addEKPId)  
}
colnames(neighbours)<-c("TOEKPid","NeighbourEKPid")
rownames(neighbours)<-NULL
write.csv(neighbours,file="NeighbouringTraitEKPid.csv",row.names = FALSE)


## Step 2a: Get Indirect relationships between "rice genes"(start) and "Trait Neighbours"(end)
## grain size testing

## 
## end<-"5900394"
## start <- "3942239"
## use these identifiers for 
# "TO:0000396" "5900965" "grain yield trait"    
# "TO:0002759" "5900394" "grain number"         
# "TO:0000447" "5900594" "filled grain number" 


### Gets the JSON objects from EKP API
system("bash Get_TO:0000396.sh")
system("bash Get_TO:0000396.sh")
system("bash Get_TO:0000396.sh")


#genes2TraitNeighbour<-getIndirectRelation(start,end[c(3,7,8),"TOEKPid"])
#save(genes2TraitNeighbour, file = "genes2TraitNeighbour.rda")


store <- paste0('"', paste(start, collapse="\", \""), '"')


### Read the JSON objects just created
document1 <- fromJSON(txt="int_TO:0000396.json",flatten=TRUE)$content
document2 <- fromJSON(txt="int_TO:0002759.json",flatten=TRUE)$content
document3 <- fromJSON(txt="int_TO:0000447.json",flatten=TRUE)$content

### Combine the documents together
genes2Traits <- list(document1,document2,document3)
df<-fromJSON(toJSON(genes2Traits),flatten=TRUE)
do.call(rbind,df) %>% as.data.frame -> genes2Traits


### Now use the neighbours of the Traits where the relationship was not identified
## use these identifiers for 
## "TO:0000590" "5899973" "dehulled grain weight"
## "TO:0000382" "5900098" "1000-seed weight"  
## "TO:0000397" "5899980" "grain size"           
## "TO:0000734" "5900194" "grain length" 
## "TO:0000402" "5899965" "grain width"  

###!!!!!!! use the excel sheet
###genes2TraitNeighbourNot<-getIndirectRelation(start,end[c(1,2,4,5,6),"TOEKPid"])
###save(genes2TraitNeighbourNot, file = "genes2TraitNeighbourNot.rda")




neig<-read.csv("NeighbouringTraitEKPid.csv",stringsAsFactors = FALSE,header=TRUE)
tstStr<-c("5899973","5900098","5899980","5900194","5899965")

sel<-subset(neig,TOEKPid %in% tstStr)
sel<- sel$NeighbourEKPid
#selStore <-paste0('"', paste(sel, collapse="\", \""), '"')
#start <- paste0('"', paste(start, collapse="\", \""), '"')



### Now call get indirect relationships for remaining traits (proxy for their neighbours)
system ("bash Get_TO:0000590_TO:0000382_TO:0000397_TO:0000734_TO:0000402.sh")

genes2TraitNeighbour <- fromJSON(txt="int_TO:0000590_TO:0000382_TO:0000397_TO:0000734_TO:0000402.json")$content

## Combine the two traits
overallTraitRelations<-rbind(genes2Traits,genes2TraitNeighbour)

### Formatting and data cleaning
dfs<-as.matrix(getTableFromJson(overallTraitRelations))
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
dfs<-cbind(dfs,subject_name[,1])

object_name<-getConceptName(dfs[,"Object"])
dfs<-cbind(dfs,object_name[,1])

predicate_name<-sqldf('select * from dfs left join pred on pred.pred=dfs.Predicate')

pbs<-getPubMedId(dfs$Publications)

tripleName<-cbind(subject_name,as.character(predicate_name[,"names"]),object_name,pbs,dfs[,"Score"])
colnames(tripleName)<-c("Subject","Predicate","Object","Provenance","Score")

write.table(tripleName,file="/home/anandgavai/odex4all_usecases/ODEX4all-UseCases/Bayer/data/Results_TO:0000396_TO:0002759_TO:0000447_TO:0000590_TO:0000382_TO:0000397_TO:0000734_TO:0000402.csv",sep=",",row.names = FALSE)


### cross validation