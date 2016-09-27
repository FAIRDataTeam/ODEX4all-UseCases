USER_CREATE('odex4all', 'odex4all');

CREATE TABLE "B4F"."odex4all"."QTL" (
   "chromosome"		VARCHAR,
   "source"		VARCHAR,
   "feature_type"	VARCHAR,
   "start_pos"		INTEGER,
   "end_pos"		INTEGER,
   "additive_effect"	FLOAT,
   "dominance_effect"	FLOAT,
   "bayes_value"	FLOAT,
   "likelihood_ratio"	FLOAT,
   "p_value"		FLOAT,
   "variance"		FLOAT,
   "f_stat"		FLOAT,
   "lod_score"		FLOAT,
   "cmo_name"		VARCHAR,
   "cmo_md5"		VARCHAR,
   "cmo_id"		VARCHAR,
   "vt_name"		VARCHAR,
   "vt_md5"		VARCHAR,
   "vt_id"		VARCHAR,
   "lpt_name"		VARCHAR,
   "lpt_md5"		VARCHAR,
   "lpt_id"		VARCHAR,
   "map_type"		VARCHAR,
   "model"		VARCHAR,
   "flanking_markers"	VARCHAR,
   "breed"		VARCHAR,
   "pmid"		INTEGER,
   "qtl_id"		INTEGER NOT NULL,
   PRIMARY KEY ("qtl_id")
);
CREATE INDEX idx_QTL_chromosome ON B4F.odex4all.QTL("chromosome");
CREATE INDEX idx_QTL_region ON B4F.odex4all.QTL("start_pos","end_pos");
CREATE INDEX idx_QTL_pmid ON B4F.odex4all.QTL("pmid");
CREATE INDEX idx_QTL_cmo_md5 ON B4F.odex4all.QTL("cmo_md5");
CREATE INDEX idx_QTL_vt_md5 ON B4F.odex4all.QTL("vt_md5");
CREATE INDEX idx_QTL_lpt_md5 ON B4F.odex4all.QTL("lpt_md5");


CREATE TABLE "B4F"."odex4all"."ONTO" (
   "id"		VARCHAR,
   "name"	VARCHAR,
   "name_md5"	VARCHAR,
   PRIMARY KEY ("id")
);
CREATE INDEX idx_ONTO_name_md5 ON B4F.odex4all.ONTO("name_md5");
