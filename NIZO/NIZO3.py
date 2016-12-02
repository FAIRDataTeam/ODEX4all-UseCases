from EKP.EKP2 import connection
import os
import csv
import configparser
import logging
from EKP.DatabaseMapper import DatabaseMapper

# Read in the files
input_file = open("NIZO/Input/List commensals for textmining_v3.txt", "r")
csv_reader = csv.reader(input_file)

commensals = []
for line in csv_reader:
    commensals += line

input_file.close()

input_file = open("NIZO/Input/intermediate_types.txt", "r")
csv_reader = csv.reader(input_file, delimiter="\t")

types = []
for line in csv_reader:
    types.append(line[0])

input_file.close()

input_file = open("NIZO/Input/Gut health.csv", "r")
csv_reader = csv.reader(input_file, delimiter=";")

healthbenefits = []
for line in csv_reader:
    healthbenefits.append(line[0])

input_file.close()

# Load the config file and start the connection
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/EKP')
logging.basicConfig(filename='logs/NIZO.log', level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)
dbmap = DatabaseMapper("Data/RDRTAccess12-01-2016.txt")

# Set the output directory
c.setDirectory("NIZO")

error_file = open("Mapping difficulties.csv", "w")
error_writer = csv.writer(error_file, delimiter = ";")

# Magic
commensals_mapped = {}
for b in commensals:
    ID = c.getID(b, "Bacterium")
    if ID['numberOfElements'] == 1:
        commensals_mapped[b] = ID['content'][0]['id']
    elif ID['numberOfElements'] > 1:
        error_writer.writerow([b, ID['content']])
    elif ID['numberOfElements'] == 0:
        error_writer.writerow([b, "No mapping available"])

healthbenefits_mapped = {}
for b in healthbenefits:
    ID = c.getID(b)
    if ID['numberOfElements'] == 1:
        healthbenefits_mapped[b] = ID['content'][0]['id']
    elif ID['numberOfElements'] > 1:
        error_writer.writerow([b, ID['content']])
    elif ID['numberOfElements'] == 0:
        error_writer.writerow([b, "No mapping available"])

error_file.close()

# Get the direct connections between the gut commensals and health benefits and write results to output file
output = open("Direct_paths.csv", "w", encoding='utf-8')
csv_writer = csv.writer(output, delimiter = ";")
csv_writer.writerow(["Starting concept", "Starting concept ID", "Starting concept ST", "Relationships", "End concept", "End concept ID", "End concept ST", "Path score",
                     "Link1", "Link2", "Link3", "All links", "Source DB", "Sources", "Source score"])
paths = c.getDirectRelationship(list(commensals_mapped.values()), list(healthbenefits_mapped.values()))
for p in paths:
    start = [p['concepts'][0]['name'], p['concepts'][0]['id']]
    start.append(", ".join([c.rev_map[s] for s in list(set(p['concepts'][0]['semanticTypes']) - set(["T9998", "T9997", "T9999"]))]))
    end = [p['concepts'][1]['name'], p['concepts'][1]['id']]
    end.append(", ".join([c.rev_map[s] for s in list(set(p['concepts'][1]['semanticTypes']) - set(["T9998", "T9997", "T9999"]))]))
    score = p['score']
    AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
    AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
    AB_db = [dbmap.MapRDRTtoName(x['accessMappings'][0]['researchDomain'], x['accessMappings'][0]['researchTarget']) for x in AB_pubs]
    AB_sourceNames = [y['sourceName'] for y in AB_pubs]
    AB_sourceScores = [g['measures'][0]['value'] for g in AB_pubs]
    AB_sourceIds = ["https://www.ncbi.nlm.nih.gov/pubmed/" + z['documentId'] for z in AB_pubs]
    AB_clicks = ['=HYPERLINK("' + x + '")' for x in AB_sourceIds[0:3]]
    for i in range(0, 3 - len(AB_clicks)):
        AB_clicks.append("")
    csv_writer.writerow(start + [", ".join(AB_predicates)] + end + [str(score).replace('.', ',')] + AB_clicks + [", ".join(AB_sourceIds)] + [", ".join(AB_db)] + [", ".join(AB_sourceNames)]  + [", ".join(AB_sourceScores)])
