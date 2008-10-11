CREATE TABLE IF NOT EXISTS mesh_tree
(
term varchar(256),
tree_num varchar(256),
PRIMARY KEY(term, tree_num)
);

CREATE TABLE IF NOT EXISTS mesh
(
term varchar(256),
mesh_ui varchar(256),
PRIMARY KEY(term, mesh_ui)
);

