set u{path} /usr/local/virtuoso-opensource/share/virtuoso/vad/;
vad_install('$u{path}/rdb2rdf_dav.vad', 0);
vad_install('$u{path}/rdf_mappers_dav.vad', 0);
vad_install('$u{path}/fct_dav.vad', 0);
quit;
