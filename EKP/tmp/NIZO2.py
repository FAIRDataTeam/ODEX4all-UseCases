# Load the required packages
import EKP
import csv
import os
import datetime

# Knowledge platform URL
url = ''

# User credentials: Please fill in!
username = ''
password = ''

# Set the output directory
os.chdir("NIZO input & Output/")

# Get the user token, required for access
t = EKP.getToken(username, password, url).json()['token']

# Get the semantic types contained in the database, and their codes
Types = EKP.getSemanticTypeDict(url, t)


# Read in the input file
input_file = open("List commensal species Qin et al 19_10_2015.csv", "r")
reader = csv.reader(input_file, delimiter=";")

commensals = []

for line in reader:
    commensals.append(line[0])
input_file.close()

input_group = "Bacterium"
input_ids = {}
for c in commensals:
    ID = EKP.getID(url, Types, t, c, input_group)
    if len(ID) > 0:
        input_ids.update({ID[0]['name']: ID[0]['id']})


endpoints = {"Gut dysmotility" : "C1839757",
             "bowel/gut problem" : "C1656426",
             "Inflammatory Bowel Diseases" : "C0021390",
             "Intestinal mucosal permeability" : "C0232645",
             "Permeability" : "C0232645",
             "body barrier" : "C0682585"
             }

intermediate_types = {   "Food" : "Objects",
                         "Organ or Tissue Function" : "Physiology",
                         #"Gene or Genome" : "Genes & Molecular Sequences",
                         "Finding" : "Disorders",
                         "Disease or Syndrome" : "Disorders",
                         "Chemical Viewed Functionally" : "Chemicals & Drugs",
                         "Biologically Active Substance" : "Chemicals & Drugs",
                         "Tissue" : "Anatomy",
                         "Body Location or Region" : "Anatomy",
                         "Body Part, Organ, or Organ Component" : "Anatomy",
                         "Body Space or Junction" : "Anatomy",
                         "Body System" : "Anatomy",
                         "Cell" : "Anatomy"
                         }

# Alle concepten die met Gut te maken hebben gebruiken als filter
gut = EKP.getID(url, Types, t, "C0699819")
intestines = EKP.getID(url, Types, t, "C0021853")


endpoint_ids = []
for point in endpoints.values():
    endpoint_ids.append(EKP.getID(url, Types, t, point)[0]['id'])
endpoint_ids = list(set(endpoint_ids))

for input in input_ids.values():
    print(EKP.getRelationships([input], endpoint_ids, url, t))

indirect_all = []
gut_all = []
intestines_all = []

for key, value in intermediate_types.items():
    gut_connected = EKP.getDirectlyConnectedConcepts(Types, t, url, [gut[0]['id']], value, key)
    if 'content' in gut_connected.keys() and len(gut_connected['content']) > 0:
        for g in gut_connected['content']:
            gut_all.append(g['tier1Concept']['gi'])
    intestines_connected = EKP.getDirectlyConnectedConcepts(Types, t, url, [intestines[0]['id']], value, key)
    if 'content' in intestines_connected.keys() and len(intestines_connected['content']) > 0:
        for g in intestines_connected['content']:
            intestines_all.append(g['tier1Concept']['gi'])
    response = EKP.getIndirectRelationships(list(input_ids.values()), endpoint_ids, Types, url, t, value, key)
    print(response)
    if 'content' in response.keys():
        indirect_all.append(response['content'])

indirect_out = open("indirect_output_" + datetime.datetime.today().strftime("%Y_%m_%d") + ".csv", "w")
iw = csv.writer(indirect_out, delimiter = ";")

iw.writerow(["Starting concept", "Predicate1", "Sources1", "Connecting concept", "Semantic category", "Semantic types", "Found in gut?", "Found in intestines?", "Predicate2", "Sources2", "End concept", "Path weight"])

indirect_all2 = []
for ii in indirect_all:
    indirect_all2 = indirect_all2 + ii

for i in indirect_all2:
    start = i['tier0Concept']['name']
    intermediate = i['tier1Concept']['name']
    intermediate_cat = i['tier1Concept']['category']
    intermediate_concept = EKP.getConcept(i['tier1Concept']['gi'], url, t)
    output_STs = []
    for g in intermediate_concept['semanticTypes']:
        for key, value in Types[0].items():
            if g == value:
                output_STs.append(key)
    # Hier logica om te filteren op gut & intestines
    if i['tier1Concept']['gi'] in gut_all:
        gut_bool = "gut"
    if i['tier1Concept']['gi'] not in gut_all:
        gut_bool = "no"
    if i['tier1Concept']['gi'] in intestines_all:
        intestines_bool = "intestines"
    if i['tier1Concept']['gi'] not in intestines_all:
        intestines_bool = "no"
    end = i['tier2Concept']['name']
    pw = i['pathWeight']
    nrows = max([len(i['tier01TripleInformation']), len(i['tier12TripleInformation'])])
    pubs1 = []
    pubs2 = []
    for w in range(0,nrows):
        if w <= len(i['tier01TripleInformation']) - 1:
            predicate1 = i['tier01TripleInformation'][w]['predicateName']
            pub_info = EKP.getPublications(i['tier01TripleInformation'][w]['tripleUuid'], url, t)
            for p1 in pub_info['publications']:
                if p1['publicationInfo'] is not None and 'url' in p1['publicationInfo'].keys():
                    pubs1.append(p1['publicationInfo']['url'])
        if w <= len(i['tier12TripleInformation']) - 1:
            predicate2 = i['tier12TripleInformation'][w]['predicateName']
            pub_info2 = EKP.getPublications(i['tier12TripleInformation'][w]['tripleUuid'], url, t)
            for p2 in pub_info2['publications']:
                if p2['publicationInfo'] is not None and 'url' in p2['publicationInfo'].keys():
                    pubs2.append(p2['publicationInfo']['url'])
        iw.writerow([start, predicate1, pubs1, intermediate, intermediate_cat, output_STs, gut_bool, intestines_bool, predicate2, pubs2, end, pw])

indirect_out.close()
