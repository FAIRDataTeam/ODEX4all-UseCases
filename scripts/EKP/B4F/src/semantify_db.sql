--
-- Create RDF view over RDB using R2RML mapping language.
--
-- Author: Arnold Kuzniar
--

-- set local variables
SET u{graph_IRI} http://localhost:8890/B4F;
SET u{r2rml_graph_IRI} http://temp/B4F;
SET u{r2rml_file_path} /tmp/data/r2rml.ttl;
-- clear graphs
SPARQL CLEAR GRAPH <$u{r2rml_graph_IRI}>;
SPARQL DROP SILENT GRAPH <$u{graph_IRI}>;

-- store R2RML mappings in temp graph
DB.DBA.TTLP(file_to_string('$u{r2rml_file_path}'), '$u{graph_IRI}', '$u{r2rml_graph_IRI}');

-- sanity checks
--SELECT DB.DBA.R2RML_TEST('$u{r2rml_graph_IRI}');
--DB.DBA.OVL_VALIDATE('$u{r2rml_graph_IRI}', 'http://www.w3.org/ns/r2rml#OVL');

-- convert R2RML into Virtuoso's own Linked Data Views script
EXEC('SPARQL ' || DB.DBA.R2RML_MAKE_QM_FROM_G('$u{r2rml_graph_IRI}'));

-- TODO: materialize RDF/Linked Data view(s), http://docs.openlinksw.com/virtuoso/fn_rdf_view_sync_to_physical/
