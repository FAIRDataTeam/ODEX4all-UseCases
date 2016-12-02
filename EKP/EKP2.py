class connection:
    # Set up a connection with the Euretos Knowledge platform.
    # Includes methods to execute various queries.
    # Requires a config file with the username, password, and url as a parameter.

    def __init__(self, config):
        # Load packages required for the connection.
        # Set variables required in the class.
        # Execute functions to get variables from the platform, and set them.
        self.logging = __import__("logging")
        self.r = __import__("requests")
        self.json = __import__("json")
        self.url = config['address']['url']
        self.directory = config['directory']['dir']
        self.username = config['credentials']['username']
        self.password = config['credentials']['password']
        self.token = self.getToken()
        self.Types = self.getSemanticTypes()
        self.ST_hierarchy = self.Types[0]
        self.ST_map = self.Types[1]
        self.rev_map = {v: k for k, v in self.Types[1].items()}
        self.Categories = self.getSemanticCategories()
        self.Taxonomy = self.getTaxonomy()
        self.Predicates = self.getPredicates()

    def setDirectory(self, sub_directory = None):
        # Create a working directory for the specific date.
        import os, datetime
        if sub_directory is None:
            todays_directory = self.directory + "/" + datetime.datetime.today().strftime("%Y_%m_%d")
        else:
            todays_directory = self.directory + "/" + sub_directory + "/" + datetime.datetime.today().strftime("%Y_%m_%d")
        if not os.path.exists(todays_directory):
            os.makedirs(todays_directory)
        os.chdir(todays_directory)
        self.logging.info("Set working directory to " + todays_directory)

    def getToken(self):
        # Get the authorization token to access the platform.
        call = "/login/authenticate"
        payload = {'username': self.username, 'password': self.password}
        token = self.r.post(self.url + call, json=payload)
        self.logging.info("Requested token at " + self.url + call)
        if token.ok:
            self.logging.debug("Connection accepted with token " + token.json()['token'])
            return token.json()['token']
        else:
            print("Could not connect to the server")
            self.logging.critical("Failed to set up connection")

    def getSemanticCategories(self):
        # Get the list of Semantic Categories.
        SC = self.r.get(self.url + "/external/semantic-categories",
                   headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
        self.logging.debug("Retrieved semantic categories from platform")
        categories = []
        for sc in SC:
            categories.append(sc['name'])
        return categories

    def getSemanticTypes(self):
        # Get a dictionary of Semantic Types, their codes and their Semantic Categories.
        SemanticTypes = self.r.get(self.url + "/external/semantic-types",
                   headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        ST = SemanticTypes['content']

        for page in range(0, SemanticTypes['totalPages'] + 1):
            ST += self.r.get(self.url + "/external/semantic-types", params = {"page" : page},
                            headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
        self.logging.debug("Retrieved semantic types from platform")
        types_dictionary = {}
        code_map = {}
        for st in ST:
            if st['semanticCategory'] in types_dictionary.keys():
                types_dictionary[st['semanticCategory']][st['name']] = st['id']
            if st['semanticCategory'] not in types_dictionary.keys():
                types_dictionary[st['semanticCategory']] = {st['name'] : st['id']}
            code_map[st['name']] = st['id']
        return [types_dictionary, code_map]

    def getPredicates(self, raw = False):
        if type(raw) is not bool:
            return "Function requires boolean operator to work"
        # Get all predicates, and their mapped codes. Their definitions can be obtained as well by setting "raw" to True.
        response = self.r.get(self.url + "/external/predicates", headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        predicates = response['content']
        for page in range(1, response['totalPages']):
            predicates += self.r.get(self.url + "/external/predicates", params = {"page" : page}, headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
        self.logging.debug("Retrieved list of predicates from platform")
        if raw:
            return predicates
        if raw == False:
            predicates_dictionary = {}
            for p in predicates:
                predicates_dictionary[p['id']] = p['name']
            return predicates_dictionary

    def mapPredicate(self, predicate_id):
        # A number of functions only return predicate ID's. This function easily maps these ID's to their labels.
        return self.Predicates[predicate_id]

    def Predicates(self):
        print("\n".join(list(self.Predicates.values()).sort()))

    def updateTaxonomy(self):
        # Get a list of all taxonomies in the database, and write it out to a file.
        import csv
        Taxonomy = []
        response = self.r.post(self.url + "/external/taxonomies", headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        for t in response['content']:
            Taxonomy.append(t["name"])
        for page in range(1, response['totalPages']):
            page_response = self.r.post(self.url + "/external/taxonomies", params = {"page" : page}, headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
            for p in page_response:
                Taxonomy.append(p['name'])
        self.logging.debug("Extracted list of taxonomies from platform")
        taxonomy_file = open(self.directory + "/Taxonomy.csv", "w")
        out = csv.writer(taxonomy_file)
        for t in Taxonomy:
            out.writerow([t])
        taxonomy_file.close()
        self.logging.info("Written new taxonomy file")

    def getTaxonomy(self):
        # Read in the Taxonomy from a pre-written file (Re-loading the taxonomy every time the class is created takes a long time).
        import csv
        taxonomy_file = open(self.directory + "/Taxonomy.csv", "r")
        reader = csv.reader(taxonomy_file)
        Taxonomy = []
        for line in reader:
            Taxonomy.append(line[0])
        self.logging.debug("Loaded taxonomy file")
        return Taxonomy

    def SemanticTypes(self):
        # Pretty print the Semantic Types.
        print(self.json.dumps(self.Types, sort_keys=True, indent=4, separators=(',', ': ')))

    def SemanticCategories(self):
        # Pretty print the Semantic Categories.
        print(self.json.dumps(self.Categories, sort_keys=True, indent=4, separators=(',', ': ')))

    def execute(self, api_call, query, parameters):
        # Generic execution function. Api-call, json-query, paramters have to be customly defined and supplied.
        # As it will be commonly be used for more complex calls, it is set to POST.
        self.logging.info("Executing " + api_call + "\n with query " + str(query) + "\n with parameters " + str(parameters))
        response = self.r.post(self.url + api_call, json = query, params = parameters, headers = {'Content-type': 'application/json', "X-Token": self.token}).json()
        if 'content' in response.keys():
            self.logging.info("Returned " + str(len(response)) + " items")
            return response['content']
        else:
            return response

    def mapSemanticType(self, semanticType):
        # Input semantic types should always be supplied as a "T" code.
        # This function checks whether this is the case, and if not maps it to a semantic type code.
        if semanticType[0] == "T" and str.isnumeric(semanticType[1:3]):
            return semanticType
        elif semanticType in self.ST_map.keys():
            return self.ST_map[semanticType]
        else:
            return "Could not map your input to a Semantic Type"

    def createFilter(self, semantics):
        # Create a filtergroup which can be used in multiple functions.
        filtergroup = []
        for sem in semantics:
            if sem in self.Categories:
                filtergroup += ["sc:" + sem]
            elif sem in self.ST_map.keys():
                filtergroup += ["st:" + self.ST_map[sem]]
            elif sem in self.ST_map.values():
                filtergroup += ["st:" + sem]
            elif sem in self.Predicates.values():
                filtergroup += ["pred:" + list(self.Predicates.keys())[list(self.Predicates.values()).index(sem)]]
            elif sem.lower() in self.Taxonomy:
                filtergroup += ["tax:" + sem.lower()]
            else:
                print("Cannot map " + sem)
                continue
        self.logging.debug("Created filtergroup " + str(filtergroup))
        return filtergroup

    def getID(self, term, semantics = None, source = None, **kwargs):
        # Map an input term/code to a concept identifier.
        call = "/external/concepts/search"
        qs = "term : '" + term + "'"
        if semantics is not None:
            if semantics in self.Categories:
                qs += " AND semanticcategory : '" + semantics + "'"
            if semantics in self.ST_map.keys() or semantics in self.ST_map.values():
                qs += " AND semantictype : '" + str(int(self.mapSemanticType(semantics).split("T")[1])) + "'"
        if source is not None:
            qs += " AND source : '" + source + "'"
        query =     {
                    "additionalFields": ["synonyms", "source"],
                    "queryString":  qs,
                    "searchType": "TOKEN",
                    "hasTriples": "False"
                    }
        self.logging.info("Executing " + call + " with query " + str(query))
        concept = self.r.post(self.url + call, json=query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        self.logging.info("Returned " + str(len(concept)) + " concepts, " + str([x['id'] for x in concept['content']]))
        return concept

    def getConcepts(self, IDs):
        # Get the details of a list of concepts. Takes a list as input.
        call = "/external/concepts"
        query =     {
                    "additionalFields": ["synonyms", "description", "semanticCategory", "semanticTypes", "taxonomies", "measures", "accessMappings", "hasTriples", "source", "knowledgebase"],
                    "ids" : IDs
                    }
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        return response

    def getDirectRelationship(self, start, end, linkweight = "PWS"):
        # Get the direct relationships between (sets of) concepts.
        call = "/external/concept-to-concept/direct"
        query =     {
                    "additionalFields":["publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes", "taxonomies"],
                    "leftInputs": start,
                    "rightInputs": end,
                    "relationshipWeightAlgorithm": linkweight,
                    "sort": "DESC"
                    }
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        if 'content' in response.keys():
            connections = response['content']
            if response['totalPages'] > 1:
                for page in range(1, response['totalPages']):
                    connections += self.r.post(self.url + call, json = query, params = {"page" : page}, headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
                self.logging.info("Returned " + str(len(connections)) + " items")
                return connections
            else:
                return response
        else:
            return response

    def getIndirectRelationship(self, start, end, intermediateFilters, linkweight = "PWS"):
        # Get all the indirect relationships between (sets of) concepts
        # Requires a filter for the intermediate concepts (Semantic category/type, species, etc.)
        # Filters can be created the createFilter function
        call = "/external/concept-to-concept/indirect"
        query =     {
                    "additionalFields": ["publicationIds", "tripleIds", "predicateIds", "semanticCategory", "semanticTypes", "taxonomies"],
                    "leftInputs": start,
                    "rightInputs": end,
                    "positiveFilters" : intermediateFilters,
                    "relationshipWeightAlgorithm": linkweight,
                    "sort": "DESC"
                    }
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        if 'content' in response.keys():
            if response['totalPages'] > 1:
                connections = response['content']
                for page in range(1, response['totalPages']):
                    connections += self.r.post(self.url + call, json = query, params = {"page" : page}, headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
                self.logging.info("Returned " + str(len(connections)) + " items")
                return connections
            else:
                return response
        else:
            return response

    def getDirectlyConnected(self, input_concepts, input_semantics, linkweight = "PWS", **kwargs):
        # Get all concepts of a selected semantic type/category, which are directly connected to the input-concepts.
        call = "/external/concept-to-semantic/direct"
        semantics = self.createFilter(input_semantics)
        query =     {
                    "additionalFields": ["publicationIds", "tripleIds", "predicateIds", "taxonomies"],
                    "leftInputs": input_concepts,
                    "rightInputs": semantics,
                    "relationshipWeightAlgorithm": linkweight,
                    "sort": "DESC"
                    }
        if 'positive' in kwargs.keys():
            query.update({"positiveFilters" : kwargs['positive']})
        if 'negative' in kwargs.keys():
            query.update({"negativeFilters": kwargs['negative']})
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        if response['totalPages'] > 1:
            output = response['content']
            for page in range(1, response['totalPages']):
                output += self.r.post(self.url + call, json=query, params = {"page" : page}, headers={'Content-type': 'application/json', "X-Token": self.token}).json()['content']
            self.logging.info("Returned " + str(len(output)) + " paths")
            return output
        else:
            return response['content']

    def getTriples(self, triple_ids):
        # Get data about triples. Takes a list of triple ID's as input.
        call = "/external/triples"
        query =     {
                    "additionalFields": ["predicateName", "measures", "accessMappings", "publicationIds"],
                    "ids": triple_ids
                    }
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        self.logging.info("Returned " + str(len(response)) + " triples")
        return response

    def getPubliciations(self, pub_ids):
        # Get data about publications. Takes a list of publication ID's as input.
        call = "/external/publications"

        # Platform cannot handle too many pub ids at once, therefore long lists of pub ids are split up.
        # Chunks function should help with this

        def chunks(l, n):
            """Yield successive n-sized chunks from l."""
            for i in range(0, len(l), n):
                yield l[i:i + n]

        partition = list(chunks(pub_ids, 10))

        out = []

        for part in partition:
            query =     {
                    "additionalFields": ["sourceId", "sourceName", "meshHeadList", "publicationDateHumanReadableUTC", "accessMappings", "measures"],
                    "ids": part
                    }
            self.logging.info("Executing " + call + " with query " + str(query))
            response = self.r.post(self.url + call, json = query, headers={'Content-type': 'application/json', "X-Token": self.token})
            if response.ok and 'message' not in response.json():
                out += response.json()
        self.logging.info("Returned " + str(len(out)) + " publications")
        return out

    # Get ONLY the number of concepts related to the input concept(s). Additional parameter is the semantic type
    def getConceptCount(self, ids, categories):
        call = "/external/direct-connections-count/semantic-types"
        query =     {
            "additionalFields": ["taxonomies", "totalCount"],
            "ids": ids,
            "semanticCategories": categories
        }
        self.logging.info("Executing " + call + " with query " + str(query))
        response = self.r.post(self.url + call, json=query,
                               headers={'Content-type': 'application/json', "X-Token": self.token}).json()
        if len(response) > 1:
            out = {}
            for j in response:
                out[j['name']] = j['count']
        else:
            out = response
        return out