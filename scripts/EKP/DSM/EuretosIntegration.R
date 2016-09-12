library(httr)
library(jsonlite)
library(magrittr)
library(yaml)

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

setwd("/home/anandgavai/ODEX4all-UseCases/ODEX4all-UseCases/scripts/EKP/DSM")
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
getConceptID<-function(yeast_genes){
  out<-NULL
  for (i in 1:dim(yeast_genes)[1]){
    b<-paste("{",'"queryString":"term:',yeast_genes[i,],'","searchType":"STRING"',"}")
    pr <- POST(url = paste(base_url, query, sep =""), 
               add_headers('X-token' = token),
               body=fromJSON(b),
               encode = "json", 
               accept_json(),verbose())
    a<-content(pr)
    a<-do.call(rbind, lapply(a, data.frame, stringsAsFactors=FALSE))
    a<-cbind(yeast_genes[i,],a)
    out<-rbind(out,a)
  }
  colnames(out)<-c("SGD_Id","EKP_Concept_Id","Gene_name")
  return(out)
}

getConceptID(yeast_genes)
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

