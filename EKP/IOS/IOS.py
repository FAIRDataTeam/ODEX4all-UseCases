# Load the required packages
import csv, configparser, logging, os, sys
sys.path.append(os.getcwd())
from EKP.EKP2 import connection
logging.basicConfig(filename='EKP/logs/IOS.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('EKP/config.ini')

# Set up the connection
c = connection(config)

## IMPORTANT: Rewritten for exploratory DSM use case research

# Get the internal identifier for Parkinson disease through its UMLS ID

#parkinson = c.getID("c0030567", source = "umls")[0]['id']

start_genes = []
infile = open("DSM/src/20170119_GeneList_DSM.txt", "r")
rdr = csv.reader(infile, delimiter = "\t")
next(rdr)
for i in rdr:
    start_genes.append(c.getID(i[1].lower())['content'][0]['id'])
infile.close()

start_genes = start_genes #<-- Remove for ultimate test. Using it now to debug

c.setDirectory("IOS")
## Get all relevant concepts directly associated with it
# Disease or Syndrome
#output_file = open("parkinson_adjacent_diseases.csv", "w")
output_file = open("genes_cell_component.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
diseases = c.getDirectlyConnected(start_genes, ["T026"], linkweight="LWS")
disease_ids = []
for d in diseases:
    #csv_writer.writerow([d['concepts'][1]['name'], d['relationships'][0]['concept1Id'], d['score'], d['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(d['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([d['concepts'][0]['name'], d['concepts'][0]['id'], t['predicateName'], d['concepts'][1]['name'], d['relationships'][0]['concept1Id'], d['score']])
    disease_ids.append(d['relationships'][0]['concept1Id'])
output_file.close()

# First three diseases are uninformative
#disease_ids = disease_ids[3:]

# Anatomical Structure, Cell, Cell Component, Tissue
#output_file = open("parkinson_adjacent_anatomy.csv", "w")
output_file = open("genes_functions.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
anatomy = c.getDirectlyConnected(start_genes, ["T038", "T067"])
anatomy_ids = []
for a in anatomy:
    #csv_writer.writerow([a['concepts'][1]['name'], a['relationships'][0]['concept1Id'], a['score'], a['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(a['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([a['concepts'][0]['name'], a['concepts'][0]['id'], t['predicateName'], a['concepts'][1]['name'], a['relationships'][0]['concept1Id'], a['score']])
    anatomy_ids.append(a['relationships'][0]['concept1Id'])
output_file.close()


# Hormones, Enzymes, Steroids
#output_file = open("parkinson_adjacent_chemicals.csv", "w")
output_file = open("genes_chemicals.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
chemicals = c.getDirectlyConnected(start_genes, ["T125", "T126", "T110"])
chemical_ids = []
for ch in chemicals:
    #csv_writer.writerow([ch['concepts'][1]['name'], ch['relationships'][0]['concept1Id'], ch['score'], ch['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(ch['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([ch['concepts'][0]['name'], ch['concepts'][0]['id'], t['predicateName'], ch['concepts'][1]['name'],
                             ch['relationships'][0]['concept1Id'], ch['score']])
    chemical_ids.append(ch['relationships'][0]['concept1Id'])
output_file.close()


# Gene or Genome
#output_file = open("parkinson_adjacent_genes.csv", "w")
output_file = open("genes_genes.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
genes = c.getDirectlyConnected(start_genes, ["T028"])
gene_ids = []
for g in genes:
    # csv_writer.writerow([g['concepts'][1]['name'], g['relationships'][0]['concept1Id'], g['score'], g['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(g['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([g['concepts'][0]['name'], g['concepts'][0]['id'], t['predicateName'], g['concepts'][1]['name'],
                             g['relationships'][0]['concept1Id'], g['score']])
    gene_ids.append(g['relationships'][0]['concept1Id'])
output_file.close()

# First gene is nonsense, and therefore removed
gene_ids = gene_ids[1:]

# Physiologic Function
output_file = open("parkinson_adjacent_physiology.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
physiology = c.getDirectlyConnected(start_genes, ["T039"])
physiology_ids = []
for p in physiology:
    #csv_writer.writerow([p['concepts'][1]['name'], p['relationships'][0]['concept1Id'], p['score'], p['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(p['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([p['concepts'][0]['name'], p['concepts'][0]['id'], t['predicateName'], p['concepts'][1]['name'],
                             p['relationships'][0]['concept1Id'], p['score']])
    physiology_ids.append(p['relationships'][0]['concept1Id'])
output_file.close()

# Get all human (& maybe model animal??) genes associated with the genes mentioned above
indirect_disease = c.getDirectlyConnected(disease_ids, ["T032"], linkweight= "PWS")
indirect_anatomy = c.getDirectlyConnected(anatomy_ids, ["T032"], linkweight= "PWS")
indirect_chemicals = c.getDirectlyConnected(chemical_ids, ["T032"], linkweight= "PWS")
indirect_physiology = c.getDirectlyConnected(physiology_ids, ["T032"], linkweight= "PWS")
indirect_genes = c.getDirectlyConnected(gene_ids[0:10], ["T032"], linkweight= "PWS")

all = indirect_disease + indirect_anatomy + indirect_chemicals + indirect_physiology + indirect_genes

output_file = open("indirect_all.csv", "w")
csv_writer = csv.writer(output_file, delimiter = ";")
for p in all:
    #csv_writer.writerow([p['concepts'][1]['name'], p['relationships'][0]['concept1Id'], p['score'], p['relationships'][0]['tripleIds']])
    triple_data = c.getTriples(p['relationships'][0]['tripleIds'])
    for t in triple_data:
        csv_writer.writerow([p['concepts'][0]['name'], p['concepts'][0]['id'], t['predicateName'], p['concepts'][1]['name'],
                             p['relationships'][0]['concept1Id'], p['score']])
    physiology_ids.append(p['relationships'][0]['concept1Id'])
output_file.close()

