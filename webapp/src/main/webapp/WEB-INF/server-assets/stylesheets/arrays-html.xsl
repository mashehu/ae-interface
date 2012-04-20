<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:aejava="java:uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions"
                xmlns:search="java:uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension"
                xmlns:html="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="xs aejava search html"
                exclude-result-prefixes="xs aejava search html"
                version="2.0">

    <xsl:param name="page"/>
    <xsl:param name="pagesize"/>

    <xsl:variable name="vPage" select="if ($page) then $page cast as xs:integer else 1"/>
    <xsl:variable name="vPageSize" select="if ($pagesize) then $pagesize cast as xs:integer else 25"/>
    
    <xsl:param name="sortby"/>
    <xsl:param name="sortorder"/>

    <xsl:variable name="vSortBy" select="if ($sortby) then $sortby else 'accession'"/>
    <xsl:variable name="vSortOrder" select="if ($sortorder) then $sortorder else 'ascending'"/>
    
    <xsl:param name="queryid"/>
    <xsl:param name="keywords"/>
    <xsl:param name="directsub"/>
    <xsl:param name="accession"/>

    <xsl:param name="userid"/>

    <xsl:param name="host"/>
    <xsl:param name="basepath"/>

    <xsl:variable name="vBaseUrl">http://<xsl:value-of select="$host"/><xsl:value-of select="$basepath"/></xsl:variable>

    <xsl:variable name="vBrowseMode" select="not($accession)"/>

    <xsl:output omit-xml-declaration="yes" method="html"
                indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

    <xsl:include href="ae-html-page.xsl"/>
    <xsl:include href="ae-sort-arrays.xsl"/>
    <xsl:include href="ae-highlight.xsl"/>

    <xsl:template match="/">
        <html lang="en">
            <xsl:call-template name="page-header">
                <xsl:with-param name="pTitle">
                    <xsl:value-of select="if (not($vBrowseMode)) then concat(upper-case($accession), ' | ') else ''"/>
                    <xsl:text>Platforms | ArrayExpress Archive | EBI</xsl:text>
                </xsl:with-param>

                <xsl:with-param name="pExtraCode">
                    <link rel="stylesheet" href="{$basepath}/assets/stylesheets/ae_arrays_20.css" type="text/css"/>
                    <script src="{$basepath}/assets/scripts/jquery-1.4.2.min.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/jquery.query-2.1.7m-ebi.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_common_20.js" type="text/javascript"/>
                    <script src="{$basepath}/assets/scripts/ae_arrays_20.js" type="text/javascript"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="page-body"/>
        </html>
    </xsl:template>

    <xsl:template name="ae-contents">

        <xsl:variable name="vFilteredArrays" select="search:queryIndex($queryid)"/>
        <xsl:variable name="vTotal" select="count($vFilteredArrays)"/>

        <xsl:variable name="vFrom" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$vPage > 0"><xsl:value-of select="1 + ( $vPage - 1 ) * $vPageSize"/></xsl:when>
                <xsl:when test="$vTotal = 0">0</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vTo" as="xs:integer">
            <xsl:choose>
                <xsl:when test="( $vFrom + $vPageSize - 1 ) > $vTotal"><xsl:value-of select="$vTotal"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$vFrom + $vPageSize - 1"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div id="ae_contents_box_100pc">
            <div id="ae_content">
                <div id="ae_navi">
                    <a href="${interface.application.link.www_domain}/">EBI</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}">ArrayExpress</a>
                    <xsl:text> > </xsl:text>
                    <a href="{$basepath}/arrays?directsub=on">Platforms</a>
                    <xsl:if test="not($vBrowseMode)">
                        <xsl:text> > </xsl:text>
                        <a href="{$basepath}/arrays/{upper-case($accession)}">
                            <xsl:value-of select="upper-case($accession)"/>
                        </a>
                    </xsl:if>
                </div>
                <xsl:if test="$vBrowseMode">
                    <div id="ae_query_box">
                        <form id="ae_query_form" method="get" action="browse.html">
                            <fieldset id="ae_keywords_fset">
                                <label for="ae_keywords_field">Platform accessions, names, descriptions and providers [<a href="javascript:aeClearKeywords()">clear</a>]</label>
                                <input id="ae_keywords_field" type="text" name="keywords" value="{$keywords}" maxlength="255" class="ae_assign_font"/>
                                <div id="ae_directsub_option">
                                    <input id="ae_directsub_field" name="directsub" type="checkbox" title="Select the 'ArrayExpress data only' check box to query for platform designs submitted directly to ArrayExpress. If you want to query GEO data only include AND A-GEOD* in your query.">
                                        <xsl:if test="$directsub = 'on'">
                                            <xsl:attribute name="checked"/>
                                        </xsl:if>
                                    </input>
                                    <label for="ae_directsub_field" title="Select the 'ArrayExpress data only' check box to query for platform designs submitted directly to ArrayExpress. If you want to query GEO data only include AND A-GEOD* in your query">ArrayExpress data only</label>
                                </div>
                            </fieldset>
                            <div id="ae_submit_box"><input id="ae_query_submit" type="submit" value="Query"/></div>
                            <div id="ae_results_stats">
                                <div>
                                    <xsl:value-of select="$vTotal"/>
                                    <xsl:text> platform design</xsl:text>
                                    <xsl:if test="$vTotal != 1">
                                        <xsl:text>s</xsl:text>
                                    </xsl:if>
                                    <xsl:text> found</xsl:text>
                                    <xsl:if test="$vTotal > $vPageSize">
                                        <xsl:text>, displaying </xsl:text>
                                        <xsl:value-of select="$vFrom"/>
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select="$vTo"/>
                                    </xsl:if>
                                    <xsl:text>.</xsl:text>
                                </div>
                                <xsl:if test="$vTotal > $vPageSize">
                                    <xsl:variable name="vTotalPages" select="floor( ( $vTotal - 1 ) div $vPageSize ) + 1"/>
                                    <div id="ae_results_pager">
                                        <div id="total_pages"><xsl:value-of select="$vTotalPages"/></div>
                                        <div id="page"><xsl:value-of select="$vPage"/></div>
                                        <div id="page_size"><xsl:value-of select="$vPageSize"/></div>
                                    </div>
                                </xsl:if>
                            </div>
                        </form>
                    </div>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$vTotal&gt;0">
                        <div id="ae_results_box">
                            <table id="ae_results_table" border="0" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="col_accession sortable">
                                            <xsl:text>Accession</xsl:text>
                                            <xsl:call-template name="add-sort">
                                                <xsl:with-param name="pKind" select="'accession'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th class="col_name sortable">
                                            <xsl:text>Name</xsl:text>
                                            <xsl:call-template name="add-sort">
                                                <xsl:with-param name="pKind" select="'name'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th class="col_species sortable">
                                            <xsl:text>Species</xsl:text>
                                            <xsl:call-template name="add-sort">
                                                <xsl:with-param name="pKind" select="'species'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th class="col_files">
                                            <xsl:text>Files</xsl:text>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:call-template name="ae-sort-arrays">
                                        <xsl:with-param name="pArrays" select="$vFilteredArrays"/>
                                        <xsl:with-param name="pFrom" select="$vFrom"/>
                                        <xsl:with-param name="pTo" select="$vTo"/>
                                        <xsl:with-param name="pSortBy" select="$vSortBy"/>
                                        <xsl:with-param name="pSortOrder" select="$vSortOrder"/>
                                    </xsl:call-template>
                                </tbody>
                            </table>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="block-warning">
                            <xsl:with-param name="pStyle" select="'ae_warn_area'"/>
                            <xsl:with-param name="pMessage">
                                <xsl:text>There are no platform designs matching your search criteria found in ArrayExpress Archive.</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="array_design">
        <xsl:param name="pFrom"/>
        <xsl:param name="pTo"/>
        <xsl:if test="position() >= $pFrom and not(position() > $pTo)">
            <xsl:variable name="vArrFolder" select="aejava:getAcceleratorValueAsSequence('ftp-folder', accession)"/>
            <tr>
                <xsl:if test="not($vBrowseMode)">
                    <xsl:attribute name="class">expanded</xsl:attribute>
                </xsl:if>
                <td class="col_accession">
                    <div>
                        <a href="{$basepath}/arrays/{accession}">
                            <xsl:call-template name="highlight">
                                <xsl:with-param name="pQueryId" select="$queryid"/>
                                <xsl:with-param name="pText" select="accession"/>
                                <xsl:with-param name="pFieldName" select="'accession'"/>
                            </xsl:call-template>
                        </a>
                        <xsl:if test="not(user/@id = '1')">
                            <img src="{$basepath}/assets/images/silk_lock.gif" width="8" height="9"/>
                        </xsl:if>
                    </div>
                </td>
                <td class="col_name">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="name"/>
                            <xsl:with-param name="pFieldName"/>
                        </xsl:call-template>
                        <xsl:if test="count(name) = 0">&#160;</xsl:if>
                    </div>
                </td>
                <td class="col_species">
                    <div>
                        <xsl:call-template name="highlight">
                            <xsl:with-param name="pQueryId" select="$queryid"/>
                            <xsl:with-param name="pText" select="string-join(species, ', ')"/>
                            <xsl:with-param name="pFieldName" select="'species'"/>
                        </xsl:call-template>
                        <xsl:if test="count(species) = 0"><xsl:text>&#160;</xsl:text></xsl:if>
                    </div>
                </td>
                <td class="col_files">
                    <div>
                        <xsl:choose>
                            <xsl:when test="count($vArrFolder/file) > 0">
                                <a href="{$basepath}/files/{accession}">
                                    <img src="{$basepath}/assets/images/basic_tick.gif" width="16" height="16"
                                         alt="Click to browse all files"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$basepath}/assets/images/silk_data_unavail.gif" width="16" height="16"
                                 alt="-"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </td>
            </tr>
            <xsl:if test="not($vBrowseMode)">
            <tr>
                <td class="col_detail" colspan="4">
                    <div class="detail_table">
                        <xsl:call-template name="detail-table">
                            <xsl:with-param name="pAccession" select="accession"/>
                            <xsl:with-param name="pFiles" select="$vArrFolder"/>
                        </xsl:call-template>

                    </div>
                </td>
            </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-table">
        <xsl:param name="pAccession"/>
        <xsl:param name="pFiles"/>
        <xsl:variable name="vExpsWithArray" select="search:queryIndex('experiments', concat('visible:true array:', $pAccession, if ($userid) then concat(' userid:(', $userid, ')') else ''))"/>

        <table border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Description'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="description"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Version'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="version"/>
                </xsl:call-template>
                <xsl:call-template name="detail-row">
                    <xsl:with-param name="pName" select="'Provider'"/>
                    <xsl:with-param name="pFieldName"/>
                    <xsl:with-param name="pValue" select="provider"/>
                </xsl:call-template>
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="'Links'"/>
                    <xsl:with-param name="pContent">
                        <xsl:choose>
                            <xsl:when test="count($vExpsWithArray) > 10">
                               <a href="{$basepath}/browse.html?array={$pAccession}">All <xsl:value-of select="count($vExpsWithArray)"/> experiments done using <xsl:value-of select="$pAccession"/></a>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithArray) > 1">
                                <a href="{$basepath}/browse.html?array={$pAccession}">All experiments done using <xsl:value-of select="$pAccession"/></a>
                                <xsl:text>: (</xsl:text>
                                    <xsl:for-each select="$vExpsWithArray">
                                        <xsl:sort select="accession"/>
                                        <a href="{$vBaseUrl}/experiments/{accession}">
                                            <xsl:value-of select="accession"/>
                                        </a>
                                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                    </xsl:for-each>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:when test="count($vExpsWithArray) = 1">
                                <a href="{$vBaseUrl}/experiments/{$vExpsWithArray/accession}">
                                    <xsl:text>Experiment </xsl:text><xsl:value-of select="$vExpsWithArray/accession"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="count($pFiles/file) > 0">
                <xsl:call-template name="detail-section">
                    <xsl:with-param name="pName" select="'Files'"/>
                    <xsl:with-param name="pContent">
                        <xsl:variable name="vADFile" select="$pFiles/file[@kind = 'adf' and @extension = 'txt']"/>
                        <xsl:if test="count($vADFile) > 0">
                            <table cellspacing="0" cellpadding="0" border="0">
                                <tbody>
                                    <tr>
                                        <td class="attr_name">Array Design</td>
                                        <td class="attr_value">
                                            <xsl:for-each select="$vADFile">
                                                <xsl:sort select="lower-case(@name)"/>
                                                <a href="{$vBaseUrl}/files/{$pAccession}/{@name}">
                                                    <xsl:value-of select="@name"/>
                                                </a>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </xsl:if>
                        <div>
                            <a href="{$basepath}/files/{$pAccession}">
                                <img src="{$basepath}/assets/images/silk_ftp.gif" width="16" height="16"
                                     alt="Click to browse all files"/>
                                <xsl:text>Browse all available files</xsl:text>
                            </a>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
                </xsl:if>
            </tbody>
        </table>

    </xsl:template>

    <xsl:template name="detail-row">
        <xsl:param name="pName"/>
        <xsl:param name="pFieldName"/>
        <xsl:param name="pValue"/>
        <xsl:if test="$pValue/node()">
            <xsl:call-template name="detail-section">
                <xsl:with-param name="pName" select="$pName"/>
                <xsl:with-param name="pContent">
                    <xsl:for-each select="$pValue">
                        <div>
                            <xsl:apply-templates select="." mode="highlight">
                                <xsl:with-param name="pFieldName" select="$pFieldName"/>
                            </xsl:apply-templates>
                        </div>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="detail-section">
        <xsl:param name="pName"/>
        <xsl:param name="pContent"/>
        <tr>
            <td class="detail_name">
                <div class="outer"><xsl:value-of select="$pName"/></div>
            </td>
            <td class="detail_value">
                <div class="outer"><xsl:copy-of select="$pContent"/></div>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="add-sort">
        <xsl:param name="pKind"/>
        <xsl:if test="$pKind = $vSortBy">
            <xsl:choose>
                <xsl:when test="'ascending' = $vSortOrder"><img src="{$basepath}/assets/images/mini_arrow_up.gif" width="12" height="16" alt="^"/></xsl:when>
                <xsl:otherwise><img src="{$basepath}/assets/images/mini_arrow_down.gif" width="12" height="16" alt="v"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
