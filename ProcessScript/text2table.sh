#!/bin/sh

#改行\nを代入する変数LFを定義する
LF=$(printf '\n_');LF=${LF%_}
DATE=`date "+%C%y/%m/%d"`
DELIM=','


#URLページを書き込むファイル
DOC=$1

#フィルター処理して、整形した株価データを出力するファイル
SUBDOCOUT=`pwd`/stock_price_air_transpotation_sub.csv

#download WEBページを表形式に整形する
# 入力ファイル「$DOC」の「 <!-- LIST -->/」から 「/<!-- \/LIST -->」の部分を抽出し、パイプで渡す
# sed 's/[パターン]/[置換値]/g'で[パターン]部を[置換値]に置き換えて、パイプで渡す
# パイプから渡されたデータについて、パターン「<strong class=/」または 「<div class="price」の行を書き出して、パイプで渡す
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
| sed 's% %'"${DELIM}${DATE}"'/%g' > ${SUBDOCOUT}


#時刻区切り「:」があるかどうかチェックする（土日等は市場が停止し、時間：ではなく日付印字／されるため）あれば$?=0、なければ$?=1となる。
cat ${SUBDOCOUT} | grep  ":"  > /dev/null 2>&1 
if [ $? -eq 0 ]  ;then
	cat ${SUBDOCOUT} 
else
	DATE=`date +"%Y/%m/%d %H:%M:%S"`
	cat ${SUBDOCOUT} \
	| sed 's/'"${DELIM}"'/ /g' \
	| awk -v d=`date +"%Y/%m/%d"`"¥t"`date +"%H:%M:%S"` ' $4!~/:/ { $4=d }  { print }' \
	| sed 's/ /'"${DELIM}"'/g' \
	| sed 's/¥t/ /g'
fi

rm ${SUBDOCOUT}
