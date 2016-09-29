# Load the required packages
from scripts.EKP.EKP2 import connection
import os
import csv
import configparser
import logging
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/scripts/EKP')
logging.basicConfig(filename='logs/IOS.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)

c.setDirectory("IOS")

# Get the internal identifier for Parkinson disease through its UMLS ID

parkinson = c.getID("c0030567", source = "umls")[0]['id']

# Get all relevant concepts directly associated with it


# Disease or Syndrome
output_file = open("parkinson_adjacent_diseases.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
diseases = c.getDirectlyConnected([parkinson], ["T047"], linkweight="LWS")
disease_ids = []
for d in diseases:
    connected_concept = d['concepts'][1]['name']
    csv_writer.writerow([connected_concept, d['relationships'][0]['concept1Id'], d['score'], d['relationships'][0]['tripleIds']])
    disease_ids.append(d['relationships'][0]['concept1Id'])
output_file.close()

# First three diseases are uninformative
disease_ids = disease_ids[3:]

# Anatomical Structure, Cell, Cell Component, Tissue
output_file = open("parkinson_adjacent_anatomy.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
anatomy = c.getDirectlyConnected([parkinson], ["T017", "T025", "T026", "T024"])
anatomy_ids = []
for a in anatomy:
    connected_concept = a['concepts'][1]['name']
    csv_writer.writerow([connected_concept, a['relationships'][0]['concept1Id'], a['score'], a['relationships'][0]['tripleIds']])
    anatomy_ids.append(a['relationships'][0]['concept1Id'])
output_file.close()


# Hormones, Enzymes, Steroids
output_file = open("parkinson_adjacent_chemicals.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
chemicals = c.getDirectlyConnected([parkinson], ["T125", "T126", "T110"])
chemical_ids = []
for ch in chemicals:
    connected_concept = ch['concepts'][1]['name']
    csv_writer.writerow([connected_concept, ch['relationships'][0]['concept1Id'], ch['score'], ch['relationships'][0]['tripleIds']])
    chemical_ids.append(ch['relationships'][0]['concept1Id'])
output_file.close()


# Gene or Genome
output_file = open("parkinson_adjacent_genes.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
genes = c.getDirectlyConnected([parkinson], ["T028"])
gene_ids = []
for g in genes:
    connected_concept = g['concepts'][1]['name']
    csv_writer.writerow([connected_concept, g['relationships'][0]['concept1Id'], g['score'], g['relationships'][0]['tripleIds']])
    gene_ids.append(g['relationships'][0]['concept1Id'])
output_file.close()

# First gene is nonsense, and therefore removed
gene_ids = gene_ids[1:]

# Physiologic Function
output_file = open("parkinson_adjacent_physiology.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
physiology = c.getDirectlyConnected([parkinson], ["T039"])
physiology_ids = []
for p in physiology:
    connected_concept = p['concepts'][1]['name']
    csv_writer.writerow([connected_concept, p['relationships'][0]['concept1Id'], p['score'], p['relationships'][0]['tripleIds']])
    physiology_ids.append(p['relationships'][0]['concept1Id'])
output_file.close()

# Get all human (& maybe model animal??) genes associated with the genes mentioned above
indirect_disease = c.getDirectlyConnected(disease_ids, ["T028"], linkweight= "PWS", positive = c.createFilter(["homo sapiens"]))
indirect_anatomy = c.getDirectlyConnected(anatomy_ids, ["T028"], linkweight= "PWS", positive = c.createFilter(["homo sapiens"]))
indirect_chemicals = c.getDirectlyConnected(chemical_ids, ["T028"], linkweight= "PWS", positive = c.createFilter(["homo sapiens"]))
indirect_physiology = c.getDirectlyConnected(physiology_ids, ["T028"], linkweight= "PWS", positive = c.createFilter(["homo sapiens"]))
indirect_genes = c.getDirectlyConnected(gene_ids[0:10], ["T028"], linkweight= "PWS", positive = c.createFilter(["homo sapiens"]))

