# DSM Workflow

This repo contains notebook ranging from basic usages of this script that is mapped with [EKP](http://www.euretos.com/EKPlatform.php) (Euretos Knowledge Platform) API.

## How to use

### R

The python notebooks are written in [Jupyter](http://jupyter.org/).

- **View** We can view the notebooks on either
  [github](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/DSM/src/DSM_workflow.ipynb)

- **Run** We can run and modify these notebooks if both [R](https://www.r-project.org/) and [jupyter](http://jupyter.org/) are installed together with its required. These scripts are tested on Ubuntu but should work as well on Windows (not tested).

  If you have a EKP, here is an easier way to run the notebooks:
  
  1. Create a config.yaml file with received username and passwords from EKP. 
  
  2. Create a file with SGD identifiers and replace this with and its name [20170119_GeneList_DSM.txt](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/DSM/src/20170119_GeneList_DSM.txt)

  1.  Launch a [DSM_Workflow.R](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/DSM/src/DSM_workflow.R) instance by either with R or using the iPython notebook in an interactive way.

  2.  Once launch is succeed a complete list of concepts related with Butanol Tolerance will be created for example [ConceptsRelatedwithButanolTriples.csv](https://github.com/DTL-FAIRData/ODEX4all-UseCases/blob/master/DSM/src/ConceptsRelatedwithButanolTriples.csv)

## General Workflow
### Steps carried out within this workflow
1. 
