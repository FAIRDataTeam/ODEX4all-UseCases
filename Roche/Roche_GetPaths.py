# Load the connection
from EKP.EKP2 import connection
import os
import csv
import configparser
import logging
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/EKP')
logging.basicConfig(filename='logs/Roche.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)

# Read in the targets of the drugs
target_dict = {}
input = open("Roche/drug_target_uniprot_links.csv", "r")
reader = csv.reader(input, delimiter = ",")
for line in reader:
    if line[0] not in target_dict.keys():
        target_dict[line[0]] = [line[3]]
    else:
        target_dict[line[0]].append(line[3])
input.close()

# Load the data
input = open("Roche/DiseaseTarget_referenceSet.csv", "r")
reader = csv.reader(input, delimiter = ";")
reader.__next__()

# Set the working directory for today
c.setDirectory("Roche")

intermediate_filter = c.createFilter(["T116", "homo sapiens"])

signals = open("Functional drugs.csv", "w", encoding='utf-8')
out_write = csv.writer(signals, delimiter = ";")

# Map to concepts and get paths

# Model is : A -[relationship]- B -[relationship]- C, terminology is accordingly
for line in reader:
    genes = line[6:30]
    genes = list(filter(lambda x: x != ' ', genes))
    gene_ids = []
    for g in genes:
        gene_ids.append(c.getID("[entrezgene]" + g, "T028")[0]['id'])
    drug_targets = []
    if line[0] in target_dict.keys():
        for t in target_dict[line[0]]:
            target_id = c.getID(t, source = 'uniprot')
            if len(target_id) > 0:
                drug_targets.append(target_id[0]['id'])
            else:
                print("Unable to map UNIPROT ID " + t)
        paths = c.getIndirectRelationship(drug_targets, gene_ids, intermediate_filter)
        if type(paths) is list:
            for p in paths:
                start = [p['concepts'][0]['name'], p['concepts'][0]['id'], p['concepts'][0]['semanticTypes']]
                middle = [p['concepts'][1]['name'], p['concepts'][1]['id'], p['concepts'][1]['semanticTypes']]
                end = [p['concepts'][2]['name'], p['concepts'][2]['id'], p['concepts'][2]['semanticTypes']]
                score = p['score']
                AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
                AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
                AB_RD = [x['accessMappings'][0]['researchDomain'] for x in AB_pubs]
                AB_RT = [x['accessMappings'][0]['researchTarget'] for x in AB_pubs]
                AB_sourceNames = [y['sourceName'] for y in AB_pubs]
                #AB_sourceIds = [z['sourceId'] for z in AB_pubs]
                BC_predicates = [c.mapPredicate(x) for x in p['relationships'][1]['predicateIds']]
                BC_pubs = c.getPubliciations(p['relationships'][1]['publicationIds'])
                BC_RD = [x['accessMappings'][0]['researchDomain'] for x in BC_pubs]
                BC_RT = [x['accessMappings'][0]['researchTarget'] for x in BC_pubs]
                BC_sourceNames = [y['sourceName'] for y in BC_pubs]
                #BC_sourceIds = [z['sourceId'] for z in BC_pubs]
                out_write.writerow(start + middle + end + score + [AB_predicates] + [AB_sourceNames] + [AB_RD] + [AB_RT] + [BC_predicates] +
                                    [BC_sourceNames] + [BC_RD] + [BC_RT])
    else:
        print(line[0] + " not in target dictionary.")

signals.close()