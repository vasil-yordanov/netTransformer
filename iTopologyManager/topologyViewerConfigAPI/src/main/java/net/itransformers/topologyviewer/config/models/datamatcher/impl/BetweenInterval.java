/*
 * BetweenInterval.java
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

package net.itransformers.topologyviewer.config.models.datamatcher.impl;/*
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

import net.itransformers.topologyviewer.config.models.datamatcher.DataMatcher;
import org.apache.log4j.Logger;

public class BetweenInterval implements DataMatcher{
    static Logger logger = Logger.getLogger(BetweenInterval.class);
    @Override
    public boolean compareData(String data1, String data2) {
        try {
            String[] limits = data2.split(",");
            if (limits.length != 2){
                logger.error("Unable to parse input limits: "+data2);
                return false;
            }
            Long i11 = Long.parseLong(limits[0]);
            Long i12 = Long.parseLong(limits[1]);
            Long i2 = Long.parseLong(data1);
            logger.debug("between: "+i11+":"+i2+":"+i12);

            return (i2 > i11 && i2 < i12);
        }catch (RuntimeException rte) {
            logger.error("Unable to compare " + data1 + " and " + data2 +". Reason: "+rte.getMessage(),rte);
            return false;
        }
    }
}
