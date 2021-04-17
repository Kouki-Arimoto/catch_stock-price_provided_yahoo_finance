#!/bin/sh

#改行\nを代入する変数LFを定義する
LF=$(printf '\n_');LF=${LF%_}
DATE=`date "+%C%y/%m/%d"`
DELIM=','


#yahooファイナンス空運業の企業株価ページURL
if [ $# -eq 0 ]; then
	URL='https://stocks.finance.yahoo.co.jp/stocks/qi/?ids=5150&sort=m&order=1&p=1'
	echo 'DOWNLOAD URL=https://stocks.finance.yahoo.co.jp/stocks/qi/?ids=5150&sort=m&order=1&p=1'
elif [ $# -eq 1 ]; then
#	引数にURLを指定する際は、シングルクオーテーションでくくること→ command 'URL'
	URL="$1" 
else
	echo 'Usage: stock_price_air_transpotation.sh webURL'
	exit 1
fi


#URLページを書き込むファイル
DOC=`pwd`/stock_price_yahoo_finance.php

#フィルター処理して、整形した株価データを出力するファイル
DOCOUT=`pwd`/stock_price_air_transpotation.csv
SUBDOCOUT=`pwd`/stock_price_air_transpotation_sub.csv


#webページダウンロードする
if curl $URL > $DOC ;then
        :
elif wget $URL > $DOC ;then
        :
else
        echo 'command both "curl" and "wget" does not exist or network not connected!!'
        exit 1
fi

#download WEBページを表形式に整形する
awk '/<!-- LIST -->/, /<!-- \/LIST -->/ { print } ' $DOC \
        | awk '/<strong class=/ || /<div class="price/ { print } ' \
	| sed 's/,//g' \
        | sed 's%</a></td><td class="center yjSt">%'"${DELIM}"'%g' \
        | sed 's%</td><td><strong class="yjMt">%'"${DELIM}"'%g' \
        | sed 's%</div><div class="price yjM">%'"${DELIM}"'%g' \
        | sed 's/<[^>]*>//g' \
	| awk '{ LINE[NR]=$0; ENDR=NR }
		END {
			for(i=1; i<=ENDR/2; i=i+1 )
				print LINE[2*i-1],LINE[2*i]
		}' \
	| sed 's% %'"${DELIM},${DATE}"'/%g' > ${SUBDOCOUT}


#時刻区切り「:」があるかどうかチェックする（土日等は市場が停止し、時間：ではなく日付印字／されるため）あれば$?=0、なければ$?=1となる。
cat ${SUBDOCOUT} | grep  ":"  > /dev/null 2>&1 
if [ $? -eq 0 ]  ;then
	cat ${SUBDOCOUT} > ${DOCOUT}
else
	DATE=`date +"%Y/%m/%d %H:%M"`
	cat ${SUBDOCOUT} \
	| sed 's/'"${DELIM}"'/ /g' \
	| awk -v d=`date +"%Y/%m/%d/%H:%M"` ' $4!~/:/ { $4=d }  { print }' \
	| sed 's/ /'"${DELIM}"'/g' > ${DOCOUT}
fi

rm ${SUBDOCOUT}
