<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 2, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nathan Gibson</xd:p>
            <xd:p>This stylesheet creates relation elements for person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template creates relation elements, by checking for and using content in any manually specified columns 
            that may contain relationship information.</xd:p>
        </xd:desc>
        <xd:param name="person-id">The @xml:id value of the person described in this document, whose relationship to another 
        entity is being described.</xd:param>
        <xd:param name="bib-ids">Used to cite from relationships with places.</xd:param>
    </xd:doc>
    <xsl:template name="relation" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="person-id"/>
        <xsl:param name="bib-ids"/>
        
        <!-- Should disambiguation be done as a relation or a note? -->
        <xsl:if test="string-length(normalize-space(Disambiguation)) or string-length(normalize-space(Disambiguation_URLs))">
            <relation type="disambiguation" name="different-from">
                <!-- If there are disambiguation URL's, writes machine-readable attributes for the relationship. -->
                <xsl:if test="string-length(normalize-space(Disambiguation_URLs))">
                    <xsl:attribute name="mutual" xml:space="preserve">#<xsl:value-of select="$person-id"/> <xsl:value-of select="Disambiguation_URLs"/></xsl:attribute>
                </xsl:if>
                <!-- If there is disambiguation text, writes human-readable description for the relationship. -->
                <xsl:if test="string-length(normalize-space(Disambiguation))">
                    <desc>
                        <xsl:value-of select="Disambiguation"/>
                    </desc>
                </xsl:if>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Shares_attribution_with))">
            <relation name="claims-attribution-to">
                <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                <xsl:attribute name="passive" xml:space="preserve" select="replace(Shares_attribution_with, '(^|\s)([0-9]+)', '$1http://syriaca.org/person/$2')"/>
                <desc>
                   This author composed works which he claimed were composed by an author described in another record.
                </desc>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Part_of_pseudonymous_author))">
            <relation name="is-part-of-pseudonymous-author">
                <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                <xsl:attribute name="passive" xml:space="preserve" select="replace(Part_of_pseudonymous_author, '(^|\s)([0-9]+)', '$1http://syriaca.org/person/$2')"/>
                <desc>
                    This author is one of the authors implied by the pseudonymous author described in another record.
                </desc>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Barsoum_en-Birthplace_URI))">
            <relation name="born-at">
                <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                <xsl:attribute name="passive" select="Barsoum_en-Birthplace_URI"/>
                <xsl:call-template name="source">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                    <xsl:with-param name="column-name" select="'Barsoum_en-Birthplace_URI'"/>
                </xsl:call-template>
                <desc xml:lang="en">This author was born at a known location.</desc>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Barsoum_en-Death_Place_URI))">
            <relation name="died-at">
                <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                <xsl:attribute name="passive" select="Barsoum_en-Death_Place_URI"/>
                <xsl:call-template name="source">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                    <xsl:with-param name="column-name" select="'Barsoum_en-Death_Place_URI'"/>
                </xsl:call-template>
                <desc xml:lang="en">This author died at a known location.</desc>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Barsoum_en-Literary_Place_URI))">
            <relation name="has-literary-connection-to-place">
                    <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                <xsl:attribute name="passive" select="Barsoum_en-Literary_Place_URI"/>
                    <xsl:call-template name="source">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column-name" select="'Barsoum_en-Literary_Place_URI'"/>
                    </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains(Barsoum_en-Literary_Place_URI,' ')">
                        <desc xml:lang="en">This author has a literary connection to places.</desc>
                    </xsl:when>
                    <xsl:otherwise>
                        <desc xml:lang="en">This author has a literary connection to a place.</desc>
                    </xsl:otherwise>
                </xsl:choose>
            </relation>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(Barsoum_en-Other_Place_URI))">
                    <relation name="has-relation-to-place">
                        <xsl:attribute name="active">#<xsl:value-of select="$person-id"/></xsl:attribute>
                        <xsl:attribute name="passive" select="Barsoum_en-Other_Place_URI"/>
                        <xsl:call-template name="source">
                            <xsl:with-param name="bib-ids" select="$bib-ids"/>
                            <xsl:with-param name="column-name" select="'Barsoum_en-Other_Place_URI'"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="contains(Barsoum_en-Other_Place_URI,' ')">
                                <desc xml:lang="en">This author has an unspecified connection to places.</desc>
                            </xsl:when>
                            <xsl:otherwise>
                                <desc xml:lang="en">This author has an unspecified connection to a place.</desc>
                            </xsl:otherwise>
                        </xsl:choose>
                    </relation>
        </xsl:if>
        
        <!-- Add code here for any additional columns that should produce relation elements. -->
    </xsl:template>
</xsl:stylesheet>