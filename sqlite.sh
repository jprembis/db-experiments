#!/bin/sh

sqlite3 -header -column -nullvalue NULL -cmd '.read uni.sql'
