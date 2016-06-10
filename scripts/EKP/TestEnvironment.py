
# Load the connection
from EKP2 import connection

# Get the config file
import configparser
config = configparser.ConfigParser()
config.read('config.ini')


c = connection(config)
