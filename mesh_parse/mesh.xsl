<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "DescriptorRecordSet"/>
<xsl:template match="DescriptorRecord">
<xsl:variable name="dui" select="normalize-space(DescriptorUI)"/>
<xsl:variable name="dname" select="DescriptorName/String"/>
<xsl:for-each select="TreeNumberList/TreeNumber">
<xsl:value-of select="$dui"/>|<xsl:text/>
<xsl:value-of select="$dname"/>|<xsl:text/>
<xsl:value-of select="."/><xsl:text/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:for-each>
</xsl:template> 
</xsl:stylesheet>
