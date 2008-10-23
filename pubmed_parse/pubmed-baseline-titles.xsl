<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "MedlineCitationSet"/>
<xsl:template match="MedlineCitation">
<xsl:text/><xsl:value-of select="normalize-space(PMID)"/>|<xsl:text/>
<xsl:value-of select="normalize-space(Article/ArticleTitle)"/>|<xsl:text/>
<xsl:value-of select="normalize-space(Article/Journal/Title)"/>|<xsl:text/>
<xsl:value-of select="normalize-space(Article/Journal/ISOAbbreviation)"/>|<xsl:text/>
<xsl:value-of select="normalize-space(Article/Journal/JournalIssue/PubDate/Year)"/>|<xsl:text/>
<xsl:value-of select="normalize-space(Article/Affiliation)"/><xsl:text/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:template> 
</xsl:stylesheet>
