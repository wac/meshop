<?xml version="1.0"?>
<xsl:stylesheet version = "1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:strip-space elements = "SupplementalRecordSet"/>
<xsl:template match="SupplementalRecord">
<xsl:variable name="descui" select="normalize-space(SupplementalRecordUI)"/>
<xsl:variable name="term" select="SupplementalRecordName/String"/>
<xsl:for-each select="PharmacologicalActionList/PharmacologicalAction/DescriptorReferredTo/DescriptorName">
<xsl:value-of select="$descui"/>|<xsl:text/>
<xsl:value-of select="$term"/>|<xsl:text/>
<xsl:value-of select="String"/><xsl:text/>
<xsl:text disable-output-escaping = "yes" >
</xsl:text>
</xsl:for-each>
</xsl:template> 
</xsl:stylesheet>
