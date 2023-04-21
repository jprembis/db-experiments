#!/bin/sh

sqlite3 -header -column -nullvalue NULL \
        -cmd '.read uni-schema.sql' \
        -cmd '.read ../uni-inserts.sql'
