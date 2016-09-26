
############################################

#####  Setup the Infrastructure  ####

###########################################
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
#query = "/external/concepts/search"

### Setting up the base url for Euretos Knowledge platform 
base_url <- "http://178.63.49.197:8080/spine-ws"






## A generic function that takes list of SGD Ids and returns back a table with SGD_Id, Concept_Id and Gene names
### double quotes are embeded in single q
## "quotes are not necessary inside square braces"
out<-NULL
getConceptID<-function(terms){
  for (i in 1:length(terms)){
    b<-paste("{",'"queryString":"term:',as.character(terms[i]),'","searchType":"STRING"',"}",sep="")
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


## Get indirect relationships at this URL
getIndirectRelation<-function(start,end){
  d<-NULL
  for (i in 1:length(start$EKP_Concept_Id)){
    for (j in 1:length(end$EKP_Concept_Id)){
      template<-paste("{",'"additionalFields": ["semanticCategory"]',",",'"leftInputs":[',start$EKP_Concept_Id[i],']',",",'"rightInputs":[',end$EKP_Concept_Id[j],']',"}",sep="")
      template<-fromJSON(template,simplifyVector = FALSE)
                 pr <- POST(url = paste(base_url, query, sep =""), 
                 add_headers('X-token' = token),
                 body=template,
                 encode = "json", 
                 accept_json(),verbose())
      a<-content(pr)
      a<-unlist(a)
      if(a[["totalElements"]]>0){
        d<-rbind(d,a)
      }
    }
  }
  return(d)
  }


##########################################################

#           Examples to run queries                      #
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
#template<-fromJSON('{
#  "additionalFields": [
#    "publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes"
#    ],
#  "leftInputs": [
#    "start"
#    ],
#  "relationshipWeightAlgorithm": "PWS",
#  "rightInputs": [
#    "end"
#    ],
#  "sort": "ASC"
#}')

### Fetch the concept id at EKP make sure there are single quotes in the search when it has spaces in it.
# { "queryString": "term:a-maltose", "searchType": "STRING" } 1280049
# { "queryString": "term:'glucose measurement'", "searchType": "STRING" } 3416536


#5258250 # resistance to chemicals concept id
