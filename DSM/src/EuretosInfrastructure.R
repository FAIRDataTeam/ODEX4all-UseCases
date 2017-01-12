
############################################

#####  Setup the Infrastructure  ####

###########################################
library(httr)
library(jsonlite)
library(magrittr)
library(yaml)
library(tidyr)

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
  query = "/external/concepts/search"
  for (i in 1:length(terms)){
    b<-paste("{",'"queryString":"term:',as.character(terms[i]),'","searchType":"STRING"',"}",sep="")
    pr <- POST(url = paste(base_url, query, sep =""), 
               add_headers('X-token' = token),
               body=fromJSON(b),
               encode = "json", 
               accept_json(),verbose())
    a<-content(pr)
    #print (a)
    #a<-do.call(rbind, lapply(a, data.frame, stringsAsFactors=FALSE))
    a<-cbind(terms[i],t(unlist(a)))
    out<-rbind(out,a)
  }
  colnames(out)<-c("geneId","EKP_Concept_Id","content.name","totalElements","totalPates","last","numberOfElements","first","size","number")
  return(out)
}



## Template
#{"additionalFields": ["publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes", 
#                      "taxonomies"],
#"positiveFilters":["sc:Chemicals & Drugs","sc:Genes & Molecular Sequences"],
#"leftInputs":[5243207],"rightInputs":[6526817]}



## Get indirect relationships at this URL
getIndirectRelation<-function(start,end){
  d<-NULL
  query = "/external/concept-to-concept/indirect"
  pages<-list()
  for (i in 1:length(start)){
    for (j in 1:length(end)){
      #template<-paste0("{",'"additionalFields": ["publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes", "taxonomies"]',",",'"leftInputs":[',start[i],']',",",'"rightInputs":[',end[j],']',"}")
      template<-paste0("{",'"additionalFields": ["publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes", "taxonomies"]',",",'"positiveFilters":["sc:Chemicals & Drugs","sc:Genes & Molecular Sequences","sc:Physiology"]',",",'"leftInputs":[',start[i],']',",",'"rightInputs":[',end[j],']',"}")
      template<-fromJSON(template,simplifyVector = FALSE)
                 pr <- POST(url = paste(base_url, query, sep =""), 
                 add_headers('X-token' = token),
                 body=template,
                 encode = "json", 
                 accept_json(),verbose())
      a<-content(pr)
      pages[[i+1]]<-a$content
    }
  }
  return(pages)
  }


# Function that returns table from json objects as returned by EKP
getTableFromJson<-function(indirectRelationResultsFromEKP){
  df<-fromJSON(toJSON(indirectRelationResultsFromEKP),flatten=TRUE)
  do.call(rbind,df) %>% as.data.frame ->b
  
  ### parse only the relationships
  rel<-b[,"relationships"]

  ### collapse into a data frame
  dfs<-do.call(rbind,rel)
  colnames(dfs)<-c("Subject","Object","ekpTripleID","publicationIds","Predicate")
  
  ### Select subject,predicate and object columns
  dfs<-cbind(unlist(dfs[,"Subject"]),unlist(dfs[,"Object"]),as.character.default(dfs[,"Predicate"]),as.character.default(dfs[,"publicationIds"]))
  colnames(dfs)<-c("Subject","Object","Predicate","Publications")
  dfs<-dfs[,c(1,3,2,4)]
  dfs<-cSplit(dfs,"Predicate",",","long")
  dfs<-cSplit(dfs,"Publications",",","long")
}


### Function to retrieve resistance to chemicals
getResistanceEKPID<-function(){
  query="/external/concepts/search"
  template<-paste("{",'"queryString":"term:',"'apo:0000087'",'","searchType":"STRING"',"}",sep="")
  pr <- POST(url = paste(base_url, query, sep =""), 
             add_headers('X-token' = token),
             body=fromJSON(template),
             encode = "json", 
             accept_json(),verbose())
  a<-content(pr)
}


### Function to retrieve butanol tolerance
getButanolID<-function(){
  query="/external/concepts/search"
  template<-paste("{",'"queryString":"term:',"'c0089147'",'","searchType":"STRING"',"}",sep="")
  pr <- POST(url = paste(base_url, query, sep =""), 
             add_headers('X-token' = token),
             body=fromJSON(template),
             encode = "json", 
             accept_json(),verbose())
  a<-content(pr)
}



## Get Concept name from concept id
out<-NULL
getConceptName<-function(ids){
  query<- "/external/concepts"
  for (i in 1:length(ids)){
    b<-paste0("{",'"ids":','["',as.character(ids[i]),'"]',"}",sep="")
    pr <- POST(url = paste(base_url, query, sep =""), 
               add_headers('X-token' = token),
               body=fromJSON(b,simplifyVector = FALSE),
               encode = "json", 
               accept_json(),verbose())
    a<-content(pr)
    #print (a)
    a<-do.call(rbind, lapply(a, data.frame, stringsAsFactors=FALSE))
    out<-rbind(out,a)
  }
  return(out)
}



## Get predicate name predicate
getPredicateName<-function(){
  query = "/external/predicates"
  pr <- POST(url = paste(base_url, query, sep =""), 
             add_headers('X-token' = token),
             body=NULL,
             encode = "json", 
             accept_json(),verbose())
  a<-content(pr)
  pages<-list()
  for (i in 0:a$totalPages){
    pr <- POST(url = paste(base_url, query,"?page=",i ,sep =""), 
               add_headers('X-token' = token),
               body=NULL,
               encode = "json", 
               accept_json(),verbose())
    b<-content(pr)
    message("Retrieving page ", i)
    pages[[i+1]]<-b$content
  }
  return(pages)
}

###################################

### Get Predicate names #########
predicates<- getPredicateName()

pred<-fromJSON(toJSON(predicates),flatten = TRUE)
mat<-NULL
for (i in 1:length(pred)){
  id<-unlist(pred[[i]]$id)  
  name<-unlist(pred[[i]]$name)
  t<-cbind(id,name)
  mat<-rbind(mat,t)
}
mat<-as.data.frame(mat)

#### Create predicate list for future reference
write.csv(mat,file="Reference_Predicate_List.csv")


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
