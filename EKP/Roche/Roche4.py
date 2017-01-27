# Load the required packages
import os, sys
#sys.path.append(os.getcwd()) #<-- Nodig om de boel te laten werken op een server
import csv, configparser, logging
from EKP.EKP2 import connection

logging.basicConfig(filename='EKP/logs/Roche.log',
                    level=logging.DEBUG,
                    filemode='w', format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%H:%M:%S')
logging.info("===================== Started a new session =====================")

# Load the config file and start the connection
config = configparser.ConfigParser()
config.read('EKP/config.ini')
# Set up the connection
c = connection(config)

# Load the drug targets by UNIPROT ID and RXNORM ID, keep only the ones which have more than 5 targets
nature = open("EKP/Roche/Input/Nature_Targets.csv", "r")
csv_reader = csv.reader(nature)
next(csv_reader)
target_dict = {}
for l in csv_reader:
    if l[10] is not '' and l[4] is not '':
        try:
            protID = c.getID(l[4], "Amino Acid, Peptide, or Protein", knowledgebase = "uniprot")['content']
            if len(protID) == 1:
                if l[10] not in target_dict.keys():
                    target_dict[l[10]] = [protID[0]['id']]
                else:
                    target_dict[l[10]].append(protID[0]['id'])
        except:
            continue
nature.close()
print("Mapped all drug targets to concepts")

for t in target_dict.keys():
    target_dict[t] = list(set(target_dict[t]))

disgenet = open("EKP/Roche/Input/DisGeNet with UNIPROT links 13-01-2017.csv", "r")
rdr = csv.reader(disgenet, delimiter = ";")
next(rdr)
dp_dict = {}
prot_cache = 0
dis_map = {}
for l in rdr:
    dis_CUI = l[1].split(":")[1]
    if dis_CUI in dis_map.keys():
        dis_id = dis_map[dis_CUI]
    else:
        dis_out = c.getID(dis_CUI, knowledgebase = "umls")['content']
        if len(dis_out) == 0:
            continue
        else:
            dis_id = dis_out[0]['id']
            dis_map[dis_CUI] = dis_id
    if prot_cache != l[9]:
        protID = c.getID(l[9], "T116", knowledgebase = "uniprot")['content']
        if len(protID) == 1:
            if dis_id in dp_dict.keys():
                dp_dict[dis_id].append(protID[0]['id'])
            else:
                dp_dict[dis_id] = [protID[0]['id']]
    else:
        if dis_id in dp_dict.keys():
            dp_dict[dis_id].append(protID[0]['id'])
        else:
            dp_dict[dis_id] = [protID[0]['id']]
    prot_cache = l[9]
print("Mapped all disease proteins to concepts")


for t in dp_dict.keys():
    dp_dict[t] = list(set(dp_dict[t]))

useful_diseases = []
for t in dp_dict.keys():
    if len(dp_dict[t]) > 19:
        useful_diseases.append(t)
disgenet.close()

# Load their indications
medi = open("EKP/Roche/Input/MEDI_Integrated.csv", "r")
csv_reader = csv.reader(medi)
next(csv_reader)
drugs = {}
diseases = {}
dd_pairs = []
all_diseases = []
for l in csv_reader:
    if l[6] in target_dict.keys():
        if l[1] not in drugs.keys():
            drug_id = c.getID(l[5])['content'][0]['id']
            drugs[l[1]] = drug_id
        if l[3] not in diseases.keys():
            disease_ids = c.getID(l[3].replace("'", ""), "T047")
            diseases[l[3]] = []
            for d in disease_ids['content']:
                for x in d['synonyms']:
                    if x['name'] == l[2] and x['source'] == "umls":
                        diseases[l[3]].append(d['id'])
                        all_diseases.append(d['id'])
        if len(set(useful_diseases).intersection(set(diseases[l[3]]))) > 0:
            if [l[6], l[3]] not in dd_pairs:
                dd_pairs.append([l[6], l[3]])
medi.close()
dd_pairs = [list(x) for x in set(tuple(x) for x in dd_pairs)]
print("Obtained drug-disease pairs")

def getCentrality(start):
    # Get the undirected centrality of a starting point
    direct = c.getDirectlyConnected(start, ["T116"])
    dir_con = [x['concepts'][1]['id'] for x in direct]
    return c.getConceptCount(dir_con, ["Chemicals & Drugs"])['Amino Acid, Peptide, or Protein']

# Set the output directory
c.setDirectory("EKP/Roche")

# Obtain paths between disease proteins and drug targets

#TODO: Zit blijkbaar ook een score in relaties. Die bijvoegen
centralities = {}
ifilter = c.createFilter(["T116"])
for d in dd_pairs:
    output = open(d[0] + "--" + d[1] + " paths.csv", "w")
    csv_writer = csv.writer(output, delimiter=";")
    print(d[0])
    out = c.getIndirectRelationship(target_dict[d[0]], dp_dict[diseases[d[1]][0]], ifilter)
    if len(out) > 0:
        for p in out:
            if p['concepts'][0]['id'] not in centralities.keys():
                centralities[p['concepts'][0]['id']] = getCentrality([p['concepts'][0]['id']])
            if p['concepts'][1]['id'] not in centralities.keys():
                centralities[p['concepts'][1]['id']] = getCentrality([p['concepts'][1]['id']])
            if p['concepts'][2]['id'] not in centralities.keys():
                centralities[p['concepts'][2]['id']] = getCentrality([p['concepts'][2]['id']])
            start = [p['concepts'][0]['name'], p['concepts'][0]['id'], centralities[p['concepts'][0]['id']]]
            start.append([c.rev_map[s] for s in p['concepts'][0]['semanticTypes']])
            middle = [p['concepts'][1]['name'], p['concepts'][1]['id'], centralities[p['concepts'][1]['id']]]
            middle.append([c.rev_map[s] for s in p['concepts'][1]['semanticTypes']])
            #middle_count = sum(c.getConceptCount([p['concepts'][1]['id']], c.Categories).values())
            end = [p['concepts'][2]['name'], p['concepts'][2]['id'], centralities[p['concepts'][2]['id']]]
            end.append([c.rev_map[s] for s in p['concepts'][2]['semanticTypes']])
            AB_predicates = [c.mapPredicate(x) for x in p['relationships'][0]['predicateIds']]
            AB_pubs = c.getPubliciations(p['relationships'][0]['publicationIds'])
            AB_sourceData = c.getSourceIdentifiers(AB_pubs)
            BC_predicates = [c.mapPredicate(x) for x in p['relationships'][1]['predicateIds']]
            BC_pubs = c.getPubliciations(p['relationships'][1]['publicationIds'])
            BC_sourceData = c.getSourceIdentifiers(BC_pubs)
            row = [d[0]] + start + [AB_predicates] + middle + [BC_predicates] + end + [d[1]] + [p['score']]
            row += [AB_sourceData['Database']] + [AB_sourceData['sourceScore']] + [AB_sourceData['sourceName']] + [AB_sourceData['sourceId']]
            row += [BC_sourceData['Database']] + [BC_sourceData['sourceScore']] + [BC_sourceData['sourceName']] + [BC_sourceData['sourceId']]
            csv_writer.writerow(row)
    output.close()
    output = open(d[0] + "--" + d[1] + " associations.csv", "w")
    wrtr = csv.writer(output, delimiter=";")
    out = c.getDirectRelationship(target_dict[d[0]], diseases[d[1]])['content']
    if len(out) > 0:
        for a in out:
            pubs = c.getPubliciations(a['relationships'][0]['publicationIds'])
            # Number of publications
            sources = c.getSourceIdentifiers(pubs)
            # Author commitment within these publications
            authors = []
            for pub in pubs:
                authors += pub['authors']
            predicates = [c.mapPredicate(x) for x in a['relationships'][0]['predicateIds']]
            wrtr.writerow(
                [d[0], d[1], len(pubs), a['score'], sources['sourceName'], sources['Database'], authors,
                 predicates])
    output.close()
print("Done")
