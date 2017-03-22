-- 
-- Fix database cross-references in Ensembl RDF graphs.
--

log_enable(2) ; -- disable transaction logging & enable row-by-row autocommit
SET u{BASE_URI} http://localhost:8890 ;
SET u{ENSEMBL_RELEASE} 86 ;
SET u{ENSEMBL-SSC_G_URI} http://www.ensembl.org/pig ;
SET u{ENSEMBL-HSA_G_URI} http://www.ensembl.org/human ;
--SET u{BIO2RDF_RELEASE} 4 ;
SET u{BIO2RDF_G_URI} http://bio2rdf.org/omim_resource:bio2rdf.dataset.omim.R4 ;
--SET u{QTLDB_RELEASE} 30 ;
SET u{QTLDB_G_URI} http://www.animalgenome.org/QTLdb/pig ;

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/hgnc') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/hgnc') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;

SPARQL
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s <http://semanticscience.org/resource/SIO:000630> ?o }
INSERT { ?s <http://semanticscience.org/resource/SIO_000630> ?o }
WHERE { ?s <http://semanticscience.org/resource/SIO:000630> ?o } ;

SPARQL
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s <http://semanticscience.org/resource/SIO:000630> ?o }
INSERT { ?s <http://semanticscience.org/resource/SIO_000630> ?o }
WHERE { ?s <http://semanticscience.org/resource/SIO:000630> ?o } ;

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/go') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/go') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;


--
-- Fix SO predicates
--

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s obo:SO_translates_to ?o }
INSERT { ?s so:translates_to ?o }
WHERE { ?s obo:SO_translates_to ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s obo:SO_has_part ?o }
INSERT { ?s so:has_part ?o }
WHERE { ?s obo:SO_has_part ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-SSC_G_URI}>
DELETE { ?s obo:SO_transcribed_from ?o }
INSERT { ?s so:transcribed_from  ?o }
WHERE { ?s obo:SO_transcribed_from ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_translates_to ?o }
INSERT { ?s so:translates_to ?o }
WHERE { ?s obo:SO_translates_to ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_has_part ?o }
INSERT { ?s so:has_part ?o }
WHERE { ?s obo:SO_has_part ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_transcribed_from ?o }
INSERT { ?s so:transcribed_from  ?o }
WHERE { ?s obo:SO_transcribed_from ?o } ;


-- 
-- Add chromosome type to Ensembl RDF graph.
--

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
INSERT INTO <$u{ENSEMBL-SSC_G_URI}> {
   ?chr2 a obo:SO_0000340
}  
WHERE {
   GRAPH <$u{QTLDB_G_URI}> {
      ?chr1 a obo:SO_0000340 .
      BIND(uri(concat('http://rdf.ebi.ac.uk/resource/ensembl/$u{ENSEMBL_RELEASE}/sus_scrofa/Sscrofa10.2/', replace(str(?chr1), '.+/', ''))) AS ?chr2)
   }
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX obo: <http://purl.obolibrary.org/obo/>
--WITH  <$u{ENSEMBL-SSC_G_URI}>
--DELETE WHERE { ?s a obo:SO_0000340 } ;


-- 
-- Cross-link chromosomes in two RDF graphs.
--   graph URI: http://www.animalgenome.org/QTLdb/pig
--     chromosome URI: e.g. http://.../genome/Sus_scrofa/chromosome/17
--
--   graph URI: http://www.ensembl.org/pig
--     chromosome URI: e.g. http://rdf.ebi.ac.uk/resource/ensembl/86/sus_scrofa/Sscrofa10.2/17
--

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
INSERT INTO <$u{QTLDB_G_URI}> {
   ?chr1 owl:sameAs ?chr2
}   
WHERE {
   GRAPH <$u{QTLDB_G_URI}> {
      ?chr1 a obo:SO_0000340 .
      BIND(uri(concat('http://rdf.ebi.ac.uk/resource/ensembl/$u{ENSEMBL_RELEASE}/sus_scrofa/Sscrofa10.2/', replace(str(?chr1), '.+/', ''))) AS ?chr2)
   }
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX owl: <http://www.w3.org/2002/07/owl#>
--WITH  <$u{QTLDB_G_URI}>
--DELETE WHERE { ?s owl:sameAs ?o } ;


--
-- Link chromosomes to ENA accessions.
--

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX pig-chr: <$u{BASE_URI}/genome/Sus_scrofa/chromosome/>
PREFIX ena: <http://identifiers.org/ena.embl/>
INSERT INTO <$u{QTLDB_G_URI}> {
   pig-chr:1 rdfs:seeAlso ena:CM000812.4 .
   pig-chr:2 rdfs:seeAlso ena:CM000813.4 .
   pig-chr:3 rdfs:seeAlso ena:CM000814.4 .
   pig-chr:4 rdfs:seeAlso ena:CM000815.4 .
   pig-chr:5 rdfs:seeAlso ena:CM000816.4 .
   pig-chr:6 rdfs:seeAlso ena:CM000817.4 .
   pig-chr:7 rdfs:seeAlso ena:CM000818.4 .
   pig-chr:8 rdfs:seeAlso ena:CM000819.4 .
   pig-chr:9 rdfs:seeAlso ena:CM000820.4 .
   pig-chr:10 rdfs:seeAlso ena:CM000821.4 .
   pig-chr:11 rdfs:seeAlso ena:CM000822.4 .
   pig-chr:12 rdfs:seeAlso ena:CM000823.4 .
   pig-chr:13 rdfs:seeAlso ena:CM000824.4 .
   pig-chr:14 rdfs:seeAlso ena:CM000825.4 .
   pig-chr:15 rdfs:seeAlso ena:CM000826.4 .
   pig-chr:16 rdfs:seeAlso ena:CM000827.4 .
   pig-chr:17 rdfs:seeAlso ena:CM000828.4 .
   pig-chr:18 rdfs:seeAlso ena:CM000829.4 .
   pig-chr:X rdfs:seeAlso ena:CM000830.4 .
   pig-chr:Y rdfs:seeAlso ena:CM001155.2
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
--PREFIX ena: <http://identifiers.org/ena.embl/>
--WITH <$u{QTLDB_G_URI}>
--DELETE { ?s rdfs:seeAlso ?o }
--WHERE { ?s rdfs:seeAlso ?o . FILTER regex(?o, ena:) } ;


--
-- Add gene-QTL associations (triples) based on overlapping sequence regions.
-- Note: This query might take more than 30 min (using a machine with 4 CPUs, 16 GB RAM).
-- Uncomment the code line corresponding to a 'trait filter' to compute the gene-QTL
-- associations only for a subset of traits, for example:
--   'nipple quantity'    - http://purl.obolibrary.org/obo/VT_1000206
--   'teat number'        - http://purl.obolibrary.org/obo/CMO_0000445
--   'teat number, left'  - http://purl.obolibrary.org/obo/CMO_0000472
--   'teat number, right' - http://purl.obolibrary.org/obo/CMO_0000473
--

SPARQL
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
PREFIX faldo: <http://biohackathon.org/resource/faldo#>
INSERT INTO <$u{QTLDB_G_URI}> {
   ?qtl so:overlaps ?gene
}
WHERE {
   GRAPH <$u{QTLDB_G_URI}> {
      ?qtl a obo:SO_0000771 ;
         faldo:location ?loc ;
         obo:RO_0002610 ?trait .
      ?loc faldo:begin ?begin ;
         faldo:end ?end .
      ?begin faldo:reference ?chr ;
         faldo:position ?begin_pos .
      ?end faldo:position ?end_pos .
      ?chr owl:sameAs ?chr2 .
   }
   GRAPH <$u{ENSEMBL-SSC_G_URI}> {
      ?loc2 faldo:reference ?chr2 ;
         faldo:begin ?begin2 ;
         faldo:end ?end2 ;
         ^faldo:location ?gene .
      ?gene a obo:SO_0001217 .
      ?begin2 faldo:position ?begin_pos2 .
      ?end2 faldo:position ?end_pos2 .
   }
#   FILTER(?trait IN (obo:VT_1000206, obo:CMO_0000445, obo:CMO_0000472, obo:CMO_0000473))
   FILTER((xsd:integer(?begin_pos) > xsd:integer(?begin_pos2) &&
           xsd:integer(?begin_pos) < xsd:integer(?end_pos2)) ||
          (xsd:integer(?end_pos) > xsd:integer(?begin_pos2) &&
           xsd:integer(?end_pos) < xsd:integer(?end_pos2)) ||
          (xsd:integer(?begin_pos) < xsd:integer(?begin_pos2) &&
          xsd:integer(?end_pos) > xsd:integer(?end_pos2)) ||
          xsd:integer(?begin_pos) > xsd:integer(?begin_pos2) &&
          xsd:integer(?end_pos) < xsd:integer(?end_pos2))
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX so: <http://purl.obolibrary.org/obo/so#>
--WITH  <$u{QTLDB_G_URI}>
--DELETE WHERE { ?s so:overlaps ?o } ;


--
-- Cross-link human protein-coding genes in OMIM and Ensembl.
--

SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
INSERT INTO <$u{ENSEMBL-HSA_G_URI}> {
   ?gene1 owl:sameAs ?gene2 ;
      obo:RO_0002331 ?omim
} WHERE {
   GRAPH <$u{BIO2RDF_G_URI}> {
      ?gene2 ^<http://bio2rdf.org/omim_vocabulary:x-ensembl> ?omim ;
         <http://bio2rdf.org/bio2rdf_vocabulary:identifier> ?gene_id .
      BIND(uri(concat('http://rdf.ebi.ac.uk/resource/ensembl/', ?gene_id)) AS ?gene1)
   }
   GRAPH <$u{ENSEMBL-HSA_G_URI}> {
      ?gene1 a obo:SO_0001217
   }
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX obo: <http://purl.obolibrary.org/obo/>
--PREFIX owl: <http://www.w3.org/2002/07/owl#>
--WITH  <$u{ENSEMBL-HSA_G_URI}>
--DELETE WHERE {
--   ?gene1 owl:sameAs ?gene2;
--      obo:RO_0002331 ?omim
--} ;

--
-- Append OMIM IDs to rdfs:label(s) for human genes where applicable (e.g. 'VSX2' -> 'VSX2 [omim:142993]').
--

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?gene rdfs:label ?lb }
INSERT { ?gene rdfs:label ?new }
WHERE {
   ?gene rdfs:label ?lb ;
      obo:RO_0002331 ?omim .
   BIND(concat(?lb, ' [', replace(str(?omim), '.+/', ''), ']') AS ?new)
} ;

--
-- Restore original rdfs:label(s) for genes.
--
--SPARQL
--PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
--PREFIX obo: <http://purl.obolibrary.org/obo/>
--WITH <$u{ENSEMBL-HSA_G_URI}>
--DELETE { ?gene rdfs:label ?lb }
--INSERT { ?gene rdfs:label ?new }
--WHERE {
--   ?gene rdfs:label ?lb ;
--      obo:RO_0002331 ?omim .
--   BIND(replace(?lb, ' \\[.+', '') as ?new)
--} ;
