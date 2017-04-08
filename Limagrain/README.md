## Explaination of files:

### data folder: 
consists of Crop Ontology terms, Title Terms (List provided by Limagrain), Keywords list (provided by Limagrain).
Corpus is not in this folder for confidentiality reasons.

### src folder:  
#### CO_322.csv: Crop ontology terms for maize downloaded from Crop Ontology website (http://www.cropontology.org/)

#### Limagrain.png: Workflow of the notebook.

#### dic_CO_key_title.csv: Dictionary of combined terms
#### dictionary_CO_Title_Key_Form_OpenRefine.json: Steps required to clean the dictionary, this can be opened in tool called Open Refine (http://openrefine.org/). This file is reusable for any dictionary that may require necessary cleaning.

### Jupyter notebook : 
#### tm_PatentDocs_V2.ipynb Gives detailed explaination and analysis of the workflow including results at each steps
#### tm_PatentDocs_V2.R is its equavalent script including "cross validation of data" steps commented out 

### Document Term Matrix: dtm_Abstracts_dwpi_CO_Key_Title.csv
