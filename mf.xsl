<!--
    Optimus 0.8 - Microformats Transformer

    Copyright (c) 2007 - 2009 Dmitry Baranovskiy (http://microfomatique.com/optimus/)
    Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes" omit-xml-declaration="no" method="xml" encoding="UTF-8" media-type="text/xml"/>
    <xsl:param name="filter" select="'vevent vcard hentry hresume hreview hlisting xfolkentry adr geo xfn votelinks rel-nofollow rel-tag rel-license'"/>
    <xsl:param name="url" select="''"/>
    <xsl:param name="debug" select="0"/>
    <xsl:variable name="anchor" select="substring-after($url, '#')"/>
    <xsl:variable name="all" select="//*[@id = $anchor or string-length($anchor) = 0][not(ancestor-or-self::*[name() = 'del'])]|//*[@id = $anchor or string-length($anchor) = 0]//*[not(ancestor-or-self::*[name() = 'del'])]"/>
    <xsl:variable name="top" select="//*[not(ancestor-or-self::*[name() = 'del'])]"/>
    <xsl:variable name="xml" select="document('mf.xml')"/>
    <xsl:variable name="thefilter">
        <xsl:value-of select="$filter"/>
        <xsl:if test="contains(concat(' ', $filter, ' '), ' hfeed ') and not($all/*[contains(concat(' ', @class, ' '), ' hfeed ')])">
            <xsl:text> hentry</xsl:text>
        </xsl:if>
        <xsl:if test="contains(concat(' ', $filter, ' '), ' vcalendar ') and not($all/*[contains(concat(' ', @class, ' '), ' vcalendar ')])">
            <xsl:text> vevent</xsl:text>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="upcase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="locase" select="'abcdefghijklmnopqrstuvwxyz'"/>

    <xsl:template match="/">
        <microformats from="{$url}" title="{$top[name() = 'title']}">
            <xsl:for-each select="$top[name() = 'meta'][translate(@name, $upcase, $locase) = 'description']">
                <description>
                    <xsl:value-of select="normalize-space(@content)"/>
                </description>
            </xsl:for-each>
            <xsl:apply-templates select="$xml/microformats/*" mode="begin"/>
        </microformats>
    </xsl:template>


    <xsl:template match="node()[@type = 'compound']" mode="begin">
        <xsl:if test="contains(concat(' ', $thefilter, ' '), concat(' ', name(), ' ')) or contains(concat(' ', $thefilter, ' '), concat(' ', @name, ' '))">
            <xsl:variable name="name" select="name()"/>
            <xsl:variable name="realname">
                <xsl:choose>
                    <xsl:when test="string-length($xml/microformats/*[name() = $name]/@name) > 0">
                        <xsl:value-of select="$xml/microformats/*[name() = $name]/@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="$all[contains(concat(' ', normalize-space(@class), ' '), concat(' ', $name, ' '))]">
                <xsl:element name="{$realname}">
                    <xsl:apply-templates select="." mode="compound">
                        <xsl:with-param name="type" select="$name"/>
                        <xsl:with-param name="papa" select="."/>
                        <xsl:with-param name="papaname" select="$name"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template match="node()[@type = 'elemental']" mode="begin">
        <xsl:if test="contains(concat(' ', $thefilter, ' '), concat(' ', name(), ' '))">
            <xsl:call-template name="elemental">
                <xsl:with-param name="type" select="name()"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template name="elemental">
        <xsl:param name="type" select="'xfn'"/>
        <xsl:variable name="a" select="$all[name() = 'a']"/>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="string-length($xml//*[name() = $type]/@name) > 0">
                    <xsl:value-of select="$xml//*[name() = $type]/@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:for-each select="$xml/microformats/*[name() = $type]/*">
                <xsl:variable name="ele" select="."/>
                <xsl:for-each select="$a[contains(concat(' ', normalize-space(@*[name() = $ele/@attribute]), ' '), concat(' ', name($ele), ' '))]">
                    <xsl:element name="{name($ele)}">
                        <xsl:attribute name="href">
                            <xsl:apply-templates select="@href" mode="url">
                                <xsl:with-param name="class" select="$ele"/>
                            </xsl:apply-templates>
                        </xsl:attribute>
                        <xsl:apply-templates select="." mode="value">
                            <xsl:with-param name="class" select="$ele"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($value)">
            <xsl:element name="{$name}">
                <xsl:copy-of select="$value"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="node()" mode="compound">
        <xsl:param name="type" select="'type'"/>
        <xsl:param name="papa" select="."/>
        <xsl:param name="papaname" select="."/>
        <xsl:choose>
            <xsl:when test="$type = 'geo' and not(.//*[contains(concat(' ', normalize-space(@class), ' '), ' value ')]) and contains(@title, ';') and name() = 'abbr'">
                <latitude>
                    <xsl:value-of select="substring-before(@title, ';')"/>
                </latitude>
                <longitude>
                    <xsl:value-of select="substring-after(@title, ';')"/>
                </longitude>
                <text>
                    <xsl:variable name="value">
                        <xsl:apply-templates select="*|text()" mode="value">
                            <xsl:with-param name="class" select="$xml/microformats/*[name() = $type]"/>
                            <xsl:with-param name="order" select="1"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($value)"/>
                </text>
            </xsl:when>
            <xsl:when test="$type = 'geo' and contains(*[contains(concat(' ', normalize-space(@class), ' '), ' value-title ')]/@title, ';')">
                <xsl:variable name="value" select="*[contains(concat(' ', normalize-space(@class), ' '), ' value-title ')]/@title"/>
                <latitude>
                    <xsl:value-of select="substring-before($value, ';')"/>
                </latitude>
                <longitude>
                    <xsl:value-of select="substring-after($value, ';')"/>
                </longitude>
            </xsl:when>
            <xsl:when test="$type = 'geo' and .//*[contains(concat(' ', normalize-space(@class), ' '), ' value ')]">
                <xsl:variable name="value">
                    <xsl:apply-templates select=".//*[contains(concat(' ', normalize-space(@class), ' '), ' value ')]" mode="value">
                        <xsl:with-param name="class" select="$xml/microformats/*[name() = $type]"/>
                        <xsl:with-param name="order" select="1"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <latitude>
                    <xsl:value-of select="substring-before($value, ';')"/>
                </latitude>
                <longitude>
                    <xsl:value-of select="substring-after($value, ';')"/>
                </longitude>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$xml//*[name() = $type]/*" mode="builder">
                    <xsl:with-param name="curr" select="." />
                    <xsl:with-param name="papa" select="$papa" />
                    <xsl:with-param name="papaname" select="$papaname" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="remove-duplicates">
        <xsl:param name="text"/>
        <xsl:param name="separator"/>
        <xsl:param name="replace"/>
        <xsl:param name="bug" select="0"/>
        <xsl:choose>
            <xsl:when test="string-length($separator) = 0">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="before" select="substring-before(concat($text, $separator), $separator)"/>
                <xsl:variable name="after" select="substring-after($text, $separator)"/>
                <xsl:if test="string-length($before) > 0">
                    <xsl:value-of select="$before"/>
                    <xsl:if test="string-length($after) > 0">
                        <xsl:value-of select="$replace"/>
                    </xsl:if>
                </xsl:if>
                <!-- todo -->
                <xsl:if test="$bug = 618">
                    <xsl:value-of select="$after"/>
                </xsl:if>  <!--and $bug &lt; 618-->
                <xsl:if test="string-length($after) > 0 and $bug &lt; 618">
                    <xsl:call-template name="remove-duplicates">
                        <xsl:with-param name="text" select="$after"/>
                        <xsl:with-param name="separator" select="$separator"/>
                        <xsl:with-param name="replace" select="$replace"/>
                        <xsl:with-param name="bug" select="$bug + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="manyasone">
        <xsl:param name="a"/>
        <xsl:param name="children"/>
        <xsl:param name="curr"/>
        <xsl:param name="ele"/>
        <xsl:param name="h"/>
        <xsl:param name="papa"/>
        <xsl:param name="papaname"/>
        <xsl:param name="level"/>
        <xsl:variable name="pre-result">
            <xsl:for-each select="$children">
                <xsl:variable name="isPapa">
                    <xsl:call-template name="papa">
                        <xsl:with-param name="child" select="."/>
                        <xsl:with-param name="papa" select="$papa"/>
                        <xsl:with-param name="papaname" select="$papaname"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$isPapa = 1">
                    <xsl:variable name="value">
                        <xsl:apply-templates select="." mode="value"/>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($value)"/>
                    <xsl:value-of select="$ele/@separator"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="result" select="substring($pre-result, 1, string-length($pre-result) - string-length($ele/@separator))"/>
        <xsl:value-of select="$result"/>
        <xsl:variable name="a-result">
            <xsl:for-each select="$a">
                <xsl:variable name="inc" select="$top//*[(@id = substring-after(current()/@href, '#')) or (@id = substring-after(current()/@data, '#')) and string-length(@id) > 0]"/>
                <xsl:if test="string-length($inc) and position() = 1 and string-length($result) > 0">
                    <xsl:value-of select="$ele/@separator"/>
                </xsl:if>
                <xsl:variable name="value">
                    <xsl:apply-templates select="$ele" mode="builder">
                        <xsl:with-param name="curr" select="$inc"/>
                        <xsl:with-param name="papa" select="$papa"/>
                        <xsl:with-param name="papaname" select="'include'"/>
                        <xsl:with-param name="without_element" select="1"/>
                        <xsl:with-param name="level" select="$level + 2"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:value-of select="normalize-space($value)"/>
                <xsl:if test="position() != last() and $inc">
                    <xsl:value-of select="$ele/@separator"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$a-result"/>
        <xsl:for-each select="$h">
            <xsl:variable name="inc" select="$curr/../../..//*[contains(concat(' ', current(), ' '), concat(' ', normalize-space(@id), ' ')) and string-length(@id) > 0]"/>
            <xsl:if test="string-length($inc) > 0 and position() = 1 and string-length(concat($result, $a-result)) > 0">
                <xsl:value-of select="$ele/@separator"/>
            </xsl:if>
            <xsl:variable name="value">
                <xsl:apply-templates select="$ele" mode="builder">
                    <xsl:with-param name="curr" select="$inc"/>
                    <xsl:with-param name="papa" select="$papa"/>
                    <xsl:with-param name="papaname" select="'include'"/>
                    <xsl:with-param name="without_element" select="2"/>
                    <xsl:with-param name="level" select="$level + 2"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="normalize-space($value)"/>
            <xsl:if test="position() != last() and $inc">
                <xsl:value-of select="$ele/@separator"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="papa">
        <xsl:param name="child"/>
        <xsl:param name="level" select="0"/>
        <xsl:param name="pos" select="1"/>
        <xsl:param name="papa"/>
        <xsl:param name="papaname"/>
        <xsl:param name="father" select="."/>
        <xsl:choose>
            <xsl:when test="$papaname = 'include'">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:when test="count($xml//*[name() = $papaname or @type = $papaname]) + 1 > $pos">
                <xsl:for-each select="$xml//*[name() = $papaname or @type = $papaname]">
                    <xsl:if test="position() = $pos">
                        <xsl:variable name="lfather" select="$child/ancestor::*[contains(concat(' ', normalize-space(@class), ' '), concat(' ', name(current()), ' '))][position() = 1]"/>
                        <xsl:choose>
                            <xsl:when test="count($lfather/ancestor::*) > $level">
                                <xsl:call-template name="papa">
                                    <xsl:with-param name="child" select="$child"/>
                                    <xsl:with-param name="level" select="count($lfather/ancestor::*)"/>
                                    <xsl:with-param name="pos" select="$pos + 1"/>
                                    <xsl:with-param name="papa" select="$papa"/>
                                    <xsl:with-param name="papaname" select="$papaname"/>
                                    <xsl:with-param name="father" select="$lfather"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="papa">
                                    <xsl:with-param name="child" select="$child"/>
                                    <xsl:with-param name="level" select="$level"/>
                                    <xsl:with-param name="pos" select="$pos + 1"/>
                                    <xsl:with-param name="papa" select="$papa"/>
                                    <xsl:with-param name="papaname" select="$papaname"/>
                                    <xsl:with-param name="father" select="$father"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="generate-id($father) = generate-id($papa)">
                    <xsl:text>1</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="single-run">
        <xsl:param name="ele"/>
        <xsl:param name="nodeset"/>
        <xsl:param name="papa"/>
        <xsl:param name="papaname"/>
        <xsl:param name="pos" select="1"/>
        <xsl:for-each select="$nodeset[position() = $pos]">
            <xsl:variable name="isPapa">
                <xsl:call-template name="papa">
                    <xsl:with-param name="child" select="."/>
                    <xsl:with-param name="papa" select="$papa"/>
                    <xsl:with-param name="papaname" select="$papaname"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$isPapa = 1">
                <xsl:apply-templates select="." mode="compound-next">
                    <xsl:with-param name="class" select="$ele"/>
                    <xsl:with-param name="papa" select="$papa"/>
                    <xsl:with-param name="papaname" select="$papaname"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="string-length($isPapa) = 0 or $ele/@many = 'many'">
                <xsl:call-template name="single-run">
                    <xsl:with-param name="ele" select="$ele"/>
                    <xsl:with-param name="nodeset" select="$nodeset"/>
                    <xsl:with-param name="papa" select="$papa"/>
                    <xsl:with-param name="papaname" select="$papaname"/>
                    <xsl:with-param name="pos" select="$pos + 1"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="*" mode="builder">
        <xsl:param name="curr"/>
        <xsl:param name="papa"/>
        <xsl:param name="papaname"/>
        <xsl:param name="without_element" select="0"/>
        <xsl:param name="level" select="0"/>
        <xsl:if test="10 > $level">
            <xsl:variable name="h" select="$curr//*/@headers|$curr/@headers"/>
            <xsl:variable name="cur" select="$curr"/>
            <xsl:variable name="a" select="$cur//*[name()='a' or name()='object'][contains(concat(' ', normalize-space(@class), ' '), ' include ')]"/>
            <xsl:variable name="ele" select="."/>
            <xsl:variable name="attribute_name">
                <xsl:choose>
                    <xsl:when test="string-length($ele/@attribute) > 0">
                        <xsl:value-of select="$ele/@attribute"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>class</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="children" select="$cur//*[contains(concat(' ', normalize-space(@*[name() = $attribute_name]), ' '), concat(' ', name(current()), ' '))]|$cur[contains(concat(' ', normalize-space(@*[name() = $attribute_name]), ' '), concat(' ', name(current()), ' '))]"/>
            <xsl:choose>
                <xsl:when test="$ele/@many = 'manyasone'">
                    <xsl:choose>
                        <xsl:when test="$without_element = 0">
                            <xsl:variable name="value">
                                <xsl:call-template name="manyasone">
                                    <xsl:with-param name="a" select="$a" />
                                    <xsl:with-param name="children" select="$children" />
                                    <xsl:with-param name="curr" select="$curr" />
                                    <xsl:with-param name="ele" select="$ele" />
                                    <xsl:with-param name="h" select="$h" />
                                    <xsl:with-param name="papa" select="$papa"/>
                                    <xsl:with-param name="papaname" select="$papaname"/>
                                    <xsl:with-param name="level" select="$level"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="string-length(normalize-space($value)) != 0">
                                    <xsl:element name="{name($ele)}">
                                        <xsl:call-template name="remove-duplicates">
                                            <xsl:with-param name="text" select="$value"/>
                                            <xsl:with-param name="separator" select="$ele/@separator"/>
                                            <xsl:with-param name="replace" select="$ele/@separator"/>
                                        </xsl:call-template>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:when test="$debug = 1 and $ele/@mandatory = 'yes'">
                                    <error message="Required property ‘{name($ele)}’ not specified."/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="manyasone">
                                <xsl:with-param name="a" select="$a" />
                                <xsl:with-param name="children" select="$children" />
                                <xsl:with-param name="curr" select="$curr" />
                                <xsl:with-param name="ele" select="$ele" />
                                <xsl:with-param name="h" select="$h" />
                                <xsl:with-param name="papa" select="$papa"/>
                                <xsl:with-param name="papaname" select="$papaname"/>
                                <xsl:with-param name="level" select="$level"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="value">
                        <xsl:variable name="result">
                            <xsl:call-template name="single-run">
                                <xsl:with-param name="ele" select="$ele"/>
                                <xsl:with-param name="nodeset" select="$children"/>
                                <xsl:with-param name="papa" select="$papa"/>
                                <xsl:with-param name="papaname" select="$papaname"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:copy-of select="$result"/>
                        <xsl:for-each select="$a">
                            <xsl:variable name="isPapa">
                                <xsl:call-template name="papa">
                                    <xsl:with-param name="child" select="."/>
                                    <xsl:with-param name="papa" select="$papa"/>
                                    <xsl:with-param name="papaname" select="$papaname"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="(string-length($result) = 0 or $ele/@many = 'many') and $isPapa = 1">
                                <xsl:variable name="inc" select="$top//*[(@id = substring-after(current()/@href, '#')) or (@id = substring-after(current()/@data, '#')) and string-length(@id) > 0]"/>
                                <xsl:apply-templates select="$ele" mode="builder">
                                    <xsl:with-param name="curr" select="$inc"/>
                                    <xsl:with-param name="papa" select="$papa"/>
                                    <xsl:with-param name="papaname" select="'include'"/>
                                    <xsl:with-param name="level" select="$level + 2"/>
                                </xsl:apply-templates>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="$h">
                            <xsl:variable name="inc" select="$curr/../../..//*[contains(concat(' ', current(), ' '), concat(' ', normalize-space(@id), ' ')) and string-length(@id) > 0]"/>
                            <xsl:apply-templates select="$ele" mode="builder">
                                <xsl:with-param name="curr" select="$inc"/>
                                <xsl:with-param name="papa" select="$papa"/>
                                <xsl:with-param name="papaname" select="'include'"/>
                                <xsl:with-param name="level" select="$level + 2"/>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space($value)) != 0">
                            <xsl:copy-of select="$value"/>
                        </xsl:when>
                        <xsl:when test="$debug = 1 and $ele/@mandatory = 'yes'">
                            <error message="Required property ‘{name($ele)}’ not specified."/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template name="couldbe">
        <xsl:param name="couldbe"/>
        <xsl:param name="node"/>
        <xsl:variable name="before" select="substring-before(concat($couldbe, '|'), '|')" />
        <xsl:choose>
            <xsl:when test="contains(concat(' ', $node/@class, ' '), concat(' ', $before, ' '))">
                <xsl:value-of select="$before"/>
            </xsl:when>
            <xsl:when test="string-length(substring-after($couldbe, '|')) != 0">
                <xsl:call-template name="couldbe">
                    <xsl:with-param name="couldbe" select="substring-after($couldbe, '|')" />
                    <xsl:with-param name="node" select="$node" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="node()" mode="compound-next">
        <xsl:param name="class"/>
        <xsl:param name="papa"/>
        <xsl:param name="papaname"/>
        <xsl:if test="name() != 'del'">
            <xsl:variable name="couldbe">
                <xsl:call-template name="couldbe">
                    <xsl:with-param name="couldbe" select="$class/@couldbe" />
                    <xsl:with-param name="node" select="." />
                </xsl:call-template>
            </xsl:variable>
            <xsl:element name="{name($class)}">
                <xsl:if test="string-length($couldbe) != 0">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="$xml/microformats/*[name() = $couldbe]/@name">
                                <xsl:value-of select="$xml/microformats/*[name() = $couldbe]/@name"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$couldbe"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$xml/microformats/*[name() = $class/@type]">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$class/@type"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="./*" mode="compound">
                            <xsl:with-param name="type" select="$class/@type"/>
                            <xsl:with-param name="papa" select="."/>
                            <xsl:with-param name="papaname" select="$class/@type"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="name($class) = 'org' and not(*[contains(concat(' ', normalize-space(@class), ' '), ' organization-name ')])">
                        <xsl:apply-templates select="." mode="value">
                            <xsl:with-param name="class" select="$class"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="name($class) = 'tag'">
                        <xsl:attribute name="href">
                            <xsl:apply-templates select="@href" mode="url">
                                <xsl:with-param name="class" select="$class"/>
                            </xsl:apply-templates>
                        </xsl:attribute>
                        <xsl:apply-templates select="." mode="value">
                            <xsl:with-param name="class" select="$class"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="(name($class) = 'tel' or name($class) = 'email') and not(current()//*[contains(concat(' ', normalize-space(@class), ' '), ' type ')])">
                        <xsl:apply-templates select="." mode="value">
                            <xsl:with-param name="class" select="$class"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="(name($class) = 'tel' or name($class) = 'email') and not(current()//*[contains(concat(' ', normalize-space(@class), ' '), ' value ')]) and current()//*[contains(concat(' ', normalize-space(@class), ' '), ' type ')]">
                        <xsl:variable name="value">
                            <xsl:apply-templates select=".//*[not(ancestor-or-self::*[contains(concat(' ', normalize-space(@class), ' '), ' type ')])]|text()" mode="value">
                                <xsl:with-param name="class" select="$class"/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:apply-templates select="$class/type" mode="builder">
                            <xsl:with-param name="curr" select="." />
                            <xsl:with-param name="papa" select="$papa"/>
                            <xsl:with-param name="papaname" select="$papaname"/>
                        </xsl:apply-templates>
                        <value>
                            <xsl:value-of select="normalize-space($value)"/>
                        </value>
                    </xsl:when>
                    <xsl:when test="$class/*">
                        <xsl:apply-templates select="$class/*" mode="builder">
                            <xsl:with-param name="curr" select="." />
                            <xsl:with-param name="papa" select="$papa"/>
                            <xsl:with-param name="papaname" select="$papaname"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="string-length($couldbe) = 0">
                        <xsl:if test="$debug = 1">
                            <xsl:variable name="value">
                                <p>
                                    <xsl:apply-templates select="." mode="value">
                                        <xsl:with-param name="class" select="$class"/>
                                    </xsl:apply-templates>
                                </p>
                            </xsl:variable>
                            <xsl:if test="$debug = 1 and $class/@values and not(contains(concat(',', $class/@values, ','), concat(',', normalize-space($value), ',')))">
                                <xsl:attribute name="warning">
                                    <xsl:value-of select="concat('Field ‘', name($class), '’ has non standard value ‘', $value, '’. Should be one of ‘', $class/@values, '’')"/>
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:if>
                        <xsl:apply-templates select="." mode="value">
                            <xsl:with-param name="class" select="$class"/>
                        </xsl:apply-templates>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="string-length($couldbe) != 0">
                    <xsl:apply-templates select="." mode="compound">
                        <xsl:with-param name="type" select="$couldbe"/>
                        <xsl:with-param name="papa" select="."/>
                        <xsl:with-param name="papaname" select="$couldbe"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="value">
        <xsl:param name="class" select="."/>
        <xsl:param name="order" select="0"/>
        <xsl:param name="level" select="0"/>
        <xsl:choose>
            <xsl:when test="name() = 'del'"></xsl:when>
            <xsl:when test="(name() = 'a' or name() = 'object') and contains(concat(' ', @class, ' '), ' include ') and 10 > $level">
                <xsl:for-each select="$top//*[(@id = substring-after(current()/@href, '#')) or (@id = substring-after(current()/@data, '#')) and string-length(@id) > 0]">
                    <xsl:apply-templates select="." mode="value">
                        <xsl:with-param name="class" select="$class"/>
                        <xsl:with-param name="order" select="$order"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$class/@type = 'url' and name() = 'a' and $order = 0">
                <xsl:attribute name="href">
                    <xsl:apply-templates select="@href" mode="url">
                        <xsl:with-param name="class" select="$class"/>
                    </xsl:apply-templates>
                </xsl:attribute>
                <xsl:variable name="value">
                    <xsl:apply-templates select="*|text()" mode="value">
                        <xsl:with-param name="class" select="$class"/>
                        <xsl:with-param name="order" select="1"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:if test="string-length(normalize-space($value)) = 0">
                    <xsl:if test="$debug = 1">
                        <xsl:attribute name="warning">
                            <xsl:value-of select="concat('‘', name($class), '’ has no content.')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:text>no content</xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$class/@type = 'email' and not(*[contains(concat(' ', normalize-space(@class), ' '), ' value ')]) and starts-with(@href, 'mailto:') and $order = 0">
                <xsl:attribute name="href">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
                <xsl:if test="string-length(substring-before(substring-after(concat(@href, '?'), ':'), '?')) = 0">
                    <xsl:if test="$debug = 1">
                        <xsl:attribute name="warning">
                            <xsl:value-of select="concat('‘', name($class), '’ has no content.')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:text>no content</xsl:text>
                </xsl:if>
                <xsl:value-of select="substring-before(substring-after(concat(@href, '?'), ':'), '?')"/>
            </xsl:when>
            <xsl:when test="$class/@type = 'date' and name() = 'abbr' and $order = 0">
                <xsl:attribute name="date">
                    <xsl:value-of select="@title"/>
                </xsl:attribute>
                <xsl:variable name="value">
                    <xsl:apply-templates select="*|text()" mode="value">
                        <xsl:with-param name="class" select="$class"/>
                        <xsl:with-param name="order" select="1"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:if test="string-length(normalize-space($value)) = 0">
                    <xsl:if test="$debug = 1">
                        <xsl:attribute name="warning">
                            <xsl:value-of select="concat('‘', name($class), '’ has no content.')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:text>no content</xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="(name() = 'abbr' or name() = 'acronym') and @title and $order = 0">
                <xsl:value-of select="@title"/>
            </xsl:when>
            <xsl:when test="name() = 'input' and @value and $order = 0">
                <xsl:value-of select="@value"/>
            </xsl:when>
            <xsl:when test="name() = 'object' and @data and $class/@type = 'url' and $order = 0">
                <xsl:attribute name="href">
                    <xsl:apply-templates select="@data" mode="url">
                        <xsl:with-param name="class" select="$class"/>
                    </xsl:apply-templates>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="(name() = 'img' or name() = 'area') and @src and $class/@type = 'image'">
                <xsl:attribute name="href">
                    <xsl:apply-templates select="@src" mode="url">
                        <xsl:with-param name="class" select="$class"/>
                    </xsl:apply-templates>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="name() = 'img' and @longdesc">
                <xsl:value-of select="@longdesc"/>
            </xsl:when>
            <xsl:when test="name() = 'img' and @alt">
                <xsl:value-of select="@alt"/>
            </xsl:when>
            <xsl:when test="name() = 'ol' or name() = 'ul' and $order = 0">
                <xsl:for-each select="*[name() = 'li']">
                    <xsl:apply-templates select="*|text()" mode="value">
                        <xsl:with-param name="class" select="$class"/>
                        <xsl:with-param name="order" select="1"/>
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="current()/*[not(ancestor-or-self::del) and contains(concat(' ', normalize-space(@class), ' '), ' value-title ')]/@title">
                <xsl:variable name="value">
                    <xsl:apply-templates select="current()/*[not(ancestor-or-self::del) and contains(concat(' ', normalize-space(@class), ' '), ' value-title ')]/@title" mode="value">
                        <xsl:with-param name="class" select="$class"/>
                        <xsl:with-param name="order" select="1"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="current()//*[not(ancestor-or-self::del) and contains(concat(' ', normalize-space(@class), ' '), ' value ')]">
                <xsl:variable name="value">
                    <xsl:for-each select="current()//*[not(ancestor-or-self::del) and contains(concat(' ', normalize-space(@class), ' '), ' value ')]">
                        <xsl:apply-templates select="*|text()" mode="value">
                            <xsl:with-param name="class" select="$class"/>
                            <xsl:with-param name="order" select="1"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$order = 0">
                        <xsl:variable name="value">
                            <xsl:apply-templates select="*|text()" mode="value">
                                <xsl:with-param name="class" select="$class"/>
                                <xsl:with-param name="order" select="1"/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space($value)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*|text()" mode="value">
                            <xsl:with-param name="class" select="$class"/>
                            <xsl:with-param name="order" select="1"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()" mode="value">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="@*" mode="url">
        <xsl:variable name="protocol" select="concat(substring-before($url, '://'), '://')"/>
        <xsl:variable name="domain" select="concat($protocol, substring-before(substring-after(concat($url, '/'), '://'), '/'), '/')"/>
        <xsl:variable name="query" select="substring-after($url, '?')"/>
        <xsl:variable name="prepath" select="substring-before(concat($url, '?'), '?')"/>
        <xsl:variable name="path">
            <xsl:choose>
                <xsl:when test="contains(., '#') and substring-before(., '#') = ''">
                    <xsl:value-of select="substring-before(concat($url, '#'), '#')"/>
                </xsl:when>
                <xsl:when test="substring-before(., ':') = 'tel' or substring-before(., ':') = 'fax' or substring-before(., ':') = 'modem'">
                    <xsl:value-of select="substring-after(., ':')"/>
                </xsl:when>
                <xsl:when test="substring($prepath, string-length($prepath)) = '/'">
                    <xsl:value-of select="$prepath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$protocol"/>
                    <xsl:call-template name="extract-path">
                        <xsl:with-param name="path" select="substring-after($prepath, '//')"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not(starts-with(., 'http://')) and not(starts-with(., 'https://'))">
                <xsl:choose>
                    <xsl:when test="starts-with(., '/')">
                        <xsl:value-of select="concat($domain, substring-after(., '/'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($path, .)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="extract-path">
        <xsl:param name="path" select="''"/>
        <xsl:if test="string-length(substring-before($path, '/')) > 0">
            <xsl:value-of select="concat(substring-before($path, '/'), '/')"/>
            <xsl:call-template name="extract-path">
                <xsl:with-param name="path" select="substring-after($path, '/')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>