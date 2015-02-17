<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:functx="http://www.functx.com"
                xmlns:math="http://exslt.org/math">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:include href="utils.xslt"/>
    <xsl:template match="/">
        <graphml>
            <key id="hostname" for="node" attr.name="hostname" attr.type="string"/>
            <key id="deviceModel" for="node" attr.name="deviceModel" attr.type="string"/>
            <key id="deviceType" for="node" attr.name="deviceType" attr.type="string"/>
            <key id="nodeInfo" for="node" attr.name="nodeInfo" attr.type="string"/>
            <key id="DiscoveredIPv4Address" for="node" attr.name="DiscoveredIPv4Address" attr.type="string"/>
            <key id="geoCoordinates" for="node" attr.name="geoCoordinates" attr.type="string"/>
            <key id="site" for="node" attr.name="site" attr.type="string"/>
            <key id="diff" for="node" attr.name="diff" attr.type="string"/>
            <key id="diffs" for="node" attr.name="diffs" attr.type="string"/>
            <key id="IPv6Forwarding" for="node" attr.name="IPv6Forwarding" attr.type="string"/>
            <key id="IPv4Forwarding" for="node" attr.name="IPv4Forwarding" attr.type="string"/>
            <key id="SubnetPrefix" for="node" attr.name="SubnetPrefix" attr.type="string"/>

            <key id="name" for="edge" attr.name="name" attr.type="string"/>
            <key id="method" for="edge" attr.name="method" attr.type="string"/>
            <key id="dataLink" for="edge" attr.name="dataLink" attr.type="string"/>
            <key id="ipLink" for="edge" attr.name="ipLink" attr.type="string"/>
            <key id="MPLS" for="edge" attr.name="MPLS" attr.type="string"/>
            <key id="IPv6Forwarding" for="edge" attr.name="IPv6Forwarding" attr.type="string"/>
            <key id="IPv4Forwarding" for="edge" attr.name="IPv4Forwarding" attr.type="string"/>

            <key id="bgpLocalAS" for="node" attr.name="bgpLocalAS" attr.type="string"/>
            <key id="bgpAutonomousSystemA" for="edge" attr.name="bgpAutonomousSystemA" attr.type="string"/>
            <key id="bgpAutonomousSystemB" for="edge" attr.name="bgpAutonomousSystemB" attr.type="string"/>

            <key id="InterfaceNameA" for="edge" attr.name="InterfaceNameA" attr.type="string"/>
            <key id="InterfaceNameB" for="edge" attr.name="InterfaceNameB" attr.type="string"/>
            <key id="IPv4AddressA" for="edge" attr.name="IPv4AddressA" attr.type="string"/>
            <key id="IPv4AddressB" for="edge" attr.name="IPv4AddressB" attr.type="string"/>
            <key id="edgeTooltip" for="edge" attr.name="edgeTooltip" attr.type="string"/>
            <key id="diff" for="edge" attr.name="diff" attr.type="string"/>
            <key id="diffs" for="edge" attr.name="diffs" attr.type="string"/>

            <graph edgedefault="undirected">
                <!-- data schema -->


                <xsl:variable name="nodeID">
                    <xsl:value-of select="/DiscoveredDevice/name"/>
                </xsl:variable>
                <xsl:variable name="root" select="/DiscoveredDevice"/>
                <xsl:variable name="deviceModel">
                    <xsl:value-of select="//DiscoveredDevice/parameters/parameter[name='Device Model']/value"/>
                </xsl:variable>
                <xsl:variable name="deviceType">
                    <xsl:value-of select="//DiscoveredDevice/parameters/parameter[name='Device Type']/value"/>
                </xsl:variable>


                <xsl:variable name="siteID">
                    <xsl:value-of select="//DiscoveredDevice/parameters/parameter[name='siteID']/value"/>
                </xsl:variable>
                <xsl:variable name="DiscoveredIPv4Address">
                    <xsl:value-of select="//DiscoveredDevice/parameters/parameter[name='Management IP Address']/value"/>
                </xsl:variable>
                <xsl:variable name="BGPLocalASInfo">
                    <xsl:value-of select="//DiscoveredDevice/parameters/parameter[name='BGPLocalASInfo']/value"/>
                </xsl:variable>
                <xsl:variable name="X" select="//DiscoveredDevice/parameters/parameter[name='X Coordinate']/value"/>
                <xsl:variable name="Y" select="//DiscoveredDevice/parameters/parameter[name='Y Coordinate']/value"/>
                <xsl:variable name="IPv6Forwarding"
                              select="//DiscoveredDevice/parameters/parameter[name='ipv6Forwarding']/value"/>
                <xsl:variable name="IPv4Forwarding"
                              select="//DiscoveredDevice/parameters/parameter[name='ipv4Forwarding']/value"/>
                <!--Prepare Central Node-->
                <node>
                    <xsl:attribute name="id">
                        <xsl:value-of select="$nodeID"/>
                    </xsl:attribute>
                    <xsl:attribute name="label">
                        <xsl:value-of select="$nodeID"/>
                    </xsl:attribute>

                    <data key="hostname">
                        <xsl:value-of select="$nodeID"/>
                    </data>
                    <data key="deviceModel">
                        <xsl:value-of select="$deviceModel"/>
                    </data>
                    <data key="deviceType">
                        <xsl:value-of select="$deviceType"/>
                    </data>

                    <data key="DiscoveredIPv4Address">
                        <xsl:value-of select="$DiscoveredIPv4Address"/>
                    </data>
                    <data key="bgpLocalAS"><xsl:value-of select="$BGPLocalASInfo"/></data>
                    <data key="site">
                        <xsl:value-of select="$siteID"/>
                    </data>
                    <data key="geoCoordinates">
                        <xsl:value-of select="$Y"/>,<xsl:value-of select="$X"/>
                    </data>
                    <data key="IPv6Forwarding">
                        <xsl:value-of select="$IPv6Forwarding"/>
                    </data>
                    <data key="IPv4Forwarding">
                        <xsl:value-of select="$IPv4Forwarding"/>
                    </data>
                    <!--data key="nodeInfo" diffignore="YES">
                        <xsl:text disable-output-escaping="yes">&lt;![CDATA[ &lt;html&gt;</xsl:text>
                        <xsl:text disable-output-escaping="yes">&lt;b&gt;Type: &lt;/b&gt;</xsl:text>
                        <xsl:value-of select="$deviceType"/>
                        <xsl:text disable-output-escaping="yes"> &lt;b&gt;Model:&lt;/b&gt; </xsl:text>
                        <xsl:value-of select="$deviceModel"/>
                        <xsl:text disable-output-escaping="yes"> &lt;b&gt;Site:&lt;/b&gt; </xsl:text>
                        <xsl:value-of select="$siteID"/>
                        <xsl:text
                                disable-output-escaping="yes">&lt;br&gt;&lt;b&gt;Mgmt IP address:&lt;/b&gt; </xsl:text>
                        <xsl:value-of select="$ManagementIPAddress"/>
                        <xsl:text disable-output-escaping="yes">&lt;br/&gt;</xsl:text>
                        <xsl:text disable-output-escaping="yes">&lt;b&gt;IPv6Forwarding:&lt;/b&gt; </xsl:text>
                        <xsl:value-of select="$IPv6Forwarding"/>
                        <xsl:text disable-output-escaping="yes">&lt;br/&gt;</xsl:text>
                        <xsl:text disable-output-escaping="yes">&lt;b&gt;BGPLocalASInfo:&lt;/b&gt; </xsl:text>
                        <xsl:value-of select="$BGPLocalASInfo"/>
                        <xsl:text disable-output-escaping="yes">&lt;/html&gt;]]&gt;</xsl:text>
                    </data-->
                </node>
                <xsl:variable name="nodeIDs"
                              select="distinct-values($root//object[objectType='Discovery Interface']/object[objectType='Discovered Neighbor']/name)"/>

                <xsl:for-each select="$nodeIDs">

                    <xsl:variable name="neighID">
                        <xsl:value-of select="."/>
                    </xsl:variable>
                    <xsl:if test="($neighID !=$nodeID and $neighID!='')">
                        <node>
                            <xsl:attribute name="id">
                                <xsl:value-of select="$neighID"/>
                            </xsl:attribute>
                        </node>
                    </xsl:if>
                </xsl:for-each>

                <xsl:variable name="edges">
                    <xsl:for-each select="$root//object[objectType='Discovery Interface']">
                        <xsl:variable name="interface">
                            <xsl:value-of select="name"/>
                        </xsl:variable>
                        <xsl:variable name="IPv4Forwarding">
                            <xsl:value-of
                                    select="distinct-values(parameters/parameter[name='IPv4Forwarding']/value)"/>
                        </xsl:variable>
                        <xsl:variable name="IPv6Forwarding">
                            <xsl:value-of
                                    select="distinct-values(parameters/parameter[name='IPv6Forwarding']/value)"/>
                        </xsl:variable>
                        <xsl:variable name="remoteInterfaces">
                            <xsl:value-of
                                    select="distinct-values($root//object[name=$interface]/object[objectType='Discovered Neighbor']/parameters/parameter[name='Neighbor Port']/value)"/>
                        </xsl:variable>
                        <xsl:variable name="localIPaddress">
                            <xsl:value-of
                                    select="distinct-values($root//object[name=$interface]/object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value)"/>
                        </xsl:variable>
                        <xsl:variable name="neighborIDs">
                            <xsl:value-of
                                    select="distinct-values($root//object[name=$interface]/object[objectType='Discovered Neighbor']/name)"/>
                        </xsl:variable>

                        <xsl:variable name="methods_all">
                            <xsl:for-each
                                    select="distinct-values($root//object[name=$interface]/object[objectType='Discovered Neighbor']/parameters/parameter[name='Discovery Method']/value)">
                                <xsl:value-of select="."/>
                                <xsl:text>,</xsl:text>
                            </xsl:for-each>
                            <!--<xsl:for-each select="$neighborIDs">-->
                                <!--<xsl:variable name="neighID" select="."/>-->
                                <!--<xsl:for-each-->
                                        <!--select="distinct-values($root//object[objectType='DeviceLogicalData']/object[name=$neighID]/parameters/parameter[name='Discovery Method']/value)">-->
                                    <!--<xsl:value-of select="."/>-->
                                    <!--<xsl:text>,</xsl:text>-->
                                <!--</xsl:for-each>-->
                            <!--</xsl:for-each>-->
                        </xsl:variable>
                        <xsl:variable name="bgpRemoteAs">
                            <!--<xsl:for-each select="$neighborIDs">-->
                                <!--<xsl:variable name="neighID" select="."/>-->
                                <!--<xsl:for-each-->
                                        <!--select="distinct-values($root//object[objectType='DeviceLogicalData']/object[name=$neighID]/parameters/parameter[name='bgpPeerRemoteAs']/value)">-->
                                    <!--<xsl:value-of select="."/>-->
                                <!--</xsl:for-each>-->
                            <!--</xsl:for-each>-->
                        </xsl:variable>
                        <xsl:variable name="subnetCount" select="count(object[objectType='IPv4 Address']/parameters/parameter[name='ipv4Subnet']/value)"></xsl:variable>
                        <xsl:variable name="neighborCount"
                                      select="count(distinct-values($root//object[name=$interface]/object[objectType='Discovered Neighbor']/name))">
                        </xsl:variable>



                            <xsl:variable name="node" select="$nodeID"/>

                            <xsl:choose>
                                <xsl:when test="$neighborCount>1">
                                    <xsl:for-each select="object[objectType='IPv4 Address']/parameters/parameter[name='ipv4Subnet']">
                                    <xsl:variable name="subnetPrefix" select="value"/>

                                    <xsl:variable name="subnetPrefixBitCount" select="../parameter[name='ipv4SubnetPrefix']/value"/>
                                    <xsl:variable name="subnetId"><xsl:value-of select="$subnetPrefix"/>/<xsl:value-of select="$subnetPrefixBitCount"/> </xsl:variable>

                                    <node>
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$subnetId"/>
                                        </xsl:attribute>
                                        <data key="deviceType">Subnet</data>
                                        <data key="deviceModel">passiveHub</data>
                                        <data key="SubnetPrefix"><xsl:value-of select="$subnetPrefix"/></data>
                                        <data key="subnetPrefixBitCount"><xsl:value-of select="$subnetPrefixBitCount"/></data>
                                        <data key="subnetPrefixIPv4Count"><xsl:value-of select="math:power(2,$subnetPrefixBitCount)"/></data>

                                    </node>


                                    <xsl:call-template name="subnet-to-node">
                                        <xsl:with-param name="localInterface" select="$interface"/>
                                        <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>


                                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                        <xsl:with-param name="nodeID" select="$node"/>

                                        <xsl:with-param name="subnetPrefix" select="$subnetId"/>
                                        <xsl:with-param name="localIP"
                                                        select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                                        <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                                        <xsl:with-param name="methods" select="$methods_all"/>
                                    </xsl:call-template>

                                    <xsl:call-template name="subnet_to_neighbour_assembly">

                                        <xsl:with-param name="subnetPrefix" select="$subnetId"/>

                                        <xsl:with-param name="BGPLocalASInfo" select="$BGPLocalASInfo"/>
                                        <xsl:with-param name="deviceType" select="$deviceType"/>
                                        <xsl:with-param name="interface" select="$interface"/>
                                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                        <xsl:with-param name="bgpRemoteAs" select="$bgpRemoteAs"/>
                                        <xsl:with-param name="IPv6Forwarding"  select="$IPv6Forwarding"/>
                                        <xsl:with-param name="methods_all" select="$methods_all"/>
                                        <xsl:with-param name="root" select="$root"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                 <xsl:call-template name="neighbour_assembly">
                                     <xsl:with-param name="node" select="$node"/>
                                     <xsl:with-param name="BGPLocalASInfo" select="$BGPLocalASInfo"/>
                                     <xsl:with-param name="deviceType" select="$deviceType"/>
                                     <xsl:with-param name="interface" select="$interface"/>
                                     <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                     <xsl:with-param name="bgpRemoteAs" select="$bgpRemoteAs"/>
                                     <xsl:with-param name="IPv6Forwarding"  select="$IPv6Forwarding"/>
                                     <xsl:with-param name="methods_all" select="$methods_all"/>
                                     <xsl:with-param name="root" select="$root"/>
                                 </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>

                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="logicalDataEdges">
                    <edges>
                    <xsl:for-each select="distinct-values($root//object[objectType='DeviceLogicalData']/object[objectType='Discovered Neighbor']/name)">
                        <xsl:variable name="neighbor" select="."/>

                        <xsl:variable name="methods"><xsl:for-each select="distinct-values($root//object[objectType='DeviceLogicalData']/object[objectType='Discovered Neighbor' and name=$neighbor]/parameters/parameter[name='Discovery Method']/value)"><xsl:value-of select="."/>,</xsl:for-each></xsl:variable>
                        <xsl:variable name="neighborIP" select="$root//object[objectType='DeviceLogicalData']/object[objectType='Discovered Neighbor' and name=$neighbor][1]/parameters/parameter[name='Neighbor IP Address']/value"/>
                        <xsl:variable name="neighborDeviceType" select="$root//object[objectType='DeviceLogicalData']/object[objectType='Discovered Neighbor' and name=$neighbor][1]/parameters/parameter[name='Neighbor Device Type']/value"/>


                        <xsl:variable name="sort">
                            <root>
                                <test>
                                    <node>
                                        <xsl:value-of select="$nodeID"/>
                                    </node>
                                </test>
                                <test>
                                    <node>
                                        <xsl:value-of select="$neighbor"/>
                                    </node>
                                </test>
                            </root>
                        </xsl:variable>
                        <xsl:variable name="sorted">
                            <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>
                        </xsl:variable>
                        <xsl:variable name="first" select="substring-before($sorted,' ')"/>
                        <xsl:variable name="second" select="substring-after($sorted,' ')"/>

                        <xsl:variable name="edgeId"><xsl:value-of select="$first"/>-<xsl:value-of select="$second"/></xsl:variable>


                        <edge>
                            <xsl:attribute name="id"><xsl:value-of select="$edgeId"/></xsl:attribute><xsl:attribute name="label"><xsl:value-of select="$edgeId"/></xsl:attribute><xsl:attribute name="source">
                                <xsl:value-of select="$nodeID"/>
                            </xsl:attribute><xsl:attribute name="target">
                                <xsl:value-of select="$neighbor"/>
                            </xsl:attribute>
                            <data>
                                <xsl:attribute name="key">methods</xsl:attribute>
                                <xsl:value-of select="$methods"/>
                            </data>
                            <data>
                                <xsl:attribute name="key">nodeIDDeviceType</xsl:attribute>
                                <xsl:value-of select="$neighborDeviceType"/>

                            </data>
                        </edge>

                    </xsl:for-each>
                    </edges>

                </xsl:variable>
                <!--xsl:copy-of select="$edges" /-->
                <xsl:for-each select="distinct-values($edges//node/@id)">
                    <xsl:variable name="node-id" select="."/>
                    <xsl:copy-of select="$edges//node[@id=$node-id][1]"/>
                </xsl:for-each>
                <xsl:for-each select="distinct-values($edges//edge/@id)">
                    <xsl:variable name="edge-id" select="."/>
                    <xsl:copy-of select="$edges//edge[@id=$edge-id][1]"/>
                </xsl:for-each>
                <xsl:for-each select="$logicalDataEdges/edges/edge">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </graph>
        </graphml>
    </xsl:template>
    <xsl:template match="test">
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="neighbor">
        <xsl:param name="nodeID"/>
        <xsl:param name="nodeIDDeviceType"/>

        <xsl:param name="neighID"/>
        <xsl:param name="localInterface"/>
        <xsl:param name="remoteInterface"/>
        <xsl:param name="IPv4Forwarding"/>
        <xsl:param name="IPv6Forwarding"/>
        <xsl:param name="localIP"/>
        <xsl:param name="remoteIP"/>
        <xsl:param name="bgpLocalAS"/>
        <xsl:param name="bgpRemoteAS"/>
        <xsl:param name="methods"/>
        <xsl:variable name="sort">
            <root>
                <test>
                    <node>
                        <xsl:value-of select="$nodeID"/>
                    </node>
                </test>
                <test>
                    <node>
                        <xsl:value-of select="$neighID"/>
                    </node>
                </test>
            </root>
        </xsl:variable>
        <xsl:variable name="sorted">
            <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>
        </xsl:variable>
        <!--<xsl:message>DEBUG: <xsl:value-of select="$sorted"/></xsl:message>-->
        <xsl:variable name="first" select="substring-before($sorted,' ')"/>;
        <xsl:variable name="second" select="substring-after($sorted,' ')"/>;
        <!--<xsl:message>DEBUG:first <xsl:value-of select="$first"/></xsl:message>-->
        <!--<xsl:message>DEBUG:second <xsl:value-of select="$second"/></xsl:message>-->
        <xsl:variable name="interfaceSort">
            <root>
                <node>
                    <xsl:attribute name="name"><xsl:value-of select="$nodeID"/></xsl:attribute>
                    <xsl:value-of select="$localInterface"/>
                </node>
                <node>
                    <xsl:attribute name="name"><xsl:value-of select="$neighID"/></xsl:attribute>
                    <xsl:value-of select="$remoteInterface"/>
                </node>
            </root>
        </xsl:variable>
        <xsl:variable name="ipAddressSort">
            <root>
                <test>
                    <node>
                        <xsl:attribute name="name"><xsl:value-of select="$nodeID"/></xsl:attribute>
                        <xsl:value-of select="$localIP"/>
                    </node>
                </test>
                <test>
                    <node>
                        <xsl:attribute name="name"><xsl:value-of select="$neighID"/></xsl:attribute>
                        <xsl:value-of select="$remoteIP"/>
                    </node>
                </test>
            </root>
        </xsl:variable>

        <xsl:variable name="BGPASSort">
            <root>
                <test>
                    <node>
                        <xsl:attribute name="name"><xsl:value-of select="$nodeID"/></xsl:attribute>
                        <xsl:value-of select="$bgpLocalAS"/>
                    </node>
                </test>
                <test>
                    <node>
                        <xsl:attribute name="name"><xsl:value-of select="$neighID"/></xsl:attribute>
                        <xsl:value-of select="$bgpRemoteAS"/>
                    </node>
                </test>
            </root>
        </xsl:variable>
        <xsl:variable name="edgeId"><xsl:choose>
            <xsl:when test="$localInterface!='' and $remoteInterface!=''">

                <!--<xsl:message>DEBUG: SORT <xsl:copy-of select="$sort2"/></xsl:message>-->
                <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>- <xsl:value-of select="$interfaceSort/root//node[@name = $first]"/><xsl:text> </xsl:text><xsl:value-of select="$interfaceSort/root//node[contains($second,@name)]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$localIP!='' and $remoteIP!=''">


                        <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>- <xsl:value-of select="$ipAddressSort/root//node[@name = $first]"/><xsl:text> </xsl:text><xsl:value-of select="$ipAddressSort/root//node[contains($second,@name)]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$sort//root/test">
                            <xsl:sort select="node"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

        </xsl:variable>
        <xsl:message>DEBUG: Edge ID -> <xsl:value-of select="$edgeId"/> </xsl:message>
        <edge>
            <xsl:attribute name="id"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="label"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="source">
                <xsl:value-of select="$nodeID"/>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:value-of select="$neighID"/>
            </xsl:attribute>

            <data>
                <xsl:attribute name="key">InterfaceNameA</xsl:attribute>
                <xsl:value-of select="$interfaceSort/root//node[contains($first,@name)]"/>
            </data>
            <data>
                <xsl:attribute name="key">InterfaceNameB</xsl:attribute>
                <xsl:value-of select="$interfaceSort/root//node[contains($second,@name)]"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv4Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv4Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv6Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv6Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv4AddressA</xsl:attribute>
                <xsl:value-of select="$ipAddressSort/root//node[contains($first,@name)]"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv4AddressB</xsl:attribute>
                <xsl:value-of select="$ipAddressSort/root//node[contains($second,@name)]"/>
            </data>
            <data>
                <xsl:attribute name="key">method</xsl:attribute>
                <xsl:value-of select="distinct-values($methods)"/>
            </data>
            <data>
                <xsl:attribute name="key">ipLink</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$localIP!='' or $nodeIDDeviceType='Subnet'">YES</xsl:when>
                    <xsl:otherwise>NO</xsl:otherwise>
                </xsl:choose>
            </data>
            <data>
                <xsl:attribute name="key">dataLink</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$remoteInterface!=''">YES</xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="contains($methods,'MAC')">YES</xsl:when>
                            <xsl:otherwise>NO</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </data>

            <data>
                <xsl:attribute name="key">bgpAutonomousSystemA</xsl:attribute>
                <xsl:value-of select="$BGPASSort/root//node[contains($first,@name)]"/>
            </data>
            <data>
                <xsl:attribute name="key">bgpAutonomousSystemB</xsl:attribute>
                <xsl:value-of select="$BGPASSort/root//node[contains($second,@name)]"/>
            </data>
        </edge>
    </xsl:template>


    <xsl:template name="neighbour_assembly">
        <xsl:param name="node"/>
        <xsl:param name="root"/>
        <xsl:param name="deviceType"/>
        <xsl:param name="interface"/>
        <xsl:param name="IPv4Forwarding"/>
        <xsl:param name="IPv6Forwarding"/>
        <xsl:param name="BGPLocalASInfo"/>
        <xsl:param name="bgpRemoteAs"/>
        <xsl:param name="methods_all"/>

        <xsl:variable name="cdp_check">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'CDP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lldp_check">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'LLDP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="SLASH30">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'Slash30')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="SLASH31">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'Slash31')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="next_hop">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'r_')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="c_next_hop">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'c_')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="MAC">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'MAC')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ARP">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'ARP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="OSPF">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'OSPF')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="BGP">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'BGP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <!--methods>
            <xsl:value-of select="$methods_all"/>
        </methods-->
        <!--flags>
            <cdp><xsl:value-of select="$cdp_check"/></cdp>
        </flags-->
        <xsl:choose>
            <xsl:when test="$cdp_check='YES' or $lldp_check = 'YES'">
                <xsl:for-each select="object[objectType='Discovered Neighbor']/name">
                    <xsl:call-template name="neighbor">
                        <xsl:with-param name="localInterface" select="$interface"/>
                        <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>

                        <xsl:with-param name="remoteInterface"
                                        select="../parameters/parameter[name='Neighbor Port']/value"/>
                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                        <xsl:with-param name="nodeID" select="$node"/>
                        <xsl:with-param name="neighID" select="."/>
                        <xsl:with-param name="localIP"
                                        select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                        <xsl:with-param name="remoteIP"
                                        select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                        <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                        <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                        <xsl:with-param name="methods" select="$methods_all"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$SLASH30='YES' or $SLASH31='YES'">
                        <xsl:for-each select="object[objectType='Discovered Neighbor']/name">
                            <xsl:variable name="neighID">
                                <xsl:value-of select="."/>
                            </xsl:variable>
                            <xsl:call-template name="neighbor">
                                <xsl:with-param name="localInterface" select="$interface"/>
                                <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>

                                <xsl:with-param name="remoteInterface"/>
                                <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                <xsl:with-param name="nodeID" select="$node"/>
                                <xsl:with-param name="neighID" select="$neighID"/>
                                <xsl:with-param name="localIP"
                                                select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                                <xsl:with-param name="remoteIP"
                                                select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                                <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                <xsl:with-param name="methods" select="$methods_all"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$next_hop='YES' or $c_next_hop ='YES'">
                                <!--xsl:for-each select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method' and (contains(value, 'NEXT') or contains(value,'c_NEXT') or contains(value,'ARP') or contains(value,'MAC'))]]/name"-->
                                <xsl:for-each
                                        select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method' and (contains(value, 'NEXT') or contains(value,'c_') or contains(value,'r_'))]]/name">
                                    <xsl:variable name="neighID">
                                        <xsl:value-of select="."/>
                                    </xsl:variable>
                                    <xsl:call-template name="neighbor">
                                        <xsl:with-param name="localInterface"
                                                        select="$interface"/>
                                        <xsl:with-param name="remoteInterface"/>
                                        <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>

                                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                        <xsl:with-param name="nodeID" select="$node"/>
                                        <xsl:with-param name="neighID" select="$neighID"/>
                                        <xsl:with-param name="localIP">
                                            <xsl:value-of
                                                    select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="remoteIP"
                                                        select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                        <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                                        <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                        <xsl:with-param name="methods" select="$methods_all"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--xsl:for-each
                         select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method'  and contains(value,'MAC')]]/name"-->
                                <xsl:for-each select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method']]/name">
                                    <xsl:variable name="neighID">
                                        <xsl:value-of select="."/>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="$deviceType='Subnet'">
                                            <xsl:call-template name="neighbor">
                                                <xsl:with-param name="localInterface"
                                                                select="$interface"/>
                                                <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>

                                                <xsl:with-param name="remoteInterface"/>
                                                <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                                <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                                <xsl:with-param name="nodeID" select="$node"/>
                                                <xsl:with-param name="neighID" select="$neighID"/>
                                                <xsl:with-param name="localIP"
                                                                select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                                                <xsl:with-param name="remoteIP"
                                                                select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                                <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                                                <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                                <xsl:with-param name="methods" select="$methods_all"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="neighbor">
                                                <xsl:with-param name="localInterface"
                                                                select="$interface"/>
                                                <xsl:with-param name="nodeIDDeviceType" select="$deviceType"/>

                                                <xsl:with-param name="remoteInterface"/>
                                                <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                                <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                                <xsl:with-param name="nodeID" select="$node"/>
                                                <xsl:with-param name="neighID" select="$neighID"/>
                                                <xsl:with-param name="localIP"
                                                                select="../../object[objectType='IPv4 Address']/parameters/parameter[name='IPv4Address']/value"/>
                                                <xsl:with-param name="remoteIP"
                                                                select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                                <xsl:with-param name="bgpLocalAS" select="$BGPLocalASInfo"/>
                                                <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                                <xsl:with-param name="methods" select="$methods_all"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <xsl:template name="subnet_to_neighbour_assembly">




        <xsl:param name="subnetPrefix"/>
        <xsl:param name="root"/>
        <xsl:param name="deviceType"/>
        <xsl:param name="interface"/>
        <xsl:param name="IPv4Forwarding"/>
        <xsl:param name="IPv6Forwarding"/>
        <xsl:param name="BGPLocalASInfo"/>
        <xsl:param name="bgpRemoteAs"/>
        <xsl:param name="methods_all"/>

        <xsl:variable name="cdp_check">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'CDP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lldp_check">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'LLDP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="SLASH30">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'Slash30')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="SLASH31">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'Slash31')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="next_hop">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'r_')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="c_next_hop">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'c_')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="MAC">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'MAC')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ARP">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'ARP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="OSPF">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'OSPF')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="BGP">
            <xsl:choose>
                <xsl:when test="contains($methods_all,'BGP')">YES</xsl:when>
                <xsl:otherwise>NO</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <!--methods>
            <xsl:value-of select="$methods_all"/>
        </methods-->
        <!--flags>
            <cdp><xsl:value-of select="$cdp_check"/></cdp>
        </flags-->
        <xsl:choose>
            <xsl:when test="$cdp_check='YES' or $lldp_check = 'YES'">
                <xsl:for-each select="object[objectType='Discovered Neighbor']/name">
                    <xsl:call-template name="subnet-to-neighbour">
                        <xsl:with-param name="neighIDDeviceType" select="$deviceType"/>

                        <xsl:with-param name="remoteInterface"
                                        select="../parameters/parameter[name='Neighbor Port']/value"/>
                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                        <xsl:with-param name="subnetPrefix" select="$subnetPrefix"/>
                        <xsl:with-param name="neighID" select="."/>
                        <xsl:with-param name="remoteIP"
                                        select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                        <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                        <xsl:with-param name="methods" select="$methods_all"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$SLASH30='YES' or $SLASH31='YES'">
                        <xsl:for-each select="object[objectType='Discovered Neighbor']/name">

                            <xsl:call-template name="subnet-to-neighbour">
                                <xsl:with-param name="neighIDDeviceType" select="$deviceType"/>

                                <xsl:with-param name="remoteInterface"
                                                select="../parameters/parameter[name='Neighbor Port']/value"/>
                                <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                <xsl:with-param name="subnetPrefix" select="$subnetPrefix"/>
                                <xsl:with-param name="neighID" select="."/>
                                <xsl:with-param name="remoteIP"
                                                select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                <xsl:with-param name="methods" select="$methods_all"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$next_hop='YES' or $c_next_hop ='YES'">
                                <!--xsl:for-each select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method' and (contains(value, 'NEXT') or contains(value,'c_NEXT') or contains(value,'ARP') or contains(value,'MAC'))]]/name"-->
                                <xsl:for-each
                                        select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method' and (contains(value, 'NEXT') or contains(value,'c_') or contains(value,'r_'))]]/name">
                                    <xsl:variable name="neighID">
                                        <xsl:value-of select="."/>
                                    </xsl:variable>
                                    <xsl:call-template name="subnet-to-neighbour">
                                        <xsl:with-param name="neighIDDeviceType" select="$deviceType"/>

                                        <xsl:with-param name="remoteInterface"
                                                        select="../parameters/parameter[name='Neighbor Port']/value"/>
                                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                        <xsl:with-param name="subnetPrefix" select="$subnetPrefix"/>
                                        <xsl:with-param name="neighID" select="$neighID"/>
                                        <xsl:with-param name="remoteIP"
                                                        select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                        <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                        <xsl:with-param name="methods" select="$methods_all"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--xsl:for-each
                         select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method'  and contains(value,'MAC')]]/name"-->
                                <xsl:for-each select="$root//object[name=$interface]/object[objectType='Discovered Neighbor' and parameters/parameter[name='Discovery Method']]/name">
                                    <xsl:variable name="neighID">
                                        <xsl:value-of select="."/>
                                    </xsl:variable>


                                    <xsl:call-template name="subnet-to-neighbour">
                                        <xsl:with-param name="neighIDDeviceType" select="$deviceType"/>

                                        <xsl:with-param name="remoteInterface"
                                                        select="../parameters/parameter[name='Neighbor Port']/value"/>
                                        <xsl:with-param name="IPv4Forwarding" select="$IPv4Forwarding"/>
                                        <xsl:with-param name="IPv6Forwarding" select="$IPv6Forwarding"/>

                                        <xsl:with-param name="subnetPrefix" select="$subnetPrefix"/>
                                        <xsl:with-param name="neighID" select="$neighID"/>
                                        <xsl:with-param name="remoteIP"
                                                        select="../parameters/parameter[name='Neighbor IP Address']/value"/>
                                        <xsl:with-param name="bgpRemoteAS" select="$bgpRemoteAs"/>

                                        <xsl:with-param name="methods" select="$methods_all"/>
                                    </xsl:call-template>


                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>


    <xsl:template name="subnet-to-node">
        <xsl:param name="nodeID"/>
        <xsl:param name="nodeIDDeviceType"/>
        <xsl:param name="subnetPrefix"/>
        <xsl:param name="localInterface"/>
        <xsl:param name="IPv4Forwarding"/>
        <xsl:param name="IPv6Forwarding"/>
        <xsl:param name="localIP"/>
        <xsl:param name="bgpLocalAS"/>
        <xsl:param name="methods"/>
        <xsl:variable name="sort">
            <root>
                <test>
                    <node>
                        <xsl:value-of select="$nodeID"/>
                    </node>
                </test>
                <test>
                    <node>
                        <xsl:value-of select="$subnetPrefix"/>
                    </node>
                </test>
            </root>
        </xsl:variable>
        <xsl:variable name="sorted">
            <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>
        </xsl:variable>
        <!--<xsl:message>DEBUG: <xsl:value-of select="$sorted"/></xsl:message>-->
        <xsl:variable name="first" select="substring-before($sorted,' ')"/>;
        <xsl:variable name="second" select="substring-after($sorted,' ')"/>;
        <!--<xsl:message>DEBUG:first <xsl:value-of select="$first"/></xsl:message>-->
        <!--<xsl:message>DEBUG:second <xsl:value-of select="$second"/></xsl:message>-->




        <xsl:variable name="edgeId"><xsl:value-of select="$first"/>-<xsl:value-of select="$second"/></xsl:variable>
        <xsl:message>DEBUG: Edge ID -> <xsl:value-of select="$edgeId"/> </xsl:message>
        <edge>
            <xsl:attribute name="id"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="label"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="source">
                <xsl:value-of select="$nodeID"/>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:value-of select="$subnetPrefix"/>
            </xsl:attribute>

            <data>
                <xsl:attribute name="key">InterfaceNameA</xsl:attribute>
                <xsl:value-of select="$localInterface"/>
            </data>

            <data>
                <xsl:attribute name="key">IPv4Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv4Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv6Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv6Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv4AddressA</xsl:attribute>
                <xsl:value-of select="$localIP"/>
            </data>

            <data>
                <xsl:attribute name="key">method</xsl:attribute>
                <xsl:value-of select="distinct-values($methods)"/>
            </data>
            <data>
                <xsl:attribute name="key">ipLink</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$localIP!='' or $nodeIDDeviceType='Subnet'">YES</xsl:when>
                    <xsl:otherwise>NO</xsl:otherwise>
                </xsl:choose>
            </data>
            <data>
                <xsl:attribute name="key">dataLink</xsl:attribute>YES
            </data>
            <data>
                <xsl:attribute name="key">bgpAutonomousSystemA</xsl:attribute>
                <xsl:value-of select="$bgpLocalAS"/>
            </data>

        </edge>
    </xsl:template>

    <xsl:template name="subnet-to-neighbour">
        <xsl:param name="neighID"/>
        <xsl:param name="neighIDDeviceType"/>
        <xsl:param name="subnetPrefix"/>
        <xsl:param name="remoteInterface"/>
        <xsl:param name="IPv4Forwarding"/>
        <xsl:param name="IPv6Forwarding"/>
        <xsl:param name="remoteIP"/>
        <xsl:param name="bgpRemoteAS"/>
        <xsl:param name="methods"/>
        <xsl:variable name="sort">
            <root>
                <test>
                    <node>
                        <xsl:value-of select="$neighID"/>
                    </node>
                </test>
                <test>
                    <node>
                        <xsl:value-of select="$subnetPrefix"/>
                    </node>
                </test>
            </root>
        </xsl:variable>
        <xsl:variable name="sorted">
            <xsl:apply-templates select="$sort//root/test"><xsl:sort select="node"/></xsl:apply-templates>
        </xsl:variable>
        <!--<xsl:message>DEBUG: <xsl:value-of select="$sorted"/></xsl:message>-->
        <xsl:variable name="first" select="substring-before($sorted,' ')"/>;
        <xsl:variable name="second" select="substring-after($sorted,' ')"/>;
        <!--<xsl:message>DEBUG:first <xsl:value-of select="$first"/></xsl:message>-->
        <!--<xsl:message>DEBUG:second <xsl:value-of select="$second"/></xsl:message>-->




        <xsl:variable name="edgeId"><xsl:value-of select="$first"/>-<xsl:value-of select="$second"/></xsl:variable>
        <xsl:message>DEBUG: Edge ID -> <xsl:value-of select="$edgeId"/> </xsl:message>
        <edge>
            <xsl:attribute name="id"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="label"><xsl:value-of select="$edgeId"/></xsl:attribute>
            <xsl:attribute name="source">
                <xsl:value-of select="$neighID"/>
            </xsl:attribute>
            <xsl:attribute name="target">
                <xsl:value-of select="$subnetPrefix"/>
            </xsl:attribute>
            <data>
                <xsl:attribute name="key">InterfaceNameA</xsl:attribute>
                <xsl:value-of select="$remoteInterface"/>
            </data>

            <data>
                <xsl:attribute name="key">IPv4Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv4Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv6Forwarding</xsl:attribute>
                <xsl:value-of select="$IPv6Forwarding"/>
            </data>
            <data>
                <xsl:attribute name="key">IPv4AddressA</xsl:attribute>
                <xsl:value-of select="$remoteIP"/>
            </data>

            <data>
                <xsl:attribute name="key">method</xsl:attribute>
                <xsl:value-of select="distinct-values($methods)"/>
            </data>
            <data>
                <xsl:attribute name="key">ipLink</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$remoteIP!='' or $neighIDDeviceType='Subnet'">YES</xsl:when>
                    <xsl:otherwise>NO</xsl:otherwise>
                </xsl:choose>
            </data>
            <data>
                <xsl:attribute name="key">dataLink</xsl:attribute>YES
            </data>
            <data>
                <xsl:attribute name="key">bgpAutonomousSystemA</xsl:attribute>
                <xsl:value-of select="$bgpRemoteAS"/>
            </data>

        </edge>
    </xsl:template>


    <xsl:function name="functx:is-node-in-sequence" as="xs:boolean" xmlns:functx="http://www.functx.com">
        <xsl:param name="node" as="node()?"/>
        <xsl:param name="seq" as="node()*"/>
        <xsl:sequence select="some $nodeInSeq in $seq satisfies $nodeInSeq is $node"/>
    </xsl:function>
    <xsl:function name="functx:distinct-nodes" as="node()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:sequence
                select=" for $seq in (1 to count($nodes))return $nodes[$seq][not(functx:is-node-in-sequence(.,$nodes[position() &lt; $seq]))]"/>
    </xsl:function>

</xsl:stylesheet>