output.close()

# Potential: Filter concepts based on relationship with intermediate term
#filter_concept = c.getID("FILTER")
# intermediate_filter = c.createFilter(types)
# filter_list = c.getDirectlyConnected(filter_concept, intermediate_filter)

# # Split up the data, because its too much to submit at once
def chunks(input, n):
    for i in range(0, len(input), n):
        yield input[i:i + n]

# Get the indirect connections (through the intermediate concept types) between gut commensals and health benefits
output = open("Indirect_paths.csv", "w", encoding='utf-8')
csv_writer = csv.writer(output, delimiter=";")
csv_writer.writerow(["Starting concept", "Starting concept ID", "Starting concept ST", "Relationships1", "LinkAB 1", "LinkAB 2", "LinkAB 3",
                     "Middle concept", "Middle concept ID", "Middle concept ST", "Relationships2", "LinkBC 1", "LinkBC 2", "LinkBC 3",
                     "End concept", "End concept ID", "End concept ST",
                     "Path score", "All links AB", "Source DB AB", "Source score AB", "All links BC", "Source DB BC", "Source score BC"])
paths = []
for t in types:
    intermediate_filter = c.createFilter([t])
    for h in healthbenefits_mapped.values():
        print(h)
        indirect = c.getIndirectRelationship(list(commensals_mapped.values()), [h], intermediate_filter)
        if type(indirect) is list:
            paths += indirect
if len(paths) > 0:
    for p in paths:
        start = [p['concepts'][0]['name'], p['concepts'][0]['id']]
        start.append([c.rev_map[s] for s in list(set(p['concepts'][0]['semanticTypes']) - set(["T9998", "T9997", "T9999"]))])
        middle = [p['concepts'][1]['name'], p['concepts'][1]['id']]
        middle.append([c.rev_map[s] for s in list(set(p['concepts'][1]['semanticTypes']) - set(["T9998", "T9997", "T9999"]))])
        middle_count = sum(c.getConceptCount([p['concepts'][1]['id']], c.SemanticCategories()).values())
        end = [p['concepts'][2]['name'], p['concepts'][2]['id']]
        end.append([c.rev_map[s] for s in list(set(p['concepts'][2]['semanticTypes']) - set(["T9998", "T9997", "T9999"]))])
        score = p['score']
        AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
        AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
        AB_db = [dbmap.MapRDRTtoName(x['accessMappings'][0]['researchDomain'], x['accessMappings'][0]['researchTarget']) for x in AB_pubs]
        AB_sourceNames = [y['sourceName'] for y in AB_pubs]
        AB_sourceIds = ["https://www.ncbi.nlm.nih.gov/pubmed/" + z['documentId'] for z in AB_pubs]
        AB_clicks = ['=HYPERLINK("' + x + '")' for x in AB_sourceIds[0:3]]
        for i in range(0, 3 - len(AB_clicks)):
            AB_clicks.append("")
        AB_sourceScores = [g['measures'][0]['value'] for g in AB_pubs]
        BC_predicates = [c.mapPredicate(x) for x in p['relationships'][1]['predicateIds']]
        BC_pubs = c.getPubliciations(p['relationships'][1]['publicationIds'])
        BC_db = [dbmap.MapRDRTtoName(x['accessMappings'][0]['researchDomain'], x['accessMappings'][0]['researchTarget']) for x in BC_pubs]
        BC_sourceNames = [y['sourceName'] for y in BC_pubs]
        BC_sourceIds = ["https://www.ncbi.nlm.nih.gov/pubmed/" + z['documentId'] for z in BC_pubs]
        BC_clicks = ['=HYPERLINK("' + x + '")' for x in BC_sourceIds[0:3]]
        for i in range(0, 3 - len(BC_clicks)):
            BC_clicks.append("")
        BC_sourceScores = [g['measures'][0]['value'] for g in BC_pubs]
        csv_writer.writerow(start + [AB_predicates] + AB_clicks + middle + [BC_predicates] + BC_clicks + end + score +
                            [AB_sourceNames] + [AB_db] + [AB_sourceScores] + [BC_sourceNames] + [BC_db] + [BC_sourceScores])
output.close()