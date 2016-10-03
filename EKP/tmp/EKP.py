'''
Created on Oct 24, 2015

@author: Wytze
'''

# Load the required packages
import requests as r


# ------------------------------- Knowledge platform functions -------------------------------#

# Get the login token
def getToken(username, password, url):
    query = "/login/authenticate"
    payload = {'username': username, 'password': password}
    token = r.post(url + query, json=payload)
    return token


# Map the terms to nodes
def getID(url, Types, token_key, input_term, input_group=None):
    if type(input_group) is list:
        return "This function is for single Semantic Types only. Please use custom functions for multiple Semantic Types"

    query = "/concept/searchWithSemantic"

    term = {"term": input_term,
            "type": "CONCEPT",
            "searchModel": "EXACT"}

    if input_group is not None and input_group in Types[1]:
        term.update({
            "semanticParam": {
                "valueType": "CATEGORY",
                "value": input_group
            }})

    if input_group is not None and len(input_group) == 4:
        term.update({
            "semanticParam": {
                "valueType": "TYPE",
                "value": input_group
            }})

    if input_group is not None and len(input_group) > 4 and input_group not in Types[1]:
        if input_group in Types[0].keys():
            term.update({
                "semanticParam": {
                    "valueType": "TYPE",
                    "value": str(Types[0][input_group])
                }})
        else:
            return "Could not map your given input group to Semantic Type code"

    ID = r.post(url + query, json=term, headers={"X-Token": token_key}).json()

    return ID


def getConcept(ID, url, token_key):
    query = "/concept/"

    return r.get(url + query + str(ID), headers={"X-Token": token_key}).json()


# Get the directly related concepts of selected semantic type
def getDirectlyConnectedConcepts(Types, token_key, url, concepts, category, input_group = None):
    query = "/keywordToSemanticType/direct"

    if type(concepts) is list:
        input_concepts = concepts
    else:
        input_concepts = [concepts]

    term = {
        "sort": "DESC",
        "inputTerms": input_concepts,
        "linkWeightAlgorithm": "pws",
        "semantics": [{"category": category}]
    }

    if input_group is not None:
        if type(input_group) is list:
            input_list = []
            for s in input_group:
                if input_group[0] == "T" and str.isnumeric(input_group[1:3]):
                    input_list.append({"id": s})
                elif s in Types[0].keys():
                    input_list.append({"id": Types[0][s]})
                else:
                    return "Could not map your input to Semantic Type"
            term.update({"semantics": [{"category": category, "types": input_list}]})

        else:
            if input_group[0] == "T" and str.isnumeric(input_group[1:3]):
                term.update({"semantics": [{"category": category, "types": [{"id": input_group}]}]})

            elif input_group in Types[0].keys():
                term.update({"semantics": [{"category": category, "types": [{"id": Types[0][input_group]}]}]})
            else:
                return "Could not map your input to existing semantic types"

    print(term)

    out = r.post(url + query, json=term, params={"page": 0, "size": 10}, headers={"X-token": token_key}).json()
    # Results get returned in pages. If there is only 1 page then this is returned. If there is more than 1 page, the contents are appended
    if 'totalPages' in out.keys() and out['totalPages'] > 1:
        for i in range(1, out['totalPages'] + 1):
            print("Getting page " + str(i))
            add_data = r.post(url + query, json=term, params={"page": i, "size": 10},
                              headers={"X-token": token_key}).json()
            out['content'] += add_data['content']
    return out


# Get the indirectly related concepts of selected semantic types
def getIndirectlyConnectedConcepts(concept, token_key, url):
    query = "/keywordToSemanticType/indirect"

    # TODO: Bepalen of ik de excludePublicationInfo aan of uitzet
    term = '''{
                  "inputTerms": [
                    "''' + concept + '''"
                  ],
                  "excludePublicationsInfo": true
                }'''

    concepts = r.post(url + query + term + token_key)

    return concepts


# Get the relationships between concepts

def getRelationships(concept1, concept2, url, token_key):
    query = "/relationships/direct"

    term = {
        "lhKeywords": concept1,
        "rhKeywords": concept2,
        "sort": "DESC",
        "linkWeightAlgorithm": "PWS"
    }

    print(term)
    relationships = r.post(url + query, json=term, headers={"X-Token": token_key}).json()

    if 'totalPages' in relationships.keys() and relationships['totalPages'] > 1:
        for i in range(1, relationships['totalPages'] + 1):
            print("Getting page " + str(i))
            add_data = r.post(url + query, json=term, params={'page': i, 'size': 10},
                              headers={"X-Token": token_key}).json()
            relationships['content'] += add_data['content']

    return relationships

def getIndirectRelationships(concept1, concept2, Types, url, token_key, category, semantic_type = None):
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

    if semantic_type is not None:
        if semantic_type[0] == "T" and str.isnumeric(semantic_type[1:3]):
            term["complexSearchSetting"]["semantics"][0].update({"types" : [{ "id" : semantic_type }]})
        else:
            term["complexSearchSetting"]["semantics"][0].update({"types" : [{ "id" : Types[0][semantic_type] }]})

    print(term)
    relationships = r.post(url + query, json=term, headers={"X-Token": token_key}).json()

    if 'totalPages' in relationships.keys() and relationships['totalPages'] > 1:
        for i in range(1, relationships['totalPages'] + 1):
            print("Getting page " + str(i))
            add_data = r.post(url + query, json=term, params={'page': i, 'size': 10},
                              headers={"X-Token": token_key}).json()
            relationships['content'] += add_data['content']

    return relationships


# Get the sources related to a relationship
def getPublications(triple_id, url, token_key):
    query = "/triple/getPublicationUuids"

    term = {
        "uids": [
            triple_id
        ]
    }

    pub_id = r.post(url + query, json=term, headers={"X-Token": token_key})

    if pub_id.status_code == 200:
        if len(pub_id.json()) > 0:
            pub_term = {'ids': pub_id.json()}
            publications = r.post(url + "/publications/", json = pub_term, headers={"X-Token": token_key}).json()
    return publications


# List all semantic type codes and categories, to be used as input later on
def getSemanticTypeDict(url, token_key):
    d = r.get(url + "/semantic/categories", headers={'Content-type': 'application/json', "X-Token": token_key}).json()
    cat_list = []
    type_dict = {}
    for c in d:
        cat_list.append(c['category'])
        for t in c['types']:
            type_dict[t['name']] = t['id']
    return [type_dict, cat_list]


# Logout the token
def logout(token_key, url):
    return r.get(url, json={"X-token": token_key})
