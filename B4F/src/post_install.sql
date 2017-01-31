--
-- Post-installation script for Virtuoso Faceted Browser
--

-- build full-text indices
DB.DBA.RDF_OBJ_FT_RULE_ADD (null, null, 'All') ;
DB.DBA.VT_INC_INDEX_DB_DBA_RDF_OBJ() ;

-- periodically populate label lookup tables
urilbl_ac_init_db() ;

-- re-rank the IRIs (should be done periodically)
s_rank() ;

-- grant permissions
GRANT SPARQL_UPDATE TO "SPARQL" ;
GRANT EXECUTE ON "DB.DBA.rdfdesc_http_url" TO "SPARQL" ;
