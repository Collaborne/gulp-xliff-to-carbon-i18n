<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2 xliff-core-1.2-strict.xsd"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="xs exsl"
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

	<xsl:template name="escape-quotes">
		<xsl:param name="string"/>

		<xsl:call-template name="replace">
			<xsl:with-param name="string" select="$string"/>
			<xsl:with-param name="what">'</xsl:with-param>
			<xsl:with-param name="replacement">\'</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="replace">
		<xsl:param name="string"/>
		<xsl:param name="what"/>
		<xsl:param name="replacement"/>

		<xsl:choose>
			<xsl:when test="contains($string, $what)">
				<xsl:variable name="before" select="substring-before($string, $what)"/>
				<xsl:variable name="after">
					<xsl:call-template name="replace">
						<xsl:with-param name="string" select="substring-after($string, $what)"/>
						<xsl:with-param name="what" select="$what"/>
						<xsl:with-param name="replacement" select="$replacement"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($before, $replacement, $after)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Apply "strip white-space only text nodes" to a specific node -->
	<xsl:template name="strip-space">
		<xsl:param name="node"/>

		<xsl:for-each select="exsl:node-set($node)">
			<xsl:if test="not(self::text() and normalize-space(.) = '')">
				<xsl:copy>
					<xsl:for-each select="child::node()">
						<xsl:call-template name="strip-space">
							<xsl:with-param name="node" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:copy>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="generate-code">
		<xsl:param name="source-language"/>
		<xsl:param name="target-language"/>

		<xsl:variable name="xml-space">
			<xsl:choose>
				<xsl:when test="@xml:space"><xsl:value-of select="@xml:space"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$default-xml-space"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="xliff:note">
		/** <xsl:value-of select="xliff:note"/> */
		</xsl:if>
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="$use-source='false' and xliff:target[not(@xml:lang) or @xml:lang=$target-language]">
					<xsl:copy-of select="xliff:target[not(@xml:lang) or @xml:lang=$target-language]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$use-source='false'">
						<xsl:message>WARN: Missing translation for <xsl:value-of select="../@id"/>.<xsl:value-of select="@id"/></xsl:message>
					</xsl:if>
					<xsl:copy-of select="xliff:source[not(@xml:lang) or @xml:lang=$source-language]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="stripped-value">
			<xsl:choose>
				<xsl:when test="$xml-space='preserve'"><xsl:value-of select="$value"/></xsl:when>
				<xsl:otherwise><xsl:call-template name="strip-space">
					<xsl:with-param name="node" select="$value"/>
				</xsl:call-template></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="escaped-value">
			<xsl:call-template name="escape-quotes">
				<xsl:with-param name="string" select="$stripped-value"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="newlines-replaced-value">
			<xsl:call-template name="replace">
				<xsl:with-param name="string" select="$escaped-value"/>
				<xsl:with-param name="what" select="'&#xA;'"/>
				<xsl:with-param name="replacement">\n</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="@resname"/>: '<xsl:value-of select="$newlines-replaced-value"/>',
	</xsl:template>
</xsl:stylesheet>
