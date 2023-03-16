#!/bin/sh

pg_ctl start -l /dev/null
psql -P 'null=NULL' uni
