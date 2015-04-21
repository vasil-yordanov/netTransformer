/*
 * iTransformer is an open source tool able to discover and transform
 *  IP network infrastructures.
 *  Copyright (C) 2012  http://itransformers.net
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.itransformers.idiscover.v2.core.snmpdiscoverer;/*
 * iTransformer is an open source tool able to discover IP networks
 * and to perform dynamic data data population into a xml based inventory system.
 * Copyright (C) 2010  http://itransformers.net
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import net.itransformers.idiscover.core.*;
import net.itransformers.idiscover.discoverers.DefaultDiscovererFactory;
import net.itransformers.idiscover.discoverers.SnmpWalker;
import net.itransformers.idiscover.discoveryhelpers.xml.SnmpForXslt;
import net.itransformers.idiscover.discoveryhelpers.xml.XmlDiscoveryHelperFactory;
import net.itransformers.idiscover.networkmodel.DiscoveredDeviceData;
import net.itransformers.idiscover.v2.core.NodeDiscoverer;
import net.itransformers.idiscover.v2.core.NodeDiscoveryResult;
import net.itransformers.idiscover.v2.core.model.ConnectionDetails;
import net.itransformers.resourcemanager.config.ResourceType;
import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SnmpNodeDiscoverer implements NodeDiscoverer {
    static Logger logger = Logger.getLogger(SnmpNodeDiscoverer.class);
    private SnmpWalker walker;
    private XmlDiscoveryHelperFactory discoveryHelperFactory;
    private String[] discoveryTypes;
    private DiscoveryResourceManager discoveryResource;

    public SnmpNodeDiscoverer(Map<String, String> attributes, XmlDiscoveryHelperFactory discoveryHelperFactory, String[] discoveryTypes, DiscoveryResourceManager discoveryResource) throws Exception {
        this.discoveryHelperFactory = discoveryHelperFactory;
        this.discoveryTypes = discoveryTypes;
        this.discoveryResource = discoveryResource;
        Resource resource = new Resource("", "", attributes);
        walker = (SnmpWalker) new DefaultDiscovererFactory().createDiscoverer(resource);
    }

    private String probe(ConnectionDetails connectionDetails) {
        String hostName = connectionDetails.getParam("deviceName");

        IPv4Address ipAddress = new IPv4Address(connectionDetails.getParam("ipAddress"), connectionDetails.getParam("netMask"));
        Map<String,String> params1 = new HashMap<String, String>();
        params1.put("deviceName",hostName);
        params1.put("deviceType",connectionDetails.getParam("deviceType"));
        params1.put("ipAddress",connectionDetails.getParam("ipAddress"));

        ResourceType snmp = this.discoveryResource.returnResourceByParam(params1);
        Map<String, String> snmpConnParams = this.discoveryResource.getParamMap(snmp,"snmp");
        Resource resource = new Resource(hostName,ipAddress,connectionDetails.getParam("deviceType"), Integer.parseInt(snmpConnParams.get("port")), snmpConnParams);
        hostName = walker.getDeviceName(resource);
        if  (hostName!=null && hostName.contains(".")){
            hostName=hostName.substring(0,hostName.indexOf("."));
        }
        String deviceType = connectionDetails.getParam("deviceType");
        if(deviceType==null){
            deviceType = walker.getDeviceType(resource);
            connectionDetails.put("deviceType",deviceType);
        }

        return hostName;
    }

    @Override
    public NodeDiscoveryResult discover(ConnectionDetails connectionDetails) {
        String hostName = probe(connectionDetails);
        if (hostName == null) {
            return null;
        }
        NodeDiscoveryResult result = new NodeDiscoveryResult();
        Map<String,String> params1 = new HashMap<String, String>();
        params1.put("deviceName",hostName);
        params1.put("deviceType",connectionDetails.getParam("deviceType"));
        String ipAddressStr = connectionDetails.getParam("ipAddress");
        params1.put("ipAddress", ipAddressStr);
        IPv4Address ipAddress = new IPv4Address(ipAddressStr, null);

        //Set neighbourDryRun
     //   params1.put("neighbourIPDryRun","true");

        ResourceType snmpResource = this.discoveryResource.returnResourceByParam(params1);
        Map<String, String> snmpConnParams = this.discoveryResource.getParamMap(snmpResource, "snmp");


        Resource resource = new Resource(hostName,ipAddress,connectionDetails.getParam("deviceType"), Integer.parseInt(snmpConnParams.get("port")), snmpConnParams);

        resource.getAttributes().put("neighbourIPDryRun","true");

        String devName = walker.getDeviceName(resource);
        if (devName == null) {
            logger.info("Device name is null for resource: "+resource);
            return null;
        }
        if  (devName.contains(".")){
            devName=devName.substring(0,devName.indexOf("."));
        }
        result.setNodeId(devName);
        String deviceType = walker.getDeviceType(resource);
        resource.setDeviceType(deviceType);
        DiscoveryHelper discoveryHelper = discoveryHelperFactory.createDiscoveryHelper(deviceType);
        String[] requestParamsList = discoveryHelper.getRequestParams(discoveryTypes);

        RawDeviceData rawData = walker.getRawDeviceData(resource, requestParamsList);
        result.setDiscoveredData("rawData", rawData.getData());


        discoveryHelper.setDryRun(true);


        discoveryHelper.parseDeviceRawData(rawData, discoveryTypes, resource);

        SnmpForXslt.resolveIPAddresses(discoveryResource,"snmp");


        discoveryHelper.setDryRun(false);

        DiscoveredDeviceData discoveredDeviceData = discoveryHelper.parseDeviceRawData(rawData, discoveryTypes, resource);


        result.setDiscoveredData("deviceData", discoveredDeviceData);
        Device device = discoveryHelper.createDevice(discoveredDeviceData);

        List<DeviceNeighbour> neighbours = device.getDeviceNeighbours();

        List<ConnectionDetails> neighboursConnDetails = createNeighbourConnectionDetails(neighbours);
        result.setNeighboursConnectionDetails(neighboursConnDetails);
        return result;
    }

    private List<ConnectionDetails> createNeighbourConnectionDetails(List<DeviceNeighbour> neighbours) {
        List<ConnectionDetails> neighboursConnDetails = new ArrayList<ConnectionDetails>();
        for (DeviceNeighbour neighbour : neighbours) {
            ConnectionDetails neighbourConnectionDetails = new ConnectionDetails();
            neighbourConnectionDetails.put("deviceType",neighbour.getDeviceType());
            if (neighbour.getStatus()){ // if reachable
                neighbourConnectionDetails.put("deviceName",neighbour.getHostName());
                neighbourConnectionDetails.put("ipAddress",neighbour.getIpAddress().getIpAddress());
                neighbourConnectionDetails.setConnectionType("snmp");
                neighboursConnDetails.add(neighbourConnectionDetails);
            }
        }
        return neighboursConnDetails;
    }
}
