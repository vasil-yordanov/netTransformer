/*
 * BgpMapSnmpDiscoverer.java
 *
 * This work is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This work is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * Copyright (c) 2010-2016 iTransformers Labs. All rights reserved.
 */

package net.itransformers.idiscover.v2.core.bgpdiscoverer;

import net.itransformers.idiscover.core.DiscoveryResourceManager;
import net.itransformers.idiscover.v2.core.*;
import net.itransformers.idiscover.v2.core.model.ConnectionDetails;
import net.itransformers.resourcemanager.config.ResourceType;
import net.itransformers.snmp2xml4j.snmptoolkit.*;
import net.itransformers.utils.AutoLabeler;
import net.itransformers.utils.CmdLineParser;
import net.itransformers.utils.ProjectConstants;
import net.itransformers.utils.XsltTransformer;
import net.percederberg.mibble.MibLoaderException;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.context.support.FileSystemXmlApplicationContext;
import org.springframework.context.support.GenericApplicationContext;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.*;


/**
 * Created by niau on 2/28/16.
 */
public class BgpMapSnmpDiscoverer extends ANetworkDiscoverer {

    static Logger logger = Logger.getLogger(BgpMapSnmpDiscoverer.class);
    private DiscoveryResourceManager discoveryResource;
    private String labelDirName;
    private String projectPath;
    private String xsltFileName1;
    private String xsltFileName2;
    private String xsltFileName3;
    private String asNumbers;
    private String mibDir;

    private String graphmlUndirectedPath;

    private String queryParameters;
    private MibLoaderHolder mibLoaderHolder;
    private SnmpManager snmpManager;

//    public bgpMapSnmpDiscoverer(DiscoveryResourceManager discoveryResource, String labelDirName, String projectPath, String xsltFileName, String queryParameters) {
//        this.discoveryResource = discoveryResource;
//        this.labelDirName = labelDirName;
//        this.projectPath = projectPath;
//        this.xsltFileName = xsltFileName;
//        this.queryParameters = queryParameters;
//    }

