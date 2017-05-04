library("biomaRt")
listMarts(host="plants.ensembl.org")
gramene = useMart("plants_mart", dataset="osativa_eg_gene", host="plants.ensembl.org")
listDatasets(gramene)
gramene = useDataset("osativa_eg_gene",mart=gramene)
filters = listFilters(gramene)
attributes = listAttributes(gramene)
### collect gene specific information
attributes = attributes[grep("gene",attributes[,1]),]


#### qtaro.abr.affrc.go.jp/qtab/table
setwd("~/odex4all_usecases/ODEX4all-UseCases/Bayer/data")

gitQ <-read.csv("GeneInformationTable_Qtaro.csv",header=TRUE)

qtlQ<-read.csv("QTLInformationTable_Qtaro.csv",header=TRUE)


## search for grain size and grain number

terms selected
c("grain size","grain thickness","grain number","kernel number","GRNB","fruit number","grain number per plant","GN")

https://www.biostars.org/p/66494/









