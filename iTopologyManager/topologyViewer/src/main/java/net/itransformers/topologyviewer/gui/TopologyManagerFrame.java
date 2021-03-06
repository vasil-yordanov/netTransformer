/*
 * TopologyManagerFrame.java
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

package net.itransformers.topologyviewer.gui;

import net.itransformers.topologyviewer.config.TopologyViewerConfigManager;
import net.itransformers.topologyviewer.config.TopologyViewerConfigManagerFactory;
import net.itransformers.topologyviewer.menu.MenuBuilder;
import net.itransformers.utils.ProjectConstants;
import net.itransformers.utils.graphmledgedefaultresolver.GraphmlEdgeDefaultResolver;
import org.apache.log4j.Logger;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;


public class TopologyManagerFrame extends JFrame{
    static Logger logger = Logger.getLogger(TopologyManagerFrame.class);
    public static final String VIEWER_PREFERENCES_PROPERTIES = "viewer-preferences.properties";
    private File path;
    private String projectType;
    private TopologyViewerConfigManager viewerConfig;
    private JTabbedPane tabbedPane;
    private Properties preferences = new Properties();
    Map<String, GraphViewerPanelManager> viewerPanelManagerMap = new HashMap<String, GraphViewerPanelManager>();
    private GraphViewerPanelManagerFactory graphViewerPanelManagerFactory;
    private MenuBuilder menuBuilder;
    TopologyViewerConfigManagerFactory topologyViewerConfigManagerFactory;

    public TopologyManagerFrame(String name,
                                GraphViewerPanelManagerFactory graphViewerPanelManagerFactory,
                                MenuBuilder menuBuilder,
                                TopologyViewerConfigManagerFactory topologyViewerConfigManagerFactory) {
        super(name);
        this.graphViewerPanelManagerFactory = graphViewerPanelManagerFactory;
        this.menuBuilder = menuBuilder;
        this.topologyViewerConfigManagerFactory = topologyViewerConfigManagerFactory;
        this.menuBuilder.setFrame(this);
    }

    public void init() throws IOException {
        this.init(null);
    }
    public void init(File path) throws IOException {
        //super.setIconImage(Toolkit.getDefaultToolkit().getImage("images/logo3.png"));

        this.path = path;
        File prefsFile = new File(VIEWER_PREFERENCES_PROPERTIES);
        preferences.load(new FileInputStream(prefsFile));

        createFrame();
       // String projectPath = preferences.getProperty("PATH");
        String graphmlPath = preferences.getProperty("GRAPHML_REL_DIR");

        if (graphmlPath!=null) {
           // File projectPathFile = new File(projectPath);
            this.doOpenProject(path);

            File graphmlPathFile = new File(graphmlPath);
            if (graphmlPathFile.exists()) {
                this.doOpenGraph(graphmlPathFile);
            }

        }
    }

    public File getPath() {
        return path;
    }

    public void setPath(File path) {
        this.path = path;
    }

    public void setProjectType(String projectType) {
        this.projectType = projectType;
    }
    public String getProjectType() {
        return projectType;
    }

    private void createFrame(){
        tabbedPane = new JTabbedPane();
        this.setExtendedState(Frame.MAXIMIZED_BOTH);
        try {
            this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        } catch (java.security.AccessControlException e){
            e.printStackTrace();
        }
        final Container content = this.getContentPane();

        JMenuBar menuBar = menuBuilder.createMenuBar(this);

        content.add(tabbedPane);

        this.setJMenuBar(menuBar);
        this.setMinimumSize(new Dimension(640, 480));
        this.setVisible(true);
        this.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    }


    public JTabbedPane getTabbedPane() {
        return tabbedPane;
    }

    public Properties getPreferences() {
        return preferences;
    }

    public void doOpenGraph(File selectedFile) {

        this.getPreferences().setProperty(PreferencesKeys.GRAPHML_REL_DIR.name(), selectedFile.getAbsolutePath());

        try {
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");
        } catch (IOException e) {
            e.printStackTrace();
        }


        try {
            GraphmlEdgeDefaultResolver graphTypeResolver = new GraphmlEdgeDefaultResolver();
            String graphType = graphTypeResolver.resolveEdgeDefault(selectedFile);
            GraphViewerPanelManager viewerPanelManager =
                    graphViewerPanelManagerFactory.createGraphViewerPanelManager(
                            this,
                            graphType,
                            projectType,
                            viewerConfig,
                            selectedFile,
                            path,
                            tabbedPane);
            viewerPanelManager.init();
            viewerPanelManagerMap.put(viewerPanelManager.getVersionDir().getAbsolutePath(),viewerPanelManager);
            viewerPanelManager.createAndAddViewerPanel();

        }
         catch (Exception e){
            e.printStackTrace();
            JOptionPane.showMessageDialog(this,"Error creating graph: "+e.getMessage());
        }
    }
    public void doCloseGraph() {

        GraphViewerPanel viewerPanel = (GraphViewerPanel)getTabbedPane().getSelectedComponent();
        if (viewerPanel == null){
            return;
        }

        this.getPreferences().remove(PreferencesKeys.GRAPHML_REL_DIR.name());

        try {
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");
        } catch (IOException e) {
            e.printStackTrace();
        }


        String absolutePath = viewerPanel.getVersionDir().getAbsolutePath();
        viewerPanelManagerMap.remove(absolutePath);
        JTabbedPane tabbedPane = this.getTabbedPane();
        int count = tabbedPane.getTabCount() ;
        for (int j = count-1 ; j >= 0 ; j--) {
            GraphViewerPanel currentViewerPanel = (GraphViewerPanel) tabbedPane.getComponent(j);
            if (currentViewerPanel.getVersionDir().getAbsolutePath().equals(absolutePath)) tabbedPane.remove(j) ;
        }

    }

    public void doOpenProject(File projectPath) {

        String projectDir =  projectPath.getAbsolutePath();

        this.setPath(new File(projectDir));

        if (new File (projectPath,ProjectConstants.freeGraphProjectType+".pfl").exists()) {
            this.setProjectType(ProjectConstants.freeGraphProjectType);

          //  this.setName("Free Graph");
            this.setViewerConfig(ProjectConstants.freeGraphProjectType);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(4).setEnabled(true);

        } else if (new File (projectPath,ProjectConstants.bgpDiscovererProjectType+".pfl").exists()) {
            this.setProjectType(ProjectConstants.bgpDiscovererProjectType);
            this.setViewerConfig(ProjectConstants.bgpDiscovererProjectType);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);

            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(true);

        } else if (new File (projectPath,ProjectConstants.snmpProjectType + ".pfl").exists()) {
            this.setProjectType(ProjectConstants.snmpProjectType);
            this.setViewerConfig(ProjectConstants.snmpProjectType);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);

            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(true);

        } else {
            JOptionPane.showMessageDialog(this, "Unknown project type");
            return;

        }
        this.setTitle(ProjectConstants.getProjectName(this.getProjectType())+" "+projectDir);
        this.getRootPane().getJMenuBar().getMenu(1).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(2).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(3).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(4).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(5).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(6).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(7).setEnabled(true);

        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(4).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(5).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(6).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(7).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(8).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(9).setEnabled(true);

        this.getPreferences().setProperty(PreferencesKeys.PATH.name(), projectDir);


        try {
            this.getPreferences().remove(PreferencesKeys.GRAPHML_REL_DIR.name());
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");


        } catch (IOException e1) {
            e1.printStackTrace();
            JOptionPane.showMessageDialog(this, "Can not Store preferences: " + e1.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    public void doCloseProject() {

        setPath(null);
        getTabbedPane().removeAll();
        viewerPanelManagerMap.clear();
        setProjectType("");

        //Disable all main menus except the File and Help
        this.getRootPane().getJMenuBar().getMenu(1).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(2).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(3).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(4).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(5).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(6).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(7).setEnabled(false);

        //Disable most of the components of  File menu (all except the Open Project)

        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(4).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(5).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(6).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(7).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(8).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(9).setEnabled(false);


        // frame.getRootPane().getJMenuBar().getMenu(4).setEnabled(false);
        //Disable iDiscover menu options
        this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(false);
       this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(false);
        //Disable Discoverers settings options

        this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(4).setEnabled(false);


        this.getPreferences().remove(PreferencesKeys.PATH.name());


        try {
            this.getPreferences().remove(PreferencesKeys.GRAPHML_REL_DIR.name());
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");


        } catch (IOException e1) {
            e1.printStackTrace();
            JOptionPane.showMessageDialog(this, "Can not Store preferences: " + e1.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }



    }

    public GraphViewerPanelManager getCurrentGraphViewerManager(){
        GraphViewerPanel viewerPanel = (GraphViewerPanel)getTabbedPane().getSelectedComponent();
        if (viewerPanel != null){
            return viewerPanelManagerMap.get(viewerPanel.getVersionDir().getAbsolutePath());
        } else {
            return null;
        }
    }

    public void setViewerConfig(String viewerConfig) {
        Map<String, String> props = new HashMap<>();
        props.put("projectPath",path.getAbsolutePath());
        props.put("projectType",viewerConfig);
        this.viewerConfig = topologyViewerConfigManagerFactory.createTopologyViewerConfigManager("xml",props);
    }
}

