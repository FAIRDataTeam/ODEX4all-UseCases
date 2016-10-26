# Get the full text from Elsevier using a developer API key
# For full details, please see http://api.elsevier.com/documentation/FullTextRetrievalAPI.wadl
# Key and account can be obtained at https://dev.elsevier.com/index.html

import requests as r
import configparser

config = configparser.ConfigParser()
config.read('Miscellaneous/config.ini')

base_url = "http://api.elsevier.com/content/article/doi/"
doi = "10.1016/j.jbi.2008.12.001"

doc = r.get(base_url + doi, headers = {"accept" : "application/json", "X-ELS-APIKey" : config['credentials']['api-key']})

document = doc.json()