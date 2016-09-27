SET u{path} /usr/local/virtuoso-opensource/share/virtuoso/vad/;
VAD_INSTALL('$u{path}/rdb2rdf_dav.vad', 0);
VAD_INSTALL('$u{path}/rdf_mappers_dav.vad', 0);
VAD_INSTALL('$u{path}/fct_dav.vad', 0);
QUIT;
