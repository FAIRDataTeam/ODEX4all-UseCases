--
-- Create RDF view over RDB using R2RML mapping language.
--
-- Author: Arnold Kuzniar
--

-- set local variables
SET u{GRAPH_IRI} http://localhost:8890/B4F;
SET u{R2RML_GRAPH_IRI} http://temp/B4F;
SET u{R2RML_FILE} /tmp/share/r2rml.ttl;

-- clear graphs
SPARQL CLEAR GRAPH <$u{R2RML_GRAPH_IRI}>;
SPARQL DROP SILENT GRAPH <$u{GRAPH_IRI}>;

-- store R2RML mappings in temp graph
DB.DBA.TTLP(file_to_string('$u{R2RML_FILE}'), '$u{GRAPH_IRI}', '$u{R2RML_GRAPH_IRI}');

-- sanity checks
--SELECT DB.DBA.R2RML_TEST('$u{R2RML_GRAPH_IRI}');
--DB.DBA.OVL_VALIDATE('$u{R2RML_GRAPH_IRI}', 'http://www.w3.org/ns/r2rml#OVL');

-- convert R2RML into Virtuoso's own Linked Data Views script
EXEC('SPARQL ' || DB.DBA.R2RML_MAKE_QM_FROM_G('$u{R2RML_GRAPH_IRI}'));

-- TODO:
-- set R2RML_FILE variable dynamically using to docker command-line arg
-- materialize RDF/Linked Data view(s), http://docs.openlinksw.com/virtuoso/fn_rdf_view_sync_to_physical/
