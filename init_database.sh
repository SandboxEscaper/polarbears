#!/bin/bash

if [ -f database/bear-collector.db ]; then
	echo "Database already exists at database/bear-collector.db, exiting"
	exit 1;
else
	cat schema.sql | sqlite3 database/bear-collector.db
fi