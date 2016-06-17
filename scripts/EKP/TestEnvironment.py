# Load the connection
from scripts.EKP.EKP2 import connection

# Get the config file
import configparser
config = configparser.ConfigParser()
config.read('scripts/EKP/config.ini')


c = connection(config)
c.setDirectory("Roche")