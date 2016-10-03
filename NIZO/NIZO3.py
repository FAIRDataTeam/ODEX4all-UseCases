from scripts.EKP.EKP2 import connection
import os
import csv
import configparser
import logging
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/scripts/EKP')
logging.basicConfig(filename='logs/NIZO.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)

# Read in the files
input = open("NIZO/Input/List commensals for textmining_v3.txt", "r")
csv_reader = csv.reader(input)

commensals = []
for line in csv_reader:
    commensals += line

input.close()

input = open("NIZO/Input/intermediate_types.txt", "r")
csv_reader = csv.reader(input, delimiter = "\t")

types = []
for line in csv_reader:
    types.append(line[0])

input.close()


# Set the output directory
c.setDirectory("NIZO")

# Magic
commensals_mapped = {}
for b in commensals:
    ID = c.getID(b, "Bacterium")
    if len(ID) ==1:
        commensals_mapped[b] = ID[0]['id']
    if len(ID) > 1:
        print(b)

healthbenefits_mapped = {}

# Get the direct connections between the gut commensals and health benefits and write results to output file
output = open("Direct_paths.csv", "w")
csv_writer = csv.writer(output, delimiter = ";")
paths = c.getDirectRelationship(list(commensals_mapped.values()), list(healthbenefits_mapped.values()))
for p in paths:
    start = [p['concepts'][0]['name'], p['concepts'][0]['id'], p['concepts'][0]['semanticTypes']]
    end = [p['concepts'][1]['name'], p['concepts'][1]['id'], p['concepts'][1]['semanticTypes']]
    score = p['score']
    AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
    AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
    AB_sourceNames = [y['sourceName'] for y in AB_pubs]
    AB_sourceIds = [z['sourceId'] for z in AB_pubs]
    output.writerow(start + end + [score] + AB_predicates + AB_sourceNames)
    output.close()


# Potential: Filter concepts based on relationship with intermediate term
filter_concept = c.getID("FILTER")
intermediate_filter = c.createFilter(types)
filter_list = c.getDirectlyConnected(filter_concept, intermediate_filter)

# Get the indirect connections (through the intermediate concept types) between gut commensals and health benefits
output = open("Indirect_paths.csv", "w")
csv_writer = csv.writer(output, delimiter = ";")
paths = c.getIndirectRelationship(list(commensals_mapped.values()), list(healthbenefits_mapped.values()), intermediate_filter)
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
    output.writerow(start + middle + end + [score] + AB_predicates + AB_sourceNames +
                       BC_predicates + BC_sourceNames)
output.close()