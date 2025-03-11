#!/bin/bash

/Applications/Postgres.app/Contents/Versions/17/bin/pg_dump -Fp -s -U braibau -Z none -h localhost -p 5432 -d ev-pulse -f schema-test.sql 
