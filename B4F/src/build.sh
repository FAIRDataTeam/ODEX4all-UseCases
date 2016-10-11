#!/bin/bash

PORT=1111
USER=dba
PASS=dba
LOG_FILE=err.log
SQL_FILES=(install_vad_pkgs.sql create_db.sql QTL.sql ONTO.sql update_db.sql semantify_db.sql)

rm -f $LOG_FILE
for fname in ${SQL_FILES[@]}
do
    echo "### $(date): isql ... $fname\n" &>> $LOG_FILE
    isql $PORT $USER $PASS verbose=off errors=stderr $fname &>> $LOG_FILE
done
