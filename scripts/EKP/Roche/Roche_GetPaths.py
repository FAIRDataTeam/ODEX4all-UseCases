# Load the connection
from scripts.EKP.EKP2 import connection
import os
import csv
import configparser
import logging
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/scripts/EKP')
logging.basicConfig(filename='logs/Roche.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)

# Load the data
input = open("Roche/DiseaseTarget_referenceSet.csv", "r")
reader = csv.reader(input, delimiter = ";")
reader.__next__()

# Set the working directory for today
c.setDirectory("Roche")

intermediate_filter = c.createFilter(["T116", "homo sapiens"])

signals = open("Functional drugs.csv", "w")
out_write = csv.writer(signals, delimiter = ";")

# Map to concepts and get paths

# Model is : A -[relationship]- B -[relationship]- C, terminology is accordingly
for line in reader:
    genes = line[6:30]
    genes = list(filter(lambda x: x != ' ', genes))
    gene_ids = []
    for g in genes:
        gene_ids.append(c.getID("[entrezgene]" + g, "T028")[0]['id'])
    drug_id = c.getID(line[0], "T121")
    if len(drug_id) == 0:
        print("Could not map " + line[0] + " to concept Identifier")
        drugs = []
        drug_id = c.getID(line[1], "T121")
        # Apparently there can be more than one concept ID for each drug, and they are split according to brand name. We will select them all.
        for d in drug_id:
           drugs.append(d['id'])
    paths = c.getIndirectRelationship(drugs, gene_ids, intermediate_filter)
    if type(paths) is list:
        for p in paths:
            start = [p['concepts'][0]['name'], p['concepts'][0]['id'], p['concepts'][0]['semanticTypes']]
            middle = [p['concepts'][1]['name'], p['concepts'][1]['id'], p['concepts'][1]['semanticTypes']]
            end = [p['concepts'][2]['name'], p['concepts'][2]['id'], p['concepts'][2]['semanticTypes']]
            score = p['score']
            AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
            AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
            AB_sourceNames = [y['sourceName'] for y in AB_pubs]
            AB_sourceIds = [z['sourceId'] for z in AB_pubs]
            BC_predicates = [c.mapPredicate(x) for x in p['relationships'][1]['predicateIds']]
            BC_pubs = c.getPubliciations(p['relationships'][1]['publicationIds'])
            BC_sourceNames = [y['sourceName'] for y in BC_pubs]
            BC_sourceIds = [z['sourceId'] for z in BC_pubs]
            out_write.writerow(start + middle + end + [score] + AB_predicates + AB_sourceNames +
                               BC_predicates + BC_sourceNames)

signals.close()


# Analyse uitvoeren met Caret package in R