    @Override
    public NetworkDiscoveryResult discoverNetwork(List<ConnectionDetails> connectionDetailsList, int depth) {

        try {
            mibLoaderHolder = new MibLoaderHolder(new File(mibDir), false);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (MibLoaderException e) {
            e.printStackTrace();
        }
        NetworkDiscoveryResult networkDiscoveryResult = new NetworkDiscoveryResult();


        File baseDir = new File(projectPath, labelDirName);
        if (!baseDir.exists()) baseDir.mkdir();

        for (ConnectionDetails connectionDetails : connectionDetailsList) {
            Map<String, String> params1 = new HashMap<String, String>();

            ConnectionDetailsValidator connectionDetailsValidator = new ConnectionDetailsValidator(connectionDetails);


            if (connectionDetailsValidator.validateDeviceName()) {
                params1.put("deviceName", connectionDetails.getParam("deviceName"));

            } else {
                logger.info("Can't find deviceName in connection details");
            }
            if (connectionDetailsValidator.validateDeviceType()) {
                params1.put("deviceType", connectionDetails.getParam("deviceType"));

            } else {
                logger.info("Can't find deviceType in connection details");
            }

            if (connectionDetailsValidator.validateIpAddress()) {
                params1.put("ipAddress", connectionDetails.getParam("ipAddress"));

            } else {
                logger.info("Having an ipAddress in connectionDetails is obligatory! Can't discover BGP Peering Map with those connection details");
                return null;
            }


            ResourceType snmpResource = this.discoveryResource.returnResourceByParam(params1);
            Map<String, String> snmpConnParams = this.discoveryResource.getParamMap(snmpResource, "snmp");
            snmpConnParams.put("ipAddress", connectionDetails.getParam("ipAddress"));

            if (snmpConnParams != null) {
//                snmpConnParams.put("ipAddress", connectionDetails.getParam("ipAddress"));
//                snmpConnParams.put("query.parameters", queryParameters);
//                snmpConnParams.put("mibDir", mibDir);
//
                setSnmpManager(snmpConnParams);


                byte[] rawData = new byte[0];
                try {
                    String sysDescr = snmpGetNext(snmpConnParams, "1.3.6.1.2.1.1.1");
                    if (sysDescr != null) {
                        logger.info(sysDescr);
                        logger.info("SNMP walk start");


                        rawData = snmpWalk(snmpConnParams);

                        logger.debug(new String(rawData));
                    } else {
                        logger.info("Can't connect through SNMP to " + connectionDetails.getParam("ipAddress"));
                    }
                } catch (Exception e) {
                    logger.info(e.getMessage());
                }
                logger.info("SNMP walk end");

                NodeDiscoveryResult nodeDiscoveryResult = new NodeDiscoveryResult();
                nodeDiscoveryResult.setDiscoveredData("rawData", rawData);


                ByteArrayInputStream xsmlInputStream = new ByteArrayInputStream(rawData);

                try {
                    File xsltTransformer1 = new File(projectPath,xsltFileName1);

                    ByteArrayOutputStream firstStage = XsltTransformer.transformXML(xsltTransformer1, xsmlInputStream, params1);

                    File xsltTransformer2 = new File(projectPath,xsltFileName2);
                    ByteArrayInputStream inputStream2 = new ByteArrayInputStream(firstStage.toByteArray());

                    ByteArrayOutputStream secondStage = XsltTransformer.transformXML(xsltTransformer2, inputStream2, params1);
                    ByteArrayInputStream inputStream3 = new ByteArrayInputStream(secondStage.toByteArray());

                    ByteArrayOutputStream thirdStage = XsltTransformer.transformXML(xsltTransformer2, inputStream3, params1);

                    File xsltTransformer3 = new File(projectPath,xsltFileName3);



               //     nodeDiscoveryResult.setDiscoveredData("deviceData",deviceData);



                } catch (ParserConfigurationException e) {
                    logger.info(e.getMessage());
                } catch (IOException e) {
                    logger.info(e.getMessage());
                } catch (SAXException e) {
                    logger.info(e.getMessage());
                } catch (TransformerException e) {
                    logger.info(e.getMessage());
                }

            } else {
                logger.info("Can't find an SNMP resource for those connection details");
            }

        }
        fireNetworkDiscoveredEvent(networkDiscoveryResult);

        return networkDiscoveryResult;
//        logger.info("First-transformation has started with xsltTransformator "+settings.get("xsltFileName1"));
//
//        ByteArrayOutputStream outputStream1 = new ByteArrayOutputStream();
//
//
//        File xsltFileName1 = new File(xsltFileName1);
//
//
//        ByteArrayInputStream inputStream1 = new ByteArrayInputStream(rawData);
//        transformer.transformXML(inputStream1, xsltFileName1, outputStream1, settings, null);
//
//
//        logger.info("First transformation finished");
//
//        File intermediateDataFile = new File(outputDir, "intermediate-bgpPeeringMap.xml");
//
//        FileUtils.writeStringToFile(intermediateDataFile, new String(outputStream1.toByteArray()));
//
//        logger.trace("First transformation output");
//
//        logger.trace(outputStream1.toString());
//        logger.info("Second transformation started with xsltTransformator "+settings.get("xsltFileName2"));
//
//        ByteArrayOutputStream outputStream2 = new ByteArrayOutputStream();
//        File xsltFileName2 = new File(projectDir, settings.get("xsltFileName2"));
//        ByteArrayInputStream inputStream2 = new ByteArrayInputStream(outputStream1.toByteArray());
//        transformer.transformXML(inputStream2, xsltFileName2, outputStream2, settings, null);
//        logger.info("Second transformation info");
//        logger.trace("Second transformation Graphml output");
//        logger.trace(outputStream2.toString());
//
//
//        ByteArrayInputStream inputStream3 = new ByteArrayInputStream(outputStream2.toByteArray());
//        ByteArrayOutputStream outputStream3 = new ByteArrayOutputStream();
//        File xsltFileName3 = new File(System.getProperty("base.dir"), settings.get("xsltFileName3"));
//        transformer.transformXML(inputStream3, xsltFileName3, outputStream3, null, null);
//
//
//        File outputFile = new File(graphmlDir, "undirected-bgpPeeringMap.graphml");
//        FileUtils.writeStringToFile(outputFile, new String(outputStream3.toByteArray()));
//        logger.info("Output Graphml saved in a file in"+graphmlDir);
//
//
//        //FileUtils.writeStringToFile(nodesFileListFile, "bgpPeeringMap.graphml");
//        FileWriter writer = new FileWriter(new File(outputDir,"undirected"+".graphmls"),true);
//        writer.append("undirected-bgpPeeringMap.graphml").append("\n");
//        writer.close();
//        return null;
    }

    private void setSnmpManager(Map<String, String> snmpConnParams) {

        String version = snmpConnParams.get("version");
        String protocol = snmpConnParams.get("protocol");


        if ("3".equals(version) && "udp".equals(protocol)) {

        } else if ("3".equals(version) && "tcp".equals(protocol)) {

            snmpManager = new SnmpTcpV3Manager(mibLoaderHolder.getLoader());

        } else if ("2".equals(version) && "udp".equals(protocol)) {

            snmpManager = new SnmpUdpV2Manager(mibLoaderHolder.getLoader());


        } else if ("2c".equals(version) && "udp".equals(protocol)) {

            snmpManager = new SnmpUdpV2Manager(mibLoaderHolder.getLoader());


        } else if ("2".equals(version) && "tcp".equals(protocol)) {
            snmpManager = new SnmpTcpV2Manager(mibLoaderHolder.getLoader());


        } else if ("2c".equals(version) && "tcp".equals(protocol)) {
            snmpManager = new SnmpTcpV2Manager(mibLoaderHolder.getLoader());


        } else if ("1".equals(version) && "udp".equals(protocol)) {

            snmpManager = new SnmpTcpV1Manager(mibLoaderHolder.getLoader());


        } else if ("1".equals(version) && "tcp".equals(protocol)) {

            snmpManager = new SnmpTcpV1Manager(mibLoaderHolder.getLoader());


        } else {

            logger.info("Unsupported combination of protocol: " + protocol + " and version " + version);

        }
        try {
            snmpManager.init();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String snmpGetNext(Map<String, String> settings, String oidString) throws IOException {


        snmpManager.setParameters(settings);


        return snmpManager.snmpGetNext(oidString);



    }

    private byte[] snmpWalk(Map<String, String> settings) throws IOException, MibLoaderException {

        String[] params = queryParameters.split(",");


        snmpManager.setParameters(settings);


        String xml = snmpManager.snmpWalkToString(params);
        return xml.getBytes();
    }




    public String getQueryParameters() {
        return queryParameters;
    }

    public void setQueryParameters(String queryParameters) {
        this.queryParameters = queryParameters;
    }

    public String getXsltFileName1() {
        return xsltFileName1;
    }

    public void setXsltFileName1(String xsltFileName1) {
        this.xsltFileName1 = xsltFileName1;
    }

    public DiscoveryResourceManager getDiscoveryResource() {
        return discoveryResource;
    }

    public void setDiscoveryResource(DiscoveryResourceManager discoveryResource) {
        this.discoveryResource = discoveryResource;
    }

    public String getLabelDirName() {
        return labelDirName;
    }

    public void setLabelDirName(String labelDirName) {
        this.labelDirName = labelDirName;
    }


    public String getProjectPath() {
        return projectPath;
    }

    public void setProjectPath(String projectPath) {
        this.projectPath = projectPath;
    }

    public MibLoaderHolder getMibLoaderHolder() {
        return mibLoaderHolder;
    }

    public void setMibLoaderHolder(MibLoaderHolder mibLoaderHolder) {
        this.mibLoaderHolder = mibLoaderHolder;
    }

    public SnmpManager getSnmpManager() {
        return snmpManager;
    }

    public void setSnmpManager(SnmpManager snmpManager) {
        this.snmpManager = snmpManager;
    }

    public String getXsltFileName2() {
        return xsltFileName2;
    }

    public void setXsltFileName2(String xsltFileName2) {
        this.xsltFileName2 = xsltFileName2;
    }

    public String getXsltFileName3() {
        return xsltFileName3;
    }

    public void setXsltFileName3(String xsltFileName3) {
        this.xsltFileName3 = xsltFileName3;
    }

    public String getAsNumbers() {
        return asNumbers;
    }

    public void setAsNumbers(String asNumbers) {
        this.asNumbers = asNumbers;
    }

    public String getGraphmlUndirectedPath() {
        return graphmlUndirectedPath;
    }

    public void setGraphmlUndirectedPath(String graphmlUndirectedPath) {
        this.graphmlUndirectedPath = graphmlUndirectedPath;
    }

    public String getMibDir() {
        return mibDir;
    }

    public void setMibDir(String mibDir) {
        this.mibDir = mibDir;
    }

    public static void main(String[] args) {
        logger.debug("bgpPeeringMap v2. gearing up");

        Map<String, String> params = CmdLineParser.parseCmdLine(args);
        String projectPath = params.get("-p");

        if (projectPath == null) {
            File cwd = new File(".");
            System.out.println("Project path is not specified. Will use current dir: " + cwd.getAbsolutePath());
            projectPath = cwd.getAbsolutePath();
        }

        File workingDir = new File(projectPath);
        if (!workingDir.exists()) {
            System.out.println("Invalid project path!");
            return;
        }

        logger.debug("Loading beans!!");
        File conDetails = new File(projectPath, "iDiscover/conf/txt/connection-details.txt");

        FileSystemXmlApplicationContext applicationContext = null;
        try {
            applicationContext = initializeDiscoveryContext(projectPath);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        NetworkDiscoverer discoverer = applicationContext.getBean("bgpMapSnmpDiscoverer", ANetworkDiscoverer.class);
        LinkedHashMap<String, ConnectionDetails> connectionList = (LinkedHashMap) applicationContext.getBean("connectionList", conDetails);
        NetworkDiscoveryResult result = discoverer.discoverNetwork(new ArrayList<ConnectionDetails>(connectionList.values()));


    }

    public static FileSystemXmlApplicationContext initializeDiscoveryContext(String projectPath) throws MalformedURLException {


        File generic = new File(projectPath, "iDiscover/conf/xml/generic.xml");
        String genericContextPath = generic.toURI().toURL().toString();

        File snmpDiscovery = new File(projectPath, "iDiscover/conf/xml/bgpInternetMapSNMPDiscovery.xml");
        String snmpDiscoveryContextPath = snmpDiscovery.toURI().toURL().toString();

        File connectionsDetails = new File(projectPath, "iDiscover/conf/xml/connectionsDetails.xml");
        String connectionsDetailsContextPath = connectionsDetails.toURI().toURL().toString();

        DefaultListableBeanFactory beanFactory = new DefaultListableBeanFactory();
        BeanDefinition beanDefinition = BeanDefinitionBuilder.
                rootBeanDefinition(String.class)
                .addConstructorArgValue(projectPath).getBeanDefinition();

        File networkPath = new File(projectPath, ProjectConstants.networkDirName);


        String labelDirName;
        if (!networkPath.exists()) {
            networkPath.mkdir();
            labelDirName = ProjectConstants.labelDirName + "1";
            File labelDir = new File(networkPath, labelDirName);
            labelDir.mkdir();
        } else {
            AutoLabeler autoLabeler = new AutoLabeler(projectPath, ProjectConstants.networkDirName, ProjectConstants.labelDirName);
            labelDirName = autoLabeler.autolabel();
        }

        BeanDefinition beanDefinition2 = BeanDefinitionBuilder.
                rootBeanDefinition(String.class)
                .addConstructorArgValue(labelDirName).getBeanDefinition();

        beanFactory.registerBeanDefinition("projectPath", beanDefinition);

        beanFactory.registerBeanDefinition("labelDirName", beanDefinition2);


        BeanDefinition beanDefinition3 = BeanDefinitionBuilder.
                rootBeanDefinition(String.class)
                .addConstructorArgValue(ProjectConstants.undirectedGraphmlDirName).getBeanDefinition();


        beanFactory.registerBeanDefinition("graphmlUndirectedPath", beanDefinition3);


//        BeanDefinition beanDefinition4 = BeanDefinitionBuilder.
//                rootBeanDefinition(String.class)
//                .addConstructorArgValue(mibLoaderHolder).getBeanDefinition();
//
//        beanFactory.registerBeanDefinition("mibLoaderHolder", beanDefinition4);


        GenericApplicationContext cmdArgCxt = new GenericApplicationContext(beanFactory);
        // Must call refresh to initialize context
        cmdArgCxt.refresh();

        String[] paths = new String[]{genericContextPath, snmpDiscoveryContextPath, connectionsDetailsContextPath};
//        ,project.getAbsolutePath()+project.getAbsolutePath()+File.separator+"iDiscover/conf/xml/snmpNetworkDiscovery.xml", project.getAbsolutePath()+File.separator+"iDiscover/src/main/resources/connectionsDetails.xml"
        FileSystemXmlApplicationContext applicationContext = new FileSystemXmlApplicationContext(paths, cmdArgCxt);
//        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext(workingDir+File.separator+"iDiscover/conf/xml/generic.xml",workingDir+File.separator+"/iDiscover/conf/xml/snmpNetworkDiscovery.xml","connectionsDetails.xml");
        // NetworkDiscoverer discoverer = fileApplicationContext.getBean("bgpPeeringMapDiscovery", NetworkDiscoverer.class);
        //NetworkDiscoverer discoverer = fileApplicationContext.getBean("floodLightNodeDiscoverer", NetworkDiscoverer.class);
        return applicationContext;
    }


}
