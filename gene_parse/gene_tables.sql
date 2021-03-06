CREATE TABLE IF NOT EXISTS gene 
(
	gene_id INT PRIMARY KEY,
	locus VARCHAR(64),
	taxon_id INT,
	chr VARCHAR(3)
) TYPE=INNODB;

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

CREATE TABLE IF NOT EXISTS gene2pubmed
(
	gene_id INT,
	pmid INT,	
	PRIMARY KEY(gene_id,  pmid)
) TYPE=INNODB;

CREATE TABLE IF NOT EXISTS gene2refseq
(
	gene_id INT,
	gi VARCHAR(128),
	gi_startpos INT,
	gi_endpos INT,
	PRIMARY KEY(gene_id, gi)
) TYPE=INNODB;

