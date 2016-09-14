library(httr)
library(jsonlite)
library(magrittr)
library(yaml)
library(tidyr)
setwd("/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM")

config<-yaml.load_file("config.yml")

## connect to Euretos server with login credentials of 
login <- "http://178.63.49.197:8080/spine-ws/login/authenticate"
pars <- list(
  username =  config$EKP$username,
  password =  config$EKP$password
)

res <- POST(login, body = pars,encode="json",verbose())

token <- content(res)$token


## Search for concept ids 
# Input parameters make sure the single quotes are removed for the term
query = "/external/concepts/search"

###

base_url <- "http://178.63.49.197:8080/spine-ws"


####### DSM work flow starts here ###############


yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)


phenotype <- read.csv("/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM/dropbox/Resistance_terms.txt",header=FALSE)

# separate onto columns
phenotype <- separate(data = phenotype, col = V1, into = c("terms", "class"), sep = "\tequals\t")





# Execute the query
#pr <- POST(url = paste(base_url, query, sep =""), 
#           add_headers('X-token' = token),
#           body=fromJSON('{ "queryString": "term:s000004214", "searchType": "STRING" }'),
#           encode = "json", 
#           accept_json(),verbose())
#a<-content(pr)


## A generic function that takes list of SGD Ids and returns back a table with SGD_Id, Concept_Id and Gene names
getConceptID<-function(terms){
  out<-NULL
  for (i in 1:length(terms)){
    b<-paste("{",'"queryString":"term:',as.character(terms[i]),'","searchType":"STRING"',"}")
    pr <- POST(url = paste(base_url, query, sep =""), 
               add_headers('X-token' = token),
               body=fromJSON(b),
               encode = "json", 
               accept_json(),verbose())
    a<-content(pr)
    #print (a)
    a<-do.call(rbind, lapply(a, data.frame, stringsAsFactors=FALSE))
    a<-cbind(terms[i],a)
    out<-rbind(out,a)
  }
  colnames(out)<-c("Id","EKP_Concept_Id","name")
  return(out)
}


getIndirectRelation<-function(startCId,endCId){
  ## create template for query
  template<-fromJSON(paste('{
      "additionalFields": [
        "semanticCategory", "semanticTypes"
        ],
      "leftInputs": [
        "start"
        ],
      "relationshipWeightAlgorithm": "PWS",
      "rightInputs": [
        "end"
        ],
      "sort": "ASC"
    }'))
  
  out <- NULL
  for (i in 1:length(start$EKP_Concept_Id)){
    template$leftInputs <- "4042036" #start$EKP_Concept_Id[i]
    for (j in 1:length(end$EKP_Concept_Id)){
      template$rightInputs <- "588040"  #end$EKP_Concept_Id[j]
      pr <- POST(url = paste(base_url, query, sep =""), 
                 add_headers('X-token' = token),
                 body=template,
                 encode = "json", 
                 accept_json(),verbose())
      a<-content(pr)
      a
      }
    }
  }



testS<-c("a-maltose")
testE<-c("glucose measurement")

## Step 1a : Get the starting concept identifiers
## start<-getStartConceptID(as.character(yeast_genes[,1]))

start<-getConceptID(as.character(yeast_genes[,1]))

## Step 1b: Get the ending concept identifiers

end <- getConceptID("resistance to chemicals")




write.csv(out,file="Example_output.csv")



##########################################################
#query<- "/external/semantic-categories"
#gr = GET(
#  url = paste(base_url, query, sep =""),
#  add_headers('X-token' = token),
#  body=fromJSON('{"additionalFields": ["egfr"]}'),
#  encode = "json",
#  accept_json()
#)

#content(gr)


### Concept-to-concept direct/indirect query example that works ###############
{
  "additionalFields": [
    "publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes"
    ],
  "leftInputs": [
    "4042036"
    ],
  "relationshipWeightAlgorithm": "PWS",
  "rightInputs": [
    "588040"
    ],
  "sort": "ASC"
}

{
  "additionalFields": [
    "publicationIds", "tripleIds", "predicateIds","semanticCategory", "semanticTypes"
    ],
  "leftInputs": [
    "4042036"
   ],
  "relationshipWeightAlgorithm": "PWS",
  "rightInputs": [
    "588040"
    ],
  "sort": "ASC"
} 




### Fetch the concept id at EKP make sure there are single quotes in the search when it has spaces in it.
# { "queryString": "term:a-maltose", "searchType": "STRING" } 1280049
# { "queryString": "term:'glucose measurement'", "searchType": "STRING" } 3416536


#5258250 # resistance to chemicals concept id
