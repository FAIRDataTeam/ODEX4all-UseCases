UPDATE B4F.odex4all.QTL SET cmo_md5 = substring(md5(cmo_name), 1, 7) WHERE cmo_name IS NOT NULL;
UPDATE B4F.odex4all.QTL SET vt_md5 = substring(md5(vt_name), 1, 7) WHERE vt_name IS NOT NULL;
UPDATE B4F.odex4all.QTL SET lpt_md5 = substring(md5(lpt_name), 1, 7) WHERE lpt_name IS NOT NULL;
UPDATE B4F.odex4all.ONTO SET name_md5 = substring(md5(name), 1, 7) WHERE name IS NOT NULL;
UPDATE B4F.odex4all.QTL A SET vt_id = (SELECT id FROM B4F.odex4all.ONTO B WHERE B.name_md5 = A.vt_md5);
UPDATE B4F.odex4all.QTL A SET lpt_id = (SELECT id FROM B4F.odex4all.ONTO B WHERE B.name_md5 = A.lpt_md5);
UPDATE B4F.odex4all.QTL A SET cmo_id = (SELECT id FROM B4F.odex4all.ONTO B WHERE B.name_md5 = A.cmo_md5);
