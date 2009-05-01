CREATE TABLE IF NOT EXISTS pubmed
(
	pmid int PRIMARY KEY,
	title varchar(512),
	journaltitle varchar(256),
	journalisoabbrev varchar(256),
	pubyear int,
	affiliation varchar(512),
	INDEX (pubyear),
	INDEX (journaltitle)
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

CREATE TABLE IF NOT EXISTS pubmed_author
(
pmid int,
lastname VARCHAR(256),
forename VARCHAR(256),
initials VARCHAR(64),
lastauthorYN VARCHAR(1),
firstauthorYN VARCHAR(1),
PRIMARY KEY (pmid, lastname, forename, initials),
INDEX (pmid)
);
