'''
Author: Jarno van Erp
Date created: 1/3/2016
Function: Retrieve information from the Euretos knowledge patform and parse indirect relations to a tab delimited file.
Version: 0.1

Arguments:
-f file Give the filename, filepath if needed, that you want to use, put the filename between ''
-l y/n If you want to update the log file with this run. Default is y
'''
from EKP2 import EKPsearch
import ConfigParser
import argparse
import os
import csv
import datetime
import time
import AnalyzeResults
import sys

opts = parser.parse_args()
config = ConfigParser.ConfigParser()
config.read("config.ini")
sections = config.sections()

def main():
	'''
	Main function, used to connect the other functions.
	'''
	os.chdir(config.get('files', 'location'))
	url = config.get('log in', 'url')
	username = config.get('log in', 'username')
	password = config.get('log in', 'password')
	#instantiate an object that gets used for searching in EKP.
	EKP = EKPsearch(username, password, url)
	#Retrieve all categories and semantic types in EKP.
	EKP.setSemanticTypeDict()
	commensals_list = csvcommensalstoIDs()
	filter_typename = config.get('groups', 'input')
	input_ids, notfoundcommensals = EKP.nametoID(commensals_list, filter_typename=filter_typename)
	print input_ids
	output_name = getEKPrelations(EKP, input_ids)
	if opts.log == 'y':
		log_file.write("The number of unfound commensals were "+str(len(notfoundcommensals)))
		AnalyzeResults.main(output_name, log_file)
	EKP.logout()

def csvcommensalstoIDs():
	'''
	Reads the input csv file and checks if the commensals are in the
	Euretos Knowledge Platform, if so the name and ID gets added to a
	dictionary which it returns.
	Returns:
	commensals_list: a list with all the commensals that were in the file infile.
	'''
	infile = opts.infile
	input_file = open(infile, "r")
	reader = csv.reader(input_file, delimiter=";")
	commensals_list = []
	for line in reader:
		commensal = line[0]
		commensals_list.append(commensal)
	input_file.close()
	return commensals_list

def FiletoDict(infile):
	'''
	Parses a tab delimited file to a dictionary. The first colom functions
	as key and the second colom functions as value.
	Parameters:
	infile: a opened file object
	Returns:
	dictionary: a dictionary with the information from the file, where the first column is the key and the second column is the value.
	'''
	dictionary = {}
	for line in infile:
		line = line.replace('\n','')
		line_list = line.split('\t')
		dictionary[line_list[0]] = line_list[1]
	return dictionary

def getEKPrelations(EKP, input_ids):
	'''
	Searches if there are direct and indirect relations between the concept in input_ids.
	Parameters:
	EKP: object used for retrieving information from EKP.
	input_ids: a list with all the IDs from the concepts you are interested in.
	Returns:
	output_name: name of the output file.
	'''
	endpoints_file = open(config.get('files', 'endpoints'), 'r')
	endpoints_dict = FiletoDict(endpoints_file)
	endpoint_ids = []
	print endpoints_dict
	#retrieve EKP IDs for each endpoint concept.
	for point in endpoints_dict.keys():
		endpoint_id = EKP.getID(point)
		if endpoint_id:
			endpoint_ids.append(endpoint_id[0]['id'])
	endpoint_ids = list(set(endpoint_ids))
	#Searche if there are direct relations between two concepts.
	for concept1 in input_ids:
			directRelationships = EKP.getRelationships([concept1], endpoint_ids)
			if 'content' in directRelationships:
				relations = directRelationships['content']
				for relation in relations:
					concept1 = relation['tier0Concept']['name']
					concept2 = relation['tier1Concept']['name']
					predicates = relation['tier01TripleInformation']
					for predicate in predicates:
						predicate_name = predicate['predicateName']
						print concept1 + ' ' + predicate_name + ' '+ concept2
	intermediate_file = open(config.get('files', 'intermediate types'), 'r')
	intermediate_types = FiletoDict(intermediate_file)
	gut = EKP.getID("C0699819")
	intestines = EKP.getID("C0021853")
	indirect_all = []
	gut_all = []
	intestines_all = []
	gut_ID = [gut[0]['id']]
	intestines_ID = [intestines[0]['id']]
	for input_group, category in intermediate_types.items():
		gut_all = searchEKPrelations(EKP, input_group, category, gut_ID, gut_all)
		intestines_all = searchEKPrelations(EKP, input_group, category, intestines_ID, intestines_all)
		inputID_list = list(input_ids.keys())
		response = EKP.getIndirectRelationships(inputID_list, endpoint_ids, category, input_group)
		print(response)
		if 'content' in response.keys():
			indirect_all= indirect_all + response['content']
	output_name = writeoutput(EKP, indirect_all, gut_all, intestines_all)
	return output_name

def searchEKPrelations(EKP, input_group, category, concepts, output_list):
	'''
	Searches EKP for direct relations between concepts.
	Parameters:
	EKP: Object used to search EKP
	input_group: String that functions as a filter for the search
	category: String that functions as a filter for the search
	concepts: List with concepts that you want to find relations inbetween
	output_list: list that gets updated with the information retrieved from EKP.
	Returns:
	output_list: updated list.
	'''
	connected_concepts = EKP.getDirectlyConnectedConcepts(concepts, category, filter_typename=input_group)
	if 'content' in connected_concepts.keys() and len(connected_concepts['content']) > 0:
		for g in connected_concepts['content']:
			output_list.append(g['tier1Concept']['gi'])
	return output_list


