<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "DescriptorRecordSet"/>
<xsl:template match="DescriptorRecord">
<xsl:value-of select="normalize-space(DescriptorUI)"/>|<xsl:text/>
<xsl:value-of select="DescriptorName/String"/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:template> 
</xsl:stylesheet>
