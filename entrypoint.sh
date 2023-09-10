#!/bin/bash

# スクリプト内のコマンドがエラーで終了した場合にスクリプト全体もエラーで終了させるための設定
# set -e

# Railsアプリケーションの実行時に生成されるserver.pidファイルを削除
# 前回の実行中に異常終了した場合、pidが削除されていない可能性があるため
rm -f /myapp/tmp/pids/server.pid

# Nginxを起動
nginx

# Railsを起動
rails server # 開発環境
# rails s -e production # 本番環境

# bundle exec rails db:create
# bundle exec rails db:migrate
# bundle exec rails db:seed

# exec "$@"