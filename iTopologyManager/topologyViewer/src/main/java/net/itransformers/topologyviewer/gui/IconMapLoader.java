/*
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

package net.itransformers.topologyviewer.gui;

import net.itransformers.topologyviewer.config.IconType;
import net.itransformers.topologyviewer.config.TopologyViewerConfType;
import edu.uci.ics.jung.graph.Graph;
import edu.uci.ics.jung.io.GraphMLMetadata;
import edu.uci.ics.jung.visualization.LayeredIcon;
import org.apache.log4j.Logger;

import javax.swing.*;
import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * Date: 11-11-8
 * Time: 11:27
 * To change this template use File | Settings | File Templates.
 */
public class IconMapLoader implements GraphmlLoaderListener{
    static Logger logger = Logger.getLogger(IconMapLoader.class);

    private Map<String, Icon> iconMap = new HashMap<String, Icon>();
    private TopologyViewerConfType viewerConfig;

    public IconMapLoader(TopologyViewerConfType viewerConfig) {
        this.viewerConfig = viewerConfig;
    }

    public Map<String, Icon> getIconMap() {
        return iconMap;
    }

    private void updateIconsMap(String fileName, final Map<String, GraphMLMetadata<String>> vertexMetadata, final Collection<String> graphVertices) {
//        final Collection<String> graphVertices = graph.getVertices();
        String[] vertices = graphVertices.toArray(new String[graphVertices.size()]);
        List<IconType> iconTypeList = viewerConfig.getIcon();
        List<IconType.Data> datas;
        for (String vertice : vertices) {
            for (IconType iconType : iconTypeList) {
                boolean match = true;
                datas = iconType.getData();
                boolean isDefaultIcon = datas.isEmpty();
                for (IconType.Data data : datas) {
                    final GraphMLMetadata<String> stringGraphMLMetadata = vertexMetadata.get(data.getKey());
                    if (stringGraphMLMetadata == null){
                        logger.error(String.format("Can not find vertex metadata key '%s' in file '%s'.",data.getKey(), fileName));
                        continue;
//                        throw new RuntimeException(String.format("Can not find vertex metadata key '%s' in file '%s'.",data.getKey(), fileName));
                    }
                    final String value = stringGraphMLMetadata.transformer.transform(vertice);
                    if (value == null || !value.equals(data.getValue())) {
                        match = false;
                        break;
                    }
                }
                boolean iconExists = iconMap.containsKey(vertice);
                if ((!isDefaultIcon && match) || (isDefaultIcon && !iconExists)) {
                    final String name = iconType.getName();
                    String[] iconNames = name.split(",");
                    logger.debug("Load icon: "+iconNames[0].trim());
                    final URL resource = TopologyViewer.class.getResource(iconNames[0].trim());
                    if (resource == null) {
                        logger.error("Can not load icon: "+iconNames[0].trim());
                        continue;
                    }
                    final ImageIcon imageIcon = new ImageIcon(resource);
                    LayeredIcon iconImg = new LayeredIcon(imageIcon.getImage());
                    for (int i=1;i<iconNames.length;i++) {
                        final URL resource1 = TopologyViewer.class.getResource(iconNames[i].trim());
                        logger.debug("Load icon: "+iconNames[i].trim());
                        iconImg.add(new ImageIcon(resource1));
                    }
                    iconMap.put(vertice, iconImg);
                    break;
                }
            }
        }
    }

    @Override
    public <G extends Graph<String,String>> void graphmlLoaded(String fileName, Map<String, GraphMLMetadata<String>> vertexMetadata, Map<String, GraphMLMetadata<String>> edgeMetadata, G graph) {
        updateIconsMap(fileName, vertexMetadata, graph.getVertices());
    }
}