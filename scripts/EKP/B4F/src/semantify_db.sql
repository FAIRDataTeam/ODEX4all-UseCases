--
-- Create RDF view over RDB using R2RML mapping language.
--
-- Author: Arnold Kuzniar
--

-- grant select on db
GRANT SELECT ON B4F.odex4all.QTL TO SPARQL_SELECT;

-- clear graphs
SPARQL CLEAR GRAPH <http://temp/r2rml>;
SPARQL DROP SILENT GRAPH <http://localhost:8890/B4F>;

-- store R2RML mappings in temp graph
DB.DBA.TTLP(file_to_string('/tmp/data/r2rml.ttl'), 'http://temp/r2rml', 'http://temp/r2rml');

-- sanity checks
SELECT DB.DBA.R2RML_TEST('http://temp/r2rml');
DB.DBA.OVL_VALIDATE('http://temp/r2rml', 'http://www.w3.org/ns/r2rml#OVL');

-- convert R2RML into Virtuoso's own Linked Data Views script
EXEC('SPARQL ' || DB.DBA.R2RML_MAKE_QM_FROM_G('http://temp/r2rml'));
