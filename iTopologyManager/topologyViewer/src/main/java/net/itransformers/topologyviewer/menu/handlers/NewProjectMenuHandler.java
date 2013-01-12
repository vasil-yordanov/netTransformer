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

package net.itransformers.topologyviewer.menu.handlers;

import net.itransformers.topologyviewer.dialogs.NewProjectDialog;
import net.itransformers.topologyviewer.gui.TopologyViewer;
import net.itransformers.utils.RecursiveCopy;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;

/**
 * Created by IntelliJ IDEA.
 * Date: 12-4-27
 * Time: 23:30
 * To change this template use File | Settings | File Templates.
 */
public class NewProjectMenuHandler implements ActionListener {

    private TopologyViewer frame;

    public NewProjectMenuHandler(TopologyViewer frame) throws HeadlessException {

        this.frame = frame;
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        NewProjectDialog dialog = new NewProjectDialog(frame);
        dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        dialog.setVisible(true);
        File iDiscoverDir = new File("iDiscover"); // relative to the working dir
        try {
            RecursiveCopy.copyDir(iDiscoverDir, dialog.getProjectDir());
        } catch (IOException e1) {
            JOptionPane.showMessageDialog(frame,"Unable to create project the reason is:"+e1.getMessage());
            e1.printStackTrace();
        }
        File iTopologyManagerDir = new File("iTopologyManager"); // relative to the working dir
        try {
            RecursiveCopy.copyDir(iTopologyManagerDir, dialog.getProjectDir());
        } catch (IOException e1) {
            JOptionPane.showMessageDialog(frame,"Unable to create project the reason is:"+e1.getMessage());
            e1.printStackTrace();
        }
    }

}