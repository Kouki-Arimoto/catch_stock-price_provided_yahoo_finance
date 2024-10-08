#!/bin/sh

FILENAME=
URL=
DIRECT="../phpfiles"
EXTEND=".php"

if which curl > /dev/null 2>&1  ;then #PHPファイルのダウンロードコマンド「curl」が存在するかどうかチェックし、結果(true or false)を/dev/nullへ捨てる
# URL保存ファイル[listIndustryURL.txt]からURLを１行ずつ変数「FILENAME」へ読み込んで処理する
	while read FILENAME
	do
		URL=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $2}') 	#FILENAMEをawkコマンドへ渡す、区切り文字[,]としたときの2番目のカラムを変数「URL」へ渡す
		FILENAME=$(echo $FILENAME | awk 'BEGIN{FS=","} {printf $1}')	#FILENAMEをawkコマンドへ渡す、区切り文字[,]としたときの1番目のカラムを変数「FILENAME」へ渡す
		FILENAME=${FILENAME}${EXTEND}					#変数[EXTEND]を[FILENAME]の末尾に付与して、拡張子[.php]をつける
		curl $URL > ${FILENAME}						#curl URLでダウンロードしたphpファイルの内容を「FILENAME.php」ファイルに書き込む
		mv ${FILENAME} ${DIRECT}					#「FILENAME.php」ファイルを「phpfiles」フォルダに保存する
	done < listIndustryURL.txt

#[curl]コマンドがない場合、同じ機能の「wget」コマンドを使用して、上記[while]文以下の処理をおこなう。
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

#「table_stock_price.csv」が存在しない場合、作成しヘッダーとなるカラム名たちを書き込む
# if [ ! -e ./DataCSV/table_stock_price.csv ] ;then
	# touch ./DataCSV/table_stock_price.csv
if [ ! -e $(echo `pwd`)/../DataCSV/table_stock_price.csv ] ;then
	touch $(echo `pwd`)/../DataCSV/table_stock_price.csv
	echo "code,market,Co.name,datetime,stock_price" >> $(echo `pwd`)/../DataCSV/table_stock_price.csv
fi

#[phpfiles]フォルダへ格納したファイル群（上記の[FILENAME]たち）に対して、順番に「text2table.sh」処理を実行していく
repeater.sh text2table.sh ${DIRECT} > $(echo `pwd`)/../DataCSV/table_stock_price_by_process.csv
cat $(echo `pwd`)/../DataCSV/table_stock_price_by_process.csv \
>> $(echo `pwd`)/../DataCSV/table_stock_price.csv

#table_stock_price_by_process.csvのデータをデータベースに挿入する
psql -f insert_data.sql -h localhost -p 5432 -U postgres -d your_db
