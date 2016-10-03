# Author: Wytze

import xml.etree.ElementTree as etree
import sqlite3

class DatabaseMapper:
    # Ingest the Research Domain / Research Target mapping table
    # Class enables easy mapping between the identifiers and the free text names
    def __init__(self, file_location):
        self.file = file_location
        self.db = sqlite3.connect(':memory:').cursor()
        self.createDB()
        self.dabaseList = self.createDatabaseList()

    def createDB(self):
        self.db.execute(
          '''CREATE TABLE MAPPING (
            RD INTEGER,
            RT INTEGER,
            NAME TEXT,
            PUBLICATIONTYPE TEXT)'''
          )
        xml = etree.parse(self.file).getroot()
        for x in xml:
            self.db.execute('''INSERT INTO MAPPING(RD, RT, NAME, PUBLICATIONTYPE) VALUES(?, ?, ?, ?)''',
            (int(x.findtext('rd')), int(x.findtext('rt')), x.findtext('name'), x.findtext('publicationtype')))

    def executeQuery(self, SQLiteQuery):
        self.db.execute(SQLiteQuery)
        return self.db.fetchall()

    def createDatabaseList(self):
        databases = []
        self.db.execute("SELECT DISTINCT NAME FROM MAPPING")
        db_list = self.db.fetchall()
        for d in db_list:
            databases.append(d[0])
        return databases

    def MapDBtoRDRT(self, DB_name):
        self.db.execute("SELECT DISTINCT RD AND RT FROM MAPPING WHERE NAME ==?", (DB_name))
        return self.db.fetchall()[0][0]

    def MapRDRTtoName(self, RD, RT):
        self.db.execute("SELECT DISTINCT NAME FROM MAPPING WHERE RD == ? AND RT == ?", (RD, RT))
        return self.db.fetchall()[0][0]
