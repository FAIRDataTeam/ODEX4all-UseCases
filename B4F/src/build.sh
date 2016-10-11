#!/bin/bash

PORT=1111
USER=dba
PASS=dba
LOG_FILE=pigQTLdb.log
SQL_FILES=(install_vad_pkgs.sql create_db.sql QTL.sql ONTO.sql update_db.sql semantify_db.sql)

rm -f $LOG_FILE
for fname in ${SQL_FILES[@]}
do
    echo "### START [$(date)]: 'isql ... $fname'" >> $LOG_FILE
    isql $PORT $USER $PASS verbose=off errors=stderr $fname &>> $LOG_FILE
    echo "### END [$(date)]" >> $LOG_FILE
done
