# Load the connection
from scripts.EKP.EKP2 import connection

# Get the config file
import configparser
config = configparser.ConfigParser()
config.read('scripts/EKP/config.ini')


c = connection(config)
#c.setDirectory("Roche")

migraine = c.getID("migraine", "Disorders")[0]['id']
headache = c.getID("headache", "Disorders")[0]['id']

custom_filter = c.createFilter(["Chemicals & Drugs"])
test = c.getIndirectRelationship([migraine], [headache], custom_filter)

c.getDirectRelationship([migraine], [headache])