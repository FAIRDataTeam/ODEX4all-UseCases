#!/bin/bash

DB=pigQTL.db

rm -f ${DB}
sqlite3 ${DB} < create_db.sql
sqlite3 ${DB} < import_data.sql
