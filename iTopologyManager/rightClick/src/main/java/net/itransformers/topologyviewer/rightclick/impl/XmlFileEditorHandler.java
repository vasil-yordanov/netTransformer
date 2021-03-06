/*
 * XmlFileEditorHandler.java
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

package net.itransformers.topologyviewer.rightclick.impl;

import net.itransformers.topologyviewer.gui.TopologyManagerFrame;
import net.itransformers.topologyviewer.rightclick.RightClickHandler;
import net.itransformers.utils.JEditorPane;
import net.itransformers.utils.ProjectConstants;

import javax.swing.*;
import javax.swing.text.BadLocationException;
import java.io.File;
import java.io.IOException;
import java.util.Map;

public class XmlFileEditorHandler implements RightClickHandler {
     public <G> void handleRightClick(JFrame parent, String v,
                                     Map<String, String> graphMLParams,
                                     Map<String, String> rightClickParams,
                                     File projectPath,
                                     File versionDir) throws Exception {

//      JOptionPane.showMessageDialog(parent, "versionDir: " + versionDir );

        // JEditorPane settingsEditor = new JEditorPane(versionDir.getAbsolutePath());
         TopologyManagerFrame frame = (TopologyManagerFrame) parent;
         JEditorPane editor = null;
         String path =  rightClickParams.get("path");

         if(rightClickParams.get("type").equals("deviceXml")){
             String deviceXmlPath = versionDir.getAbsolutePath() + File.separator + path + File.separator + ProjectConstants.deviceDataPrefix + v + ".xml";
             String deviceXmlDir =  versionDir+File.separator+path;
             editor = new net.itransformers.utils.JEditorPane(deviceXmlPath,deviceXmlDir,".xml");
         }else if(rightClickParams.get("type").equals("graphml")){
             String graphmlPath = versionDir+File.separator+path+File.separator+"node-"+v+".graphml";
             String graphmlDir =  versionDir + File.separator+path;
             editor = new JEditorPane(graphmlPath,graphmlDir,".graphml");

         } else if(rightClickParams.get("type").equals("raw-data")) {
             String rawDataPath = versionDir+File.separator+path+File.separator+v+".xml";
             String rawDatalDir =  versionDir + File.separator+path;

             editor = new JEditorPane(rawDataPath,rawDatalDir,".xml");

         }else {
             String config = versionDir+File.separator+path+File.separator+v+File.separator+rightClickParams.get("type")+".txt";
             String configdir =  versionDir + File.separator+path+File.separator+v;
             editor = new JEditorPane(config,configdir,".txt");

         }
         try {
             editor.init();
         } catch (IOException e1) {
             e1.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
         } catch (BadLocationException e1) {
             e1.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
         }

     }
}
