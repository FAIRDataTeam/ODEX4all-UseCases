# Bayer Workflow to identify genotype-phenotype relationship within Euretos Knowledge Platform

## Objective: The objective of this workflow is to identify concepts (genes) that are related with Morpholocial traits with EKP (Euretos Knowledge Platform) platform.


This repo contains notebook ranging from basic usages of this script that is mapped with [EKP](http://www.euretos.com/EKPlatform.php) (Euretos Knowledge Platform) API.

## How to use

The python notebooks are written in [Jupyter](http://jupyter.org/).

- **View** We can view the notebooks on either
  [github](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/Workflow_Rice.ipynb)

- **Run** We can run and modify these notebooks if both [R](https://www.r-project.org/) and [jupyter](http://jupyter.org/) are installed together with its required. These scripts are tested on Ubuntu but should work as well on Windows (not tested).

  If you have a EKP, here is an easier way to run the notebooks:
  
  1. Create a config.yaml file with received username and passwords from EKP. 
  
  2. Create a file with gene identifiers for example downloaded from [Q-TARO](http://qtaro.abr.affrc.go.jp) and replace this with and its name [GeneInformationTable_Qtaro.csv](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/data/GeneInformationTable_Qtaro.csv)

  1.  Launch a [Workflow_Rice.R](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/Workflow_Rice.R) instance by either with R or using the iPython notebook in an interactive way.

  2.  Once launch is succeed a complete list of concepts related with for example: "Grain number" will be created for example [ConceptsRelatedwithGrainNumber.csv](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/ConceptsRelatedwithGrainNumber.csv)

## General Workflow
### Steps carried out within this workflow
1. File [EuretosInfrastructure.R](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/DSM/src/EuretosInfrastructure.R) is the actual interface that connects with EKP.
2. [Workflow_Rice.R](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/Workflow_Rice.R) is the file where actual analysis happens.
3. Concepts for gene identifiers (fetched from QTARO, but not restricted to) are searched within the EKP for their relationship with "Grain number".
4. Next concepts are for these gene identifiers are searched again within EKP for their indirect relationship with "Grain Number".
5. The resulting relationships are combined together to generate the output [ConceptsRelatedGrainNumberTriples.csv](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/ConceptsRelatedGrainNumberTriples.csv)
6. Results are summarized using post processing script that is at the bottom of [Workflow_Rice.R](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/Workflow_Rice.R)
7. Final results consists of information on Genes, Intermetiate Concepts, Score (PWS from EKP) and Provenance (Gramene id's) for further analysis.
8. A graphical format of the workflow can be found [Workflow_Rice.png](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/Bayer/src/Workflow_Rice.png)
