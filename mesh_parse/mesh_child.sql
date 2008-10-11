DROP TABLE IF EXISTS mesh_child;
CREATE TABLE mesh_child AS 
SELECT DISTINCT major.term, child.term AS child 
FROM mesh_tree AS major, mesh_tree AS child 
WHERE major.tree_num=child.tree_num OR child.tree_num LIKE CONCAT(major.tree_num,'.%');
ALTER TABLE mesh_child ADD PRIMARY KEY(term, child);
ALTER TABLE mesh_child ADD INDEX(child);
