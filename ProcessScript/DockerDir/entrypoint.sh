#!/usr/bin/env bash

if [ -z "$(ls -A $PGDATA)" ]; then
  #データベースクラスタの作成（ initdb ）
  initdb -E UTF8 --locale=C
  
  #PostgreSQL に接続するクライアントの認証に関する設定を記述
  #host       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
  echo 'host    all             all             0.0.0.0/0               trust' >> /var/lib/pgsql/12/data/pg_hba.conf ; \
  
  #PostgreSQL に関する基本的な設定を記述
  cat /var/lib/pgsql/12/data/postgresql.conf | sed -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" \
  | sed -e "s/#port = 5432/port = 5432/g" > /var/lib/pgsql/12/data/postgresql_temp.conf ; \
  #・listen_addresses パラメータは PostgreSQL に対するクライアントからの接続を許可するホストや IP アドレスを設定します
  #・現在は '*' が設定されており、すべてのクライアントからの接続を許可します

  #postgresql_temp.confをpostgresql.confに置き換えて、上記設定内容を反映する
  rm /var/lib/pgsql/12/data/postgresql.conf ; mv /var/lib/pgsql/12/data/postgresql_temp.conf /var/lib/pgsql/12/data/postgresql.conf

  # データを投入するためにサーバを起動（ pg_ctl -w start )　
  pg_ctl -w start 

  #/init/ にコピーしておいた setup.sql を実行（ psql -f ）
  psql -f /init/setup.sql 

  #サーバを停止（ pg_ctl -w stop ）
  pg_ctl -w stop 

fi

exec "$@"
