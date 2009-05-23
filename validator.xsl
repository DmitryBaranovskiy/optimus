<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes" doctype-system="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-public="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <title>Optimus · microformats transformer</title>
                <meta name="author" content="Dmitry Baranovskiy" />
                <meta name="description" content="Optimus, the&#160;microformats transformer. Easily transform your microformatted content to nice, clean, easily digestible, XML, JSON or JSON-P. You can also easily set ﬁlters to only receive particular formats." />
                <link rel="stylesheet" href="optimus.css" type="text/css" title="Optimus" charset="utf-8" />
                <link rel="stylesheet" href="twilight.css" type="text/css" charset="utf-8" />
            </head>

            <body class="optimus validator" id="validator.microformatique.com">
                <h1><span>Optimus · microformats transformer</span></h1>
                <h2>Results for ‘<xsl:value-of select="/microformats/@from"/>’</h2>
                <p class="summary">
                    <xsl:choose>
                        <xsl:when test="count(.//error) > 0 or count(.//*[@date][not(@valid)])">
                            <span class="error">Microformats at this page have some errors. Scroll down for more details.</span>
                        </xsl:when>
                        <xsl:when test="count(.//@warning) > 0">
                            <span class="warning">Microformats at this page have some warnings. Scroll down for more details.</span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Microformats at this page have no errors. Congratulations.</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </p>
                <div id="content">
                    <xsl:apply-templates select="/microformats/*" mode="enter"/>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="*" mode="enter">
        <xsl:choose>
            <xsl:when test="name() = 'hatom'">
                <xsl:apply-templates select="hentry" mode="enter"/>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:variable name="class">
                        <xsl:choose>
                            <xsl:when test="count(.//error) > 0 or count(.//*[@date][not(@valid)])">
                                <xsl:text> error </xsl:text>
                            </xsl:when>
                            <xsl:when test="count(.//@warning) > 0">
                                <xsl:text> warning </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> clean </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
                    <h2>
                        <xsl:value-of select="name(.)"/>
                    </h2>
                    <div class="message">
                        <xsl:for-each select=".//error|.//@warning">
                            <p><xsl:value-of select="concat(., @message)"/></p>
                        </xsl:for-each>
                        <xsl:for-each select=".//*[@date][not(@valid)]">
                            <p>
                                The date ‘<xsl:value-of select="@date"/>’ is not valid ISO8601 date.
                            </p>
                        </xsl:for-each>
                        &#160;
                    </div>
                    <dl>
                        <xsl:apply-templates select="./*" mode="dl" />
                    </dl>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[name() != 'error']" mode="dl">
        <dt><xsl:value-of select="name(.)"/></dt>
        <dd>
            <xsl:choose>
                <xsl:when test="count(./*) > 0">
                    <dl>
                        <xsl:apply-templates select="./*" mode="dl" />
                    </dl>
                </xsl:when>
                <xsl:when test="@href">
                    <a href="{@href}"><xsl:value-of select="."/></a>
                </xsl:when>
                <xsl:when test="@date">
                    <abbr title="{@date}"><xsl:value-of select="."/></abbr>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </dd>
    </xsl:template>
</xsl:stylesheet>
