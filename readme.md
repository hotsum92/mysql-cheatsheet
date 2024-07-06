
## SQL実践入門

[サポートページ：SQL実践入門 ──高速でわかりやすいクエリの書き方：｜技術評論社](https://gihyo.jp/book/2015/978-4-7741-7301-6/support)

##### サンプルコードのダウンロード

```
curl https://gihyo.jp/assets/files/book/2015/978-4-7741-7301-6/download/SQL_practical_guide_samplecode.zip -o SQL_practical_guide_samplecode.zip
```

## init database

```
docker volume create mysql-data
# run mysql
echo 'create database test' | ./db.sh
```
