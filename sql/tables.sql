CREATE TABLE IF NOT EXISTS gene 
(
	gene_id INT PRIMARY KEY,
	locus VARCHAR(64),
	taxon_id INT
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS pubmed
(
	pmid int PRIMARY KEY,
	title varchar(512)
);

CREATE TABLE IF NOT EXISTS mesh
(
term varchar(256),
tree_num varchar(256),
PRIMARY KEY(term, tree_num)
);

CREATE TABLE IF NOT EXISTS generif
(
gene_id int,
pmid int,
heading varchar(30),
description varchar(512),
PRIMARY KEY (gene_id, pmid, heading),
FOREIGN KEY (gene_id) REFERENCES gene,
FOREIGN KEY (pmid) REFERENCES pubmed
);

CREATE TABLE IF NOT EXISTS pubmed_mesh
(
pmid int,
term varchar(256),
term_major varchar(1),
qual varchar(256),
qual_major varchar(1),
PRIMARY KEY (term, qual, pmid),
FOREIGN KEY (pmid) REFERENCES pubmed,
FOREIGN KEY (term) REFERENCES mesh,
INDEX(pmid)
);

CREATE TABLE IF NOT EXISTS related_articles
(
pmid int,
related_pmid int,
score int,
PRIMARY KEY (pmid, related_pmid)
);

CREATE TABLE IF NOT EXISTS gene_pubmed
(
	gene_id int,
	pmid int,
	degree int,
	PRIMARY KEY(gene_id, pmid),
	FOREIGN KEY (gene_id) REFERENCES gene
);

CREATE TABLE IF NOT EXISTS gene_go
(
	gene_id INT,
	go_id VARCHAR(64),
	PRIMARY KEY(gene_id, go_id),
	FOREIGN KEY (gene_id) REFERENCES gene
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS homologene
(
	homologene_id INT,
	gene_id INT,
	PRIMARY KEY(homologene_id, gene_id),
	FOREIGN KEY (gene_id) REFERENCES gene
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS gene_mim
(
	gene_id INT,
	mim_id INT,
	type VARCHAR(10),
	PRIMARY KEY(gene_id,mim_id),
	FOREIGN KEY (gene_id) REFERENCES gene
) TYPE=INNODB;


CREATE TABLE IF NOT EXISTS gene2pubmed
(
	gene_id INT,
	pmid INT,	
	PRIMARY KEY(gene_id,  pmid)
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS gene_mesh
(
	gene_id INT,
	term VARCHAR(256),	
	refs INT,
	PRIMARY KEY(gene_id,  term)
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS pubmed_mesh_parent
(
pmid int,
mesh_parent VARCHAR(256),	
PRIMARY KEY (pmid, mesh_parent),
FOREIGN KEY (pmid) REFERENCES pubmed,
INDEX (mesh_parent)
);

CREATE TABLE IF NOT EXISTS pubmed_chem
(
pmid int,
term VARCHAR(256),
PRIMARY KEY (pmid, term)
);

CREATE TABLE IF NOT EXISTS author_mesh20
(
author VARCHAR(256),
term VARCHAR(256),
PRIMARY KEY (author, term),
INDEX(term, author)
)
