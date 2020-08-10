#!/bin/sh

FILENAME=
URL=
DIRECT="phpfiles"
EXTEND=".php"

if which curl > /dev/null 2>&1  ;then
	while read FILENAME
	do
		URL=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $2}')
		FILENAME=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $1}')
		FILENAME=${FILENAME}${EXTEND}
		curl $URL > ${FILENAME}
		mv ${FILENAME} ${DIRECT}
	done < listIndustryURL.txt

elif which wget > /dev/null 2>&1 ;then
	while read FILENAME
	do
		URL=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $2}')
		FILENAME=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $1}')
		FILENAME=${FILENAME}${EXTEND}
		wget $URL > ${FILENAME}
		mv ${FILENAME} ${DIRECT}
	done < listIndustryURL.txt
fi

if [ ! -e table_stock_price.csv ] ;then
	touch table_stock_price.csv
	echo "code,market,Co.name,datetime,stock_price" >> table_stock_price.csv
fi

repeater.sh text2table.sh ${DIRECT} >> table_stock_price.csv
