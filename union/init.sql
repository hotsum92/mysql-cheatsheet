DROP DATABASE IF EXISTS mydb;

CREATE DATABASE mydb;

USE mydb;

CREATE TABLE Items
(   item_id     INTEGER  NOT NULL, 
       year     INTEGER  NOT NULL, 
  item_name     CHAR(32) NOT NULL, 
  price_tax_ex  INTEGER  NOT NULL, 
  price_tax_in  INTEGER  NOT NULL, 
  PRIMARY KEY (item_id, year));

INSERT INTO Items VALUES(100,	2000,	'カップ'	,500,	525);
INSERT INTO Items VALUES(100,	2001,	'カップ'	,520,	546);
INSERT INTO Items VALUES(100,	2002,	'カップ'	,600,	630);
INSERT INTO Items VALUES(100,	2003,	'カップ'	,600,	630);
INSERT INTO Items VALUES(101,	2000,	'スプーン'	,500,	525);
INSERT INTO Items VALUES(101,	2001,	'スプーン'	,500,	525);
INSERT INTO Items VALUES(101,	2002,	'スプーン'	,500,	525);
INSERT INTO Items VALUES(101,	2003,	'スプーン'	,500,	525);
INSERT INTO Items VALUES(102,	2000,	'ナイフ'	,600,	630);
INSERT INTO Items VALUES(102,	2001,	'ナイフ'	,550,	577);
INSERT INTO Items VALUES(102,	2002,	'ナイフ'	,550,	577);
INSERT INTO Items VALUES(102,	2003,	'ナイフ'	,400,	420);

CREATE TABLE Population
(prefecture VARCHAR(32),
 sex        CHAR(1),
 pop        INTEGER,
     CONSTRAINT pk_pop PRIMARY KEY(prefecture, sex));

INSERT INTO Population VALUES('徳島', '1', 60);
INSERT INTO Population VALUES('徳島', '2', 40);
INSERT INTO Population VALUES('香川', '1', 90);
INSERT INTO Population VALUES('香川', '2',100);
INSERT INTO Population VALUES('愛媛', '1',100);
INSERT INTO Population VALUES('愛媛', '2', 50);
INSERT INTO Population VALUES('高知', '1',100);
INSERT INTO Population VALUES('高知', '2',100);
INSERT INTO Population VALUES('福岡', '1', 20);
INSERT INTO Population VALUES('福岡', '2',200);
