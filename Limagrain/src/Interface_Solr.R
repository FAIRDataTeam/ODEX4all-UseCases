library(solr)
library(httr)
library(jsonlite)

url<-"http://localhost:8983/solr/terms/select"

solr_search(q='*:*', base=url)
