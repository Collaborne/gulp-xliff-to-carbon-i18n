<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 xliff-core-1.2-strict.xsd"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="1.0">

	<xsl:output method="text"/>

	<!--
	The name of the element that this XLIFF translates.
	  -->
	<xsl:param name="basename">element</xsl:param>

	<!--
	If `true`, then generate a JS file based on the source data.
	  -->
	<xsl:param name="use-source">false</xsl:param>

	<!--
	Path to the XLIFF 1.2 core schema.
	Optional, but may be required when the processor is unable to know its own path.
	  -->
	<xsl:param name="xliff-schema-uri" select="xliff-core-1.2-strict.xsd"/>
	<xsl:variable name="xliff-schema" select="document($xliff-schema-uri)"/>
	<xsl:variable name="default-xml-space" select="$xliff-schema//xs:element[@name='trans-unit']/xs:complexType/xs:attribute[@ref='xml:space']/@default"/>

	<xsl:template match="xliff:file">
		<xsl:apply-templates>
			<xsl:with-param name="source-language" select="@source-language"/>
			<xsl:with-param name="target-language" select="@target-language"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xliff:header[xliff:note]">
/** <xsl:value-of select="xliff:note"/> */
	</xsl:template>

	<xsl:template match="xliff:body">
		<xsl:param name="source-language"/>
		<xsl:param name="target-language"/>

		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$use-source='true'"><xsl:value-of select="$source-language"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$target-language"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

;(function() {
	'use strict';

	Polymer.CarbonI18nBehaviorLocales.add('<xsl:value-of select="$basename"/>', '<xsl:value-of select="$language"/>', {
		<!--
		xliff:group elements contain the xliff:trans-unit elements. We ignore the groups, they are there to help
		the translators.
		Similarly xliff:trans-unit elements have an id attribute which should be globally unique, but again is not relevant
		for us here.
		  -->
		<xsl:for-each select="*/xliff:trans-unit">
			<xsl:choose>
				<xsl:when test="@id=preceding-sibling::xliff:trans-unit/@id">
					<xsl:message>WARN: Duplicate id <xsl:value-of select="@id"/></xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="generate-code">
						<xsl:with-param name="source-language" select="$source-language"/>
						<xsl:with-param name="target-language" select="$target-language"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	});
})();
	</xsl:template>

	<xsl:template name="generate-code">
		<xsl:param name="source-language"/>
		<xsl:param name="target-language"/>

		<xsl:if test="xliff:note">
		/** <xsl:value-of select="xliff:note"/> */
		</xsl:if>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="$use-source='false' and xliff:target[@xml:lang=$target-language]">
					<xsl:value-of select="xliff:target[@xml:lang=$target-language]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$use-source='false'">
						<xsl:message>WARN: Missing translation for <xsl:value-of select="../@id"/>.<xsl:value-of select="@id"/></xsl:message>
					</xsl:if>
					<xsl:value-of select="xliff:source[@xml:lang=$source-language]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="xml-space">
			<xsl:choose>
				<xsl:when test="@xml:space"><xsl:value-of select="@xml:space"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$default-xml-space"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="stripped-value">
			<xsl:choose>
				<xsl:when test="$xml-space='preserve'"><xsl:value-of select="$value"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space($value)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Work around some quoting issues in XPath 1.0, see http://stackoverflow.com/a/12404176/196315 -->
		<xsl:variable name="apos">'</xsl:variable>
		<xsl:variable name="quote">
			<xsl:choose>
				<xsl:when test="contains($value, $apos)">"</xsl:when>
				<xsl:otherwise>'</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="@resname"/>: <xsl:value-of select="$quote"/><xsl:value-of select="$stripped-value"/><xsl:value-of select="$quote"/>,
	</xsl:template>
</xsl:stylesheet>
