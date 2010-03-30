package uk.ac.ebi.arrayexpress.utils.persistence;

/*
 * Copyright 2009-2010 Functional Genomics Group, European Bioinformatics Institute
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

public class TextFilePersistence<Object extends Persistable>
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    // persistence file handle
    private File persistenceFile;

    // internal object holder
    private Object object;

    public TextFilePersistence( Object obj, File file )
    {
        // TODO: check object and file
        object = obj;
        persistenceFile = file;
    }

    public Object getObject() throws Exception
    {
        if (null != object) {
            if (object.isEmpty()) {
                loadObject();
            }
        }
        return object;
    }

    public void setObject( Object obj ) throws Exception
    {
        object = obj;
        save(object.toPersistence());
    }

    private void loadObject() throws Exception
    {
        object.fromPersistence(load());
    }

    private String load() throws Exception
    {
        logger.debug("Retrieving persistable object [{}] from [{}]", object.getClass().toString(), persistenceFile.getName());

        StringBuilder result = new StringBuilder();
        if (persistenceFile.exists()) {
            BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream(persistenceFile)));
            while ( r.ready() ) {
                String str = r.readLine();
                // null means stream has reached the end
                if (null != str) {
                    result.append(str).append(Object.EOL);
                } else {
                    break;
                }
            }
            logger.debug("Object successfully retrieved");
        } else {
            logger.warn("Persistence file [{}] not found", persistenceFile.getAbsolutePath());
        }

        return result.toString();
    }

    private void save( String objectString ) throws Exception
    {
        logger.debug("Saving persistable object [{}] to [{}]", object.getClass().toString(), persistenceFile.getName());
        BufferedWriter w = new BufferedWriter(new FileWriter(persistenceFile));
        w.write(objectString);
        w.close();
        logger.debug("Object successfully saved");
    }
}
