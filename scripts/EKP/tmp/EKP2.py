'''
Created on March 1, 2016

@author version 1: Wytze
@author version 2: Jarno van Erp
'''

# Load the required packages
import requests as r
import json


# ------------------------------- Knowledge platform functions -------------------------------#

class EKPsearch:
	'''
	A class that puts request into the Euretos knowledge platform. 
	Retrieving information from it and processing it.
	'''
	def __init__(self, username, password, url):
		self.url = url
		self.getToken(username, password)
		
	# Get the login token
	def getToken(self, username, password):
		'''
		Retrieves a token from Euretos. This token is used as an identifier with the database.
		Parameters:
		username: String that contains your username (can be edited in config.ini)
		password: String that contains your password (can be edited in config.ini)
		'''
		query = "/login/authenticate"
		payload = {"username": username, "password": password}
		self.token = r.post(self.url + query, json=payload)
		print self.token
		
	# Map the terms to nodes
	def getID(self, input_term, **filters):
		'''
		Retrieves the ID from the EKP.
		Parameters:
		**filters: can contain three variables that are used as filters to make the search more specific.
		These variables can be:
		filter_category: a list with all the categories you want to specify to.
		filter_typeID: a list with all the type IDs you want to specify to.
		filter_typename: a list with all the type names you want to specify to.
		input_term: The concept you want to know the ID from.
		Returns:
		ID: A dictionary with the name as a value and the ID as a key.
		'''
		filter_category = filters.get("filter_category", None)
		filter_typeID = filters.get("filter_typeID", None)
		filter_typename = filters.get("filter_typename", None)
		query = "/concept/searchWithSemantic"
		term = {"term": input_term,
				"type": "CONCEPT",
				"searchModel": "EXACT"}
		if filter_category: 
				term.update({
					"semanticParam": {
						"valueType": "CATEGORY",
					"value": filter_category
					}})
		if filter_typeID:
				term.update({
					"semanticParam": {
						"valueType": "TYPE",
						"value": filter_typeID
				}})
		elif filter_typename:
			if filter_typename in self.semantictypes_dict.keys():
					term.update({
						"semanticParam": {
							"valueType": "TYPE",
							"value": str(self.semantictypes_dict[filter_typename])
						}})
			else:
				return "Could not map your given input group to Semantic Type code"
		ID = r.post(self.url + query, json=term, headers={"X-Token": self.token}).json()
		return ID


	def getConcept(self, ID):
		'''
		Get the concept name of a ID.
		parameters:
		ID: you want the name of this ID.
		returns:
		a dictionary with the ID and name.
		'''
		query = "/concept/"
		return r.get(self.url + query + str(ID), headers={"X-Token": self.token}).json()


	# Get the directly related concepts of selected semantic type
	def getDirectlyConnectedConcepts(self, concepts, category, **filters):
		'''
		This function accepts
		
		'''
		filter_typeID = filters.get('filter_typeID', None)
		filter_typename = filters.get('filter_typename', None)
		query = "/keywordToSemanticType/direct"
		term = {
			"sort": "DESC",
			"inputTerms": concepts,
			"linkWeightAlgorithm": "pws",
			"semantics": [{"category": category}]
		}			
		if filter_typeID:
			if type(filter_typeID) is list:
				filter_list = []
				for typeID in filter_typeID:
					filter_list.append({"id": typeID})
				term.update({"semantics": [{"category": category, "types": filter_list}]})
			else:
				term.update({"semantics": [{"category": category, "types": [{"id": filter_typeID}]}]})
		if filter_typename:
			if type(filter_typename) is list:
				filter_list = []
				for typename in filter_typename:
					if typename in self.semantictypes_dict.values():
						term.update({"semantics": [{"category": category, "types": [{"id": self.semantictypes_dict[typename]}]}]})
			else:
				term.update({"semantics": [{"category": category, "types": [{"id":  self.semantictypes_dict[filter_typename]}]}]})

		print(term)
		out = r.post(self.url + query, json=term, params={"page": 0, "size": 10}, headers={"X-token": self.token}).json()
		print('ey')
		# Results get returned in pages. If there is only 1 page then this is returned. If there is more than 1 page, the contents are appended
		if 'totalPages' in out.keys() and out['totalPages'] > 1:
			for i in range(1, out['totalPages'] + 1):
				print("Getting page " + str(i))
				add_data = r.post(self.url + query, json=term, params={"page": i, "size": 10},
								headers={"X-token": self.token}).json()
				out['content'] += add_data['content']
		return out


	# Get the relationships between concepts
	def getRelationships(self, concept1, concept2):
		'''
		Searches if the two concepts have a relation with each other according to EKP.
		A list can contain one or more IDs, but one is preferred so we do not overload the database.
		Parameters:
		concept1: a list with concept IDs.
		concept2: a list with concept IDs.
		Returns: 
		relationships: a dictionary for each relation all the relationships these two concepts have.		
		'''
		query = "/relationships/direct"
		term = {
			"lhKeywords": concept1,
			"rhKeywords": concept2,
			"sort": "DESC",
			"linkWeightAlgorithm": "PWS"
		}
		respo = r.post(self.url + query, json=term, headers={"X-Token": self.token})
		relationships = respo.json()
		if 'totalPages' in relationships.keys() and relationships['totalPages'] > 1:
			for i in range(1, relationships['totalPages'] + 1):
				print("Getting page " + str(i))
				add_data = r.post(self.url + query, json=term, params={'page': i, 'size': 10},
								headers={"X-Token": self.token}).json()
				relationships['content'] += add_data['content']

		return relationships

	def getIndirectRelationships(self, concept1, concept2, category, semantic_type = None):
		'''
		Searches if two concepts have an indirect relation with each other.
		parameters:
		concept1: the ID of the first  concept.
		concept2: a list containing one or more the IDs 
		category: a semantic category, can be used to specify the search.
		semantic_type: a semantic type, can be used to specify the search. Can be an ID or name.
		Returns:
		relationships: a list with dictionaries. Each dictionary contains information about one specific indirect relation.
		'''
		query = "/relationships/indirect"
		term = {
			"complexSearchSetting": {
				"semantics": [
				{
					"category": category
				}
				]
			},
			"sort": "DESC",
			"lhKeywords": concept1,
			"rhKeywords": concept2,
			"linkWeightAlgorithm": "pws"
			}
		if semantic_type:
			if semantic_type == "T" and str.isdigit(semantic_type[1:3]):
				term["complexSearchSetting"]["semantics"][0].update({"types" : [{ "id" : semantic_type }]})
			else:
				term["complexSearchSetting"]["semantics"][0].update({"types" : [{ "id" : self.semantictypes_dict[semantic_type] }]})

		print(term)
		relationships = r.post(self.url + query, json=term, headers={"X-Token": self.token}).json()

		if 'totalPages' in relationships.keys() and relationships['totalPages'] > 1:
			for i in range(1, relationships['totalPages'] + 1):
				print("Getting page " + str(i))
				add_data = r.post(self.url + query, json=term, params={'page': i, 'size': 10},
								headers={"X-Token": self.token}).json()
				relationships['content'] += add_data['content']

		return relationships


	# Get the sources related to a relationship
	def getPublications(self, triple_id):
		'''
		Gets all the publications that function as prove for the relation.
		Parameters:
		triple_id: id for the triple, used to find the publications.
		Returns:
		publications: a list with dictionaries. Each dictionary contains the details about the publication.
		'''
		query = "/triple/getPublicationUuids"

		term = {
			"uids": [
				triple_id
			]
		}

		pub_id = r.post(self.url + query, json=term, headers={"X-Token": self.token})

		if pub_id.status_code == 200:
			if len(pub_id.json()) > 0:
				pub_term = {'ids': pub_id.json()}
				publications = r.post(self.url + "/publications/", json = pub_term, headers={"X-Token": self.token}).json()
				return publications


	# List all semantic type codes and categories, to be used as input later on
	def setSemanticTypeDict(self):
		'''
		Gets all the categories with their types from the EKP and parses 
		them to a dictionary with all the types (name as key and id as 
		value) and a list with all the names of the categories and returns this.
		'''
		respone_dict = r.get(self.url + "/semantic/categories", headers={'Content-type': 'application/json', "X-Token": self.token}).json()
		self.categories_list = []
		types_dict = {}
		print respone_dict
		for category in respone_dict:
			self.categories_list.append(category['category'])
			for types in category['types']:
				types_dict[types['name']] = types['id']
		self.semantictypes_dict = types_dict

	def nametoID(self, name_list, **filters):
		'''
		Give a list of names that you want the ID from.
		Parameters:
		name_list: a list containing all the names that you want the ID from.
		self.semantictypes_dict: 
		Returns:
		input_ids: a dictionary containing the name (value) and the ID (key) of every name in the 
		name_list that is present in EKP.
		'''
		input_ids = {}
		notfoundcommensals = []
		for name in name_list:
			ID = self.getID(name, **filters)
			print ID
			if len(ID) > 0:
				print ' hallo'
				ID = {ID[0]['id']: ID[0]['name']}
				print ID
				input_ids.update(ID)
			else:
				notfoundcommensals.append(name)
		return input_ids, notfoundcommensals
		
	# Logout the token
	def logout(self):
		'''
		Ends your connection with the EKP.
		'''
		return r.get(self.url, json={"X-token": self.token})
