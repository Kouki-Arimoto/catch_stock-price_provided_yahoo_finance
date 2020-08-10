#!/bin/sh

awk 'BEGIN{ FS="," } {printf $1}' listIndustryURL.txt  > filenames
awk 'BEGIN{ FS="," } {printf $2}' listIndustryURL.txt  > fileURLs
 

