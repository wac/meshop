<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "MedlineCitationSet"/>
<xsl:template match="MedlineCitation">
<xsl:variable name="pmid" select="normalize-space(PMID)"/>
<xsl:for-each select="Article/AuthorList/Author">
<xsl:value-of select="$pmid"/>|<xsl:text/>
<xsl:value-of select="LastName"/>|<xsl:text/>
<xsl:value-of select="ForeName"/>|<xsl:text/>
<xsl:value-of select="Initials"/><xsl:text/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:for-each>
</xsl:template> 
</xsl:stylesheet>
