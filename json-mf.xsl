<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="no" method="text" omit-xml-declaration="yes" />
    <xsl:variable name="xml" select="document('mf.xml')"/>
    <xsl:variable name="root" select="/"/>


    <xsl:template match="/">
        <xsl:text>{"from": "</xsl:text>
        <xsl:value-of select="/microformats/@from"/>
        <xsl:text>", "title": "</xsl:text>
        <xsl:value-of select="/microformats/@title"/>
        <xsl:text>"</xsl:text>
            <xsl:for-each select="$xml/microformats/*">
                <xsl:variable name="node" select="."/>
                <xsl:for-each select="$root/microformats/*[name() = name(current()) or name() = current()/@name]">
                    <xsl:if test="position() = 1 and string-length(.) > 0">
                        <xsl:value-of select="concat(', &quot;', name(), '&quot;: ')"/>
                        <xsl:choose>
                            <xsl:when test="count($root/microformats/*[name() = name(current())]) > 1">
                            <!-- <xsl:when test="$node/@many = 'many'"> -->
                                <xsl:text>[</xsl:text>
                                <xsl:for-each select="$root/microformats/*[name() = name(current())]">
                                    <xsl:apply-templates select=".">
                                        <xsl:with-param name="name" select="name()" />
                                        <xsl:with-param name="array" select="true()" />
                                    </xsl:apply-templates>
                                    <xsl:if test="position() != last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>]</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="name" select="name()" />
                                    <xsl:with-param name="array" select="true()" />
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="node()">
        <xsl:param name="name"/>
        <xsl:param name="array" select="false()"/>
        <xsl:variable name="ele" select="."/>
        <xsl:if test="not($array)">
            <xsl:value-of select="concat('&quot;', $name, '&quot;: ')"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="* and count($xml//*[name() = $name or @name = $name or name() = $ele/@type or @name = $ele/@type]/*) > 0">
                <xsl:text>{</xsl:text>
                <xsl:variable name="cur" select="."/>
                <xsl:for-each select="$xml//*[name() = $name or @name = $name or name() = $ele/@type or @name = $ele/@type]/*">
                    <xsl:variable name="node" select="."/>
                    <xsl:for-each select="$cur/*[name() = name(current()) or name() = current()/@name]">
                        <xsl:if test="position() = 1 and (string-length(.) > 0 or @*)">
                            <xsl:if test="preceding-sibling::*">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$node/@many = 'many'">
                                    <xsl:value-of select="concat('&quot;', name(), '&quot;: [')"/>
                                    <xsl:for-each select="$cur/*[name() = name(current())]">
                                        <xsl:apply-templates select=".">
                                            <xsl:with-param name="name" select="name()" />
                                            <xsl:with-param name="array" select="true()" />
                                        </xsl:apply-templates>
                                        <xsl:if test="position() != last()">
                                            <xsl:text>, </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select=".">
                                        <xsl:with-param name="name" select="name()" />
                                        <xsl:with-param name="array" select="false()" />
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="* and count($xml//*[name() = $name or @name = $name or name() = $ele/@type or @name = $ele/@type]/*) = 0">
                <xsl:text>{</xsl:text>
                <xsl:for-each select="*">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="name" select="name()" />
                        <xsl:with-param name="array" select="false()" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="@date">
                <xsl:value-of select="concat('&quot;', @date, '&quot;')"/>
            </xsl:when>
            <xsl:when test="@href and string-length(.) > 0">
                <xsl:text>{"href": "</xsl:text>
                <xsl:value-of select="@href"/>
                <xsl:text>", "value": "</xsl:text>
                <xsl:call-template name="escape">
                    <xsl:with-param name="text" select="." />
                </xsl:call-template>
                <xsl:text>"}</xsl:text>
            </xsl:when>
            <xsl:when test="@href">
                <xsl:value-of select="concat('&quot;', @href, '&quot;')"/>
            </xsl:when>
            <xsl:when test="string-length(.) > 0">
                <xsl:text>"</xsl:text>
                <xsl:call-template name="escape">
                    <xsl:with-param name="text" select="." />
                </xsl:call-template>
                <xsl:text>"</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="escape">
        <xsl:param name="text" select="''"/>
        <xsl:choose>
            <xsl:when test="contains($text, '&quot;') or contains($text, '\')">
                <xsl:choose>
                    <xsl:when test="string-length(substring-before($text, '&quot;')) > string-length(substring-before($text, '\')) and string-length(substring-before($text, '\')) != 0">
                        <xsl:value-of select="substring-before($text, '\')"/>
                        <xsl:text>\\</xsl:text>
                        <xsl:call-template name="escape">
                            <xsl:with-param name="text" select="substring-after($text, '\')" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before($text, '&quot;')"/>
                        <xsl:text>\"</xsl:text>
                        <xsl:call-template name="escape">
                            <xsl:with-param name="text" select="substring-after($text, '&quot;')" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>