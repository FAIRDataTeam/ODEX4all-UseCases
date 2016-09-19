source("EuretosInfrastructure.R")


####### DSM work flow starts here ###############
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
end1 <- getConceptID("resistance to chemicals")



## Step 1c: Get the ending concept identifiers for "butanol tolerance"
query = "/external/concepts/search"
end2 <- getConceptID("resistance to butan-1-ol")


## Get Indirect relationships
query = "/external/concept-to-concept/indirect"
d<-getIndirectRelation(start,end1)

d1<-getIndirectRelation(start,end2)


write.csv(out,file="Example_output.csv")

