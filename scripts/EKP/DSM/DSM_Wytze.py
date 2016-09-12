# Due to the composite way in which the concept "Butanol tolerance" is modelled, I (Wytze) have created my own testsuite to play around with the data.

# Load the connection
from scripts.EKP.EKP2 import connection
import os
import configparser
import logging
os.chdir('/Users/Wytze/git/ODEX4all-UseCases/scripts/EKP')
logging.basicConfig(filename='logs/DSM.log',level=logging.DEBUG)
logging.info("===================== Started a new session =====================")

config = configparser.ConfigParser()
config.read('config.ini')

# Set up the connection
c = connection(config)

# Because Butanol Tolerance is represented as a compound concept, we cannot directly work with it.
# Instead, we have to extract the concepts between "Butanol" and "Resistance to Chemicals", and use those as a proxy.

# Using the UMLS ID of 1-Butanol because it is more specific, and the SGD ID of chemical resistance for the same reason.
butanol = c.getID("c0089147")[0]['id']
resistance = c.getID("apo:0000087")[0]['id']

intermediate_filter_chem = c.createFilter(["Chemicals & Drugs"])
intermediate_filter_genes = c.createFilter(["Genes & Molecular Sequences"])

but_chem_res_id = []
direct_but_tolerance_chem = c.getIndirectRelationship([butanol], [resistance], intermediate_filter_chem)
for i in direct_but_tolerance_chem:
    but_chem_res_id.append(i['concepts'][1]['id'])

but_gene_res_id = []
direct_but_tolerance_genes = c.getIndirectRelationship([butanol], [resistance], intermediate_filter_genes)
for i in direct_but_tolerance_genes:
    but_gene_res_id.append(i['concepts'][1]['id'])

# Now we have our proxys (Genes and chemicals associated with butanol tolerance).
# These have to be used for the rest of the process.

# First we get the relationships between the relevant genes and chemicals
genes_to_chemicals = c.getDirectRelationship(but_chem_res_id, but_gene_res_id)