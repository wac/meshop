<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "MedlineCitationSet"/>
<xsl:template match="MedlineCitation">
<xsl:variable name="pmid" select="normalize-space(PMID)"/>
<xsl:for-each select="MeshHeadingList/MeshHeading">
<xsl:value-of select="$pmid"/>|<xsl:text/>
<xsl:value-of select="DescriptorName"/>|<xsl:text/>
<xsl:value-of select="DescriptorName/@MajorTopicYN"/>|<xsl:text/>
<xsl:value-of select="QualifierName"/>|<xsl:text/>
<xsl:value-of select="QualifierName/@MajorTopicYN"/>|<xsl:text/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:for-each>
</xsl:template> 
</xsl:stylesheet>
