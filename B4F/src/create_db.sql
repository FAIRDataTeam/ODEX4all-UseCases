--
-- Create SQLite db schema for pigQTLdb data.
--
-- Author: Arnold Kuzniar
--

-- create tables
DROP TABLE IF EXISTS QTL;
CREATE TABLE QTL (
   qtl_id NUMERIC NOT NULL,
   chromosome TEXT,
   start NUMERIC,
   end NUMERIC,
   dominance_effect NUMERIC,
   additive_effect NUMERIC,
   bayes_value NUMERIC,
   likelihood_ratio NUMERIC,
   p_value NUMERIC,
   variance NUMERIC,
   f_stat NUMERIC,
   lod_score NUMERIC,
   cmo_name	TEXT,
   vt_name TEXT,
   lpt_name TEXT,
   qtl_class TEXT,
   map_type TEXT,
   model TEXT,
   markers TEXT,
   breed TEXT,
   pmid NUMERIC,
   PRIMARY KEY(qtl_id)
);
CREATE INDEX idx_QTL_chromosome ON QTL(chromosome);
CREATE INDEX idx_QTL_region ON QTL(start,end);
CREATE INDEX idx_QTL_cmo_name ON QTL(cmo_name);
CREATE INDEX idx_QTL_vt_name ON QTL(vt_name);
CREATE INDEX idx_QTL_lpt_name ON QTL(lpt_name);
CREATE INDEX idx_QTL_pmid ON QTL(pmid);


DROP TABLE IF EXISTS QNTO;
CREATE TABLE ONTO (
   id TEXT,
   name TEXT,
   PRIMARY KEY(id)
);
CREATE INDEX idx_ONTO_name ON ONTO(name);


-- create views
DROP VIEW IF EXISTS V_QTL;
CREATE VIEW V_QTL AS
SELECT
   qtl_id,
   chromosome,
   start,
   end,
   dominance_effect,
   additive_effect,
   bayes_value,
   likelihood_ratio,
   p_value,
   variance,
   f_stat,
   lod_score,
   cmo_name,
   (SELECT id FROM ONTO WHERE INSTR(id, 'CMO:') > 0 AND ONTO.name = QTL.cmo_name) AS cmo_id,
   vt_name,
   (SELECT id FROM ONTO WHERE INSTR(id, 'VT:') > 0 AND ONTO.name = QTL.vt_name) AS vt_id,
   lpt_name,
   (SELECT id FROM ONTO WHERE INSTR(id, 'LPT:') > 0 AND ONTO.name = QTL.lpt_name) AS lpt_id,
   qtl_class,
   map_type,
   model,
   markers,
   breed,
   pmid
FROM QTL;
