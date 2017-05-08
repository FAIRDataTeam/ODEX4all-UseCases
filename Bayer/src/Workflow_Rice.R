library(dplyr)
library(tidyr)
library(sqldf)
library(splitstackshape)
library(stringr)
library(compare)
detach(package:RMySQL)


## Objective: To identify genotype-phenotype trait association in yeast
### Develop a workflow to identify genes indirectly associated with a certain yeast phenotype (butanol tolerance) using EKP and visualize them in an interactive knowledge graph.

source("..//src/EuretosInfrastructure.R")
options(warn=-1)

#### qtaro.abr.affrc.go.jp/qtab/table
setwd("~/odex4all_usecases/ODEX4all-UseCases/Bayer/data")

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


rice_genes <- select(rice_genes,gene_symbol,character_major)  
rice_genes<- filter(rice_genes, character_major == "Morphological trait")
rice_genes<- tolower(as.character(rice_genes[,"gene_symbol"]))
rice_genes <- unique(rice_genes)


rice_genes<-gsub(";","",rice_genes)
rice_genes<-gsub("-","",rice_genes)

## Filter for grain size and grain number is not done yet 
### terms_selected<- c("grain size","grain thickness","grain number","kernel number","GRNB","fruit number","grain number per plant","GN")

## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))
getConceptID(head(rice_genes,n=1))

start<-getConceptID(head(rice_genes,n=10)))

