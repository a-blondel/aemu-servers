<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:template match="/">
                <html>
                        <head>
                                <title>EA Hub Prometheus Server Status</title>
                                <link rel="stylesheet" type="text/css" href="style.css" />
                                <link rel="icon" href="favicon.ico" type="image/x-icon" />
                                <meta http-equiv="refresh" content="120" />
                        </head>
                        <body>
                                <div class="headline">
                                        <xsl:value-of select="./prometheus/@usercount" /> online on <span class="site">eahub.eu</span> Prometheus ad hoc server
                                </div>
                                <div class="navigation">
                                        <a class="setuplink" href="https://github.com/Kethen/aemu/releases/latest" target="_blank">PSP/Vita Setup</a>
                                        <a class="setuplink" href="https://github.com/Kethen/ppsspp/releases/latest" target="_blank">PPSSPP Setup</a>
                                        <a class="discordlink" href="https://discord.gg/fwrQHHxrQQ" target="_blank">EA Hub Discord</a>
                                        <a class="discordlink" href="https://discord.gg/wxeGVkM" target="_blank">PSP Online Discord</a>
                                </div>
                                <xsl:for-each select="./prometheus/game">
                                        <xsl:sort select="./@name"/>
                                        <div class="gametitle">
                                                <table class="splitter">
                                                        <tr>
                                                                <td class="left">
                                                                        <xsl:value-of select="./@name" />
                                                                </td>
                                                                <td class="right">
                                                                        <span class="usercount">
                                                                                <span class="good"><xsl:value-of select="./@usercount" /> Total</span> -
                                                                                <span class="bad">
                                                                                        <xsl:choose>
                                                                                                <xsl:when test="./group[@name='Groupless']">
                                                                                                        <xsl:value-of select="./group[@name='Groupless']/@usercount" />
                                                                                                </xsl:when>
                                                                                                <xsl:otherwise>0</xsl:otherwise>
                                                                                        </xsl:choose> Ghosts
                                                                                </span>
                                                                        </span>
                                                                </td>
                                                        </tr>
                                                        <tr class="bottom">
                                                                <td>
                                                                        <table class="groups">
                                                                                <tr>
                                                                                        <th>Group</th>
                                                                                        <th>User Count</th>
                                                                                        <th>Players</th>
                                                                                </tr>
                                                                                <xsl:for-each select="./group">
                                                                                        <tr>
                                                                                                <td><xsl:value-of select="./@name" /></td>
                                                                                                <td><xsl:value-of select="./@usercount" /></td>
                                                                                                <td>
                                                                                                        <xsl:for-each select="./user">
                                                                                                                <xsl:value-of select="."/>
                                                                                                                <xsl:if test="position() != last()">
                                                                                                                    <xsl:text>, </xsl:text>
                                                                                                                </xsl:if>
                                                                                                        </xsl:for-each>
                                                                                                </td>
                                                                                        </tr>
                                                                                </xsl:for-each>
                                                                        </table>
                                                                </td>
                                                        </tr>
                                                </table>
                                        </div>
                                </xsl:for-each>
                                <div class="footer">
                                        © 2012 Team PRO (<a href="https://github.com/MrColdbird" target="_blank">MrColdbird</a>), maintained by <a href="https://github.com/Kethen" target="_blank">Kethen</a> - Hosted by EA Hub (<a href="https://github.com/a-blondel" target="_blank">a-blondel</a>)
                                </div>
                        </body>
                </html>
        </xsl:template>
</xsl:stylesheet>
