from EKP.EKP2 import connection
import csv
import configparser
import logging
import datetime
import os

#TODO: Source DB's fixen
#TODO: Source scores fixen
#TODO: Intermediate centrality ontbreekt nu nog in output --> ook scheiden op basis van type?

os.chdir("/Users/Wytze/git/ODEX4all-UseCases/")

logging.basicConfig(filename='EKP/logs/NIZO.log',
                    level=logging.DEBUG,
                    filemode='w', format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%H:%M:%S')
logging.info("===================== Started a new session =====================")

# Read in the files
input_file = open("EKP/NIZO/Input/List commensals for textmining_v3.txt", "r")
csv_reader = csv.reader(input_file)

commensals = []
for line in csv_reader:
    commensals += line

input_file.close()

input_file = open("EKP/NIZO/Input/intermediate_types.txt", "r")
csv_reader = csv.reader(input_file, delimiter="\t")

types = {}
for line in csv_reader:
    types[line[1]] = line[0]

input_file.close()

input_file = open("EKP/NIZO/Input/Gut health.csv", "r")
csv_reader = csv.reader(input_file, delimiter=";")

healthbenefits = []
for line in csv_reader:
    healthbenefits.append(line[0])

input_file.close()

# Load the config file and start the connection
config = configparser.ConfigParser()
config.read('EKP/config.ini')
# Set up the connection
c = connection(config)

# Set the output directory
c.setDirectory("EKP/NIZO")

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
                     "Link1", "Link2", "Link3", "Sources", "Source DB", "Source ID", "Source score"])
paths = c.getDirectRelationship(list(commensals_mapped.values()), list(healthbenefits_mapped.values()))
for p in paths:
    start = [p['concepts'][0]['name'], p['concepts'][0]['id']]
    start.append(", ".join([c.rev_map[s] for s in p['concepts'][0]['semanticTypes']]))
    end = [p['concepts'][1]['name'], p['concepts'][1]['id']]
    end.append(", ".join([c.rev_map[s] for s in p['concepts'][1]['semanticTypes']]))
    score = p['score']
    AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
    AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
    AB_sourceData = c.getSourceIdentifiers(AB_pubs)
    AB_clicks = ['=HYPERLINK("' + x['url'] + '")' for x in AB_sourceData]
    for i in range(0, 3 - len(AB_clicks)):
        AB_clicks.append("")
    AB_sourceNames = []
    AB_DBs = []
    AB_sourceIDs = []
    AB_sourceScores = []
    for a in AB_sourceData:
        AB_sourceNames += a['sourceName']
        AB_DBs += a['Database']
        AB_sourceIDs += a['sourceId']
        AB_sourceScores += a['sourceScore']
    csv_writer.writerow(start + [", ".join(AB_predicates)] + end + [str(score).replace('.', ',')] + AB_clicks +
                        [", ".join(AB_sourceNames)] + [", ".join(AB_DBs)] + [", ".join(AB_sourceIDs)] + [", ".join(AB_sourceScores)])
output.close()

# AB_clicks = ['=HYPERLINK("' + x + '")' for x in AB_sourceIds[0:3]]
#for i in range(0, 3 - len(AB_clicks)):
#    AB_clicks.append("")

# Potential: Filter concepts based on relationship with intermediate term
#filter_concept = c.getID("FILTER")
# intermediate_filter = c.createFilter(types)
# filter_list = c.getDirectlyConnected(filter_concept, intermediate_filter)

# # Split up the data, because its too much to submit at once
def chunks(input, n):
    for i in range(0, len(input), n):
        yield input[i:i + n]

# Get the indirect connections (through the intermediate concept types) between gut commensals and health benefits
for t in types.values():
    print(c.rev_map[t])
    output = open("Indirect_paths " + c.rev_map[t] + ".csv", "w", encoding='utf-8')
    csv_writer = csv.writer(output, delimiter=";")
    csv_writer.writerow(
        ["Starting concept", "Starting concept ID", "Starting concept ST", "Relationships1",
         "LinkAB 1", "LinkAB 2", "LinkAB 3",
         "Middle concept", "Middle concept ID", "Middle concept ST", "Relationships2",
         "LinkBC 1", "LinkBC 2", "LinkBC 3",
         "End concept", "End concept ID", "End concept ST",
         "Path score", "Source DB AB", "Source score AB", "SourceNames AB", "All AB Source IDs",
         "Source DB BC", "Source score BC", "SourceNames BC", "All BC Source IDs"])
    for h in healthbenefits_mapped.values():
        print(datetime.datetime.today().strftime("%H:%M:%S") + " getting " + h)
        indirect_all = []
        indirect = c.getIndirectRelationship(list(commensals_mapped.values()), [h], [t])
        if type(indirect) is list:
            indirect_all += indirect
        if len(indirect_all) > 0:
            for p in indirect_all:
                start = [p['concepts'][0]['name'], p['concepts'][0]['id']]
                start.append([c.rev_map[s] for s in p['concepts'][0]['semanticTypes']])
                middle = [p['concepts'][1]['name'], p['concepts'][1]['id']]
                middle.append([c.rev_map[s] for s in p['concepts'][1]['semanticTypes']])
                middle_count = sum(c.getConceptCount([p['concepts'][1]['id']], c.Categories).values())
                end = [p['concepts'][2]['name'], p['concepts'][2]['id']]
                end.append([c.rev_map[s] for s in p['concepts'][2]['semanticTypes']])
                score = p['score']
                AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
                AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
                AB_sourceData = c.getSourceIdentifiers(AB_pubs)
                AB_clicks = ['=HYPERLINK("' + x['url'] + '")' for x in AB_sourceData]
                for i in range(0, 3 - len(AB_clicks)):
                    AB_clicks.append("")
                BC_predicates = [c.mapPredicate(x) for x in p['relationships'][1]['predicateIds']]
                BC_pubs = c.getPubliciations(p['relationships'][1]['publicationIds'])
                BC_sourceData = c.getSourceIdentifiers(BC_pubs)
                BC_clicks = ['=HYPERLINK("' + x['url'] + '")' for x in BC_sourceData]
                for i in range(0, 3 - len(BC_clicks)):
                    BC_clicks.append("")
                AB_sourceNames = []
                AB_DBs = []
                AB_sourceIDs = []
                AB_sourceScores = []
                for a in AB_sourceData:
                    AB_sourceNames += a['sourceName']
                    AB_DBs += a['Database']
                    AB_sourceIDs += a['sourceId']
                    AB_sourceScores += a['sourceScore']
                BC_sourceNames = []
                BC_DBs = []
                BC_sourceIDs = []
                BC_sourceScores = []
                for b in BC_sourceData:
                    BC_sourceNames += b['sourceName']
                    BC_DBs += b['Database']
                    BC_sourceIDs += b['sourceId']
                    BC_sourceScores += b['sourceScore']
                csv_writer.writerow(start + [", ".join(AB_predicates)]+ AB_clicks[0:3] + middle + [", ".join(BC_predicates)] + BC_clicks[0:3] + end + [str(score).replace('.', ',')] +
                                    [", ".join(AB_DBs)]+ [", ".join(AB_sourceScores)] + [", ".join(AB_sourceNames)] + [", ".join(AB_sourceIDs)] +
                                    [", ".join(BC_DBs)] + [", ".join(BC_sourceScores)] + [", ".join(BC_sourceNames)] + [", ".join(BC_sourceIDs)])
    output.close()