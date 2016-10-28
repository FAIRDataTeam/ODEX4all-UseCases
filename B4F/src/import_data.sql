DELETE FROM QTL;
DELETE FROM ONTO;

.separator \t
.import ../data/QTL.tsv QTL
.import ../data/ONTO.tsv ONTO

DELETE FROM QTL WHERE qtl_id = 'qtl_id';
DELETE FROM ONTO WHERE id = 'id';
