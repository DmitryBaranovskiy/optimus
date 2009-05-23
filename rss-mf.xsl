<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" />
    <xsl:template match="/">
        <rss version="2.0">
            <channel>
                <title><xsl:value-of select="/microformats/@title"/></title>
                <description><xsl:value-of select="/microformats/description"/></description>
                <link><xsl:value-of select="/microformats/@from"/></link>
                <generator>Optimus</generator>

                <xsl:for-each select="/microformats//hentry">
                    <item>
                        <xsl:for-each select="author">
                            <author>
                                <xsl:choose>
                                    <xsl:when test="email">
                                        <xsl:value-of select="email"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>author@example.com</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="concat(' (', fn, ')')"/>
                            </author>
                        </xsl:for-each>
                        <xsl:for-each select="tag">
                            <category domain="{@href}"><xsl:value-of select="."/></category>
                        </xsl:for-each>
                        <title><xsl:value-of select="entry-title"/></title>
                        <link><xsl:value-of select="bookmark/@href"/></link>
                        <description>
                            <xsl:choose>
                                <xsl:when test="entry-content">
                                    <xsl:value-of select="entry-content"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="entry-summary"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </description>
                        <pubDate><xsl:value-of select="published/@date"/></pubDate>
                        <guid isPermaLink="false">
                            <xsl:value-of select="bookmark/@href"/>
                            <xsl:value-of select="published/@date"/>
                            <xsl:value-of select="translate(entry-title, ' ', '-')"/>
                        </guid>
                    </item>
                </xsl:for-each>
            </channel>
        </rss>
    </xsl:template>
</xsl:stylesheet>