def writeoutput(EKP, indirect_all, gut_all, intestines_all):
	'''
	Obtains all the data from the dictionaries and writes them to the outputfile.
	Parameters:
	EKP: Object that retrieves information from the Euretos database
	indirect_all: a list with all the indirect relationships
	gut_all: a list with all the concepts that are in the gut
	intestines_all: a list with all the concepts that are in the intestines
	Returns:
	output_name: name of the output file
	'''
	output_name = "indirect_output_" + datetime.datetime.today().strftime("%Y_%m_%d") + time.strftime("%H:%M") + ".csv"
	output_name_cytoscape = "indirect_output_cyto_" + datetime.datetime.today().strftime("%Y_%m_%d") + time.strftime("%H:%M") + ".csv"
	indirect_out_cytoscape = open(output_name, "w")
	iw_cytoscape= csv.writer(indirect_out_cytoscape, delimiter = ";")
	iw_cytoscape.writerow(["Concept ID 1", "Predicate", "Concept ID 2", "Concept name 1", "Predicate", "Concept name 2", "Path weight", "Sources"])
	indirect_out = open(output_name, "w")
	iw = csv.writer(indirect_out, delimiter = ";")
	iw.writerow(["Starting concept", "Predicate1", "Connecting concept", "Semantic category", "Semantic types", "Predicate2", "End concept", "Found in gut?", "Found in intestines?", "Path weight", "Sources1", "Sources2"])
	triple_list = []
	for relation in indirect_all:
		#instantiating variables.
		start = relation['tier0Concept']['name']
		intermediate = relation['tier1Concept']['name']
		intermediate_cat = relation['tier1Concept']['category']
		intermediate_concept = EKP.getConcept(relation['tier1Concept']['gi'])
		location_ID = relation['tier1Concept']['gi']
		output_STs = ""
		for g in intermediate_concept['semanticTypes']:
			for key, value in EKP.semantictypes_dict.items():
				if g == value:
					output_STs = output_STs + str(key)
		# Hier logica om te filteren op gut & intestines
		gut_bool = False
		intestines_bool = False
		if location_ID in gut_all:
			gut_bool = True
		if location_ID in intestines_all:
			intestines_bool = True
		end = relation['tier2Concept']['name']
		pw = relation['pathWeight']
		nrows = max([len(relation['tier01TripleInformation']), len(relation['tier12TripleInformation'])])
		pubs1 = []
		pubs2 = []
		#searches for publications for each relation
		for w in range(0,nrows):
			if w <= len(relation['tier01TripleInformation']) - 1:
				predicate1 = relation['tier01TripleInformation'][w]['predicateName']
				pub_info = EKP.getPublications(relation['tier01TripleInformation'][w]['tripleUuid'])
				if pub_info:
					for p1 in pub_info['publications']:
						if p1['publicationInfo'] is not None and 'url' in p1['publicationInfo'].keys():
							pubs1.append(p1['publicationInfo']['url'])
			if w <= len(relation['tier12TripleInformation']) - 1:
				predicate2 = relation['tier12TripleInformation'][w]['predicateName']
				pub_info2 = EKP.getPublications(relation['tier12TripleInformation'][w]['tripleUuid'])
				if pub_info2:
					for p2 in pub_info2['publications']:
						if p2['publicationInfo'] is not None and 'url' in p2['publicationInfo'].keys():
							pubs2.append(p2['publicationInfo']['url'])
			iw.writerow([start, predicate1, intermediate, intermediate_cat, output_STs, predicate2, end, gut_bool, intestines_bool, pw,pubs1,pubs2])
			triple1 = start + predicate1 + intermediate
			triple2 = intermediate + predicate2 + end
			# experimental output, could be used for cytoscape but not tested yet.
			if triple1 not in triple_list:
				iw_cytoscape.writerow(["Concept ID 1", predicate1, "Concept ID 2", start, predicate1, intermediate, pw, pubs1])
				triple_list.append(triple1)
			if triple2 not in triple_list:
				iw_cytoscape.writerow(["Concept ID 1", predicate1, "Concept ID 2", intermediate, predicate2, end, pw, pubs2])
				triple_list.append(triple2)
	indirect_out.close()
	return output_name


if __name__ == '__main__':
	'''
	When you call the script form the command line there are a few variables you can initiate.
	Otherwise these variables can be determined by the connecting script.
	'''
	parser = argparse.ArgumentParser(usage=__doc__)
	parser.add_argument('-f', dest='infile',   required=True, help=argparse.SUPPRESS)
	parser.add_argument('-l', dest='log', default='y', help=argparse.SUPPRESS)
	if opts.log == 'y':
		log_file = open('log.txt','a')
		cur_time = time.strftime("%H:%M")
		date = datetime.datetime.today().strftime("%Y_%m_%d")
		log_file.write("------------------------------\n Run on "+str(date)+" "+str(cur_time)+"\n")
	main()

