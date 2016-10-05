library(dplyr)
library(tidyr)
library(sqldf)
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



## Step 3: Map human redable triples from the reference database 
pred<-read.csv("Reference_Predicate_List.csv",header=TRUE)
pred<-pred[,c(2,3)]
colnames(pred)<-c("pred","names")

subject<-getConceptName(tripleId[,1])
object<-getConceptName(tripleId[,3])
predicate<-sqldf('select * from tripleId left join pred on pred.Pred=tripleId.Pred')

tripleName<-cbind(subject[,2],as.character(predicate[,5]),object[,2])



## Step 4: Integrate SGD phenotype data and biological process with the results from EKP

phenotype_data<-read.csv("phenotype_data.tab",header=FALSE,sep="\t")

#1) Feature Name (Mandatory)     		-The feature name of the gene
#2) Feature Type (Mandatory)     		-The feature type of the gene	
#3) Gene Name (Optional) 			-The standard name of the gene
#4) SGDID (Mandatory)    			-The SGDID of the gene
#5) Reference (SGD_REF Required, PMID optional)  -PMID: #### SGD_REF: #### (separated by pipe)(one reference per row)
#  6) Experiment Type (Mandatory)     		-The method used to detect and analyze the phenotype
#7) Mutant Type (Mandatory)      		-Description of the impact of the mutation on activity of the gene product
#8) Allele (Optional)    			-Allele name and description, if applicable
#9) Strain Background (Optional) 		-Genetic background in which the phenotype was analyzed
#10) Phenotype (Mandatory)       		-The feature observed and the direction of change relative to wild type
#11) Chemical (Optional) 			-Any chemicals relevant to the phenotype
#12) Condition (Optional)        		-Condition under which the phenotype was observed
#13) Details (Optional)  			-Details about the phenotype
#14) Reporter (Optional) 			-The protein(s) or RNA(s) used in an experiment to track a process 


colnames(phenotype_data)<-c("Feature_Name","Feature_Type","Gene_Name","SGDID","PMID","Expt_Type","Mutant_Type","Allele","Strain_Background","Phenotype","Chemical","Condition","Details","Reporter")
yeast_genes[,1]<-toupper(as.character(yeast_genes[,1]))

## Select only the necessary information (Phenotype) from phenotype database ** more information can be extracted

phenotype_data<-select(phenotype_data,SGDID,Phenotype)
phenotype_data<-unique(phenotype_data)



write.table(tripleName,file="/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM/triple/app/triple.csv",sep=";")

















