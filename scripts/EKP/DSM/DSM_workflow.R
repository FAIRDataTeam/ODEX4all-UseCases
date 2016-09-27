library(dplyr)

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

write.csv(dfs,file="Example_output.csv")

















