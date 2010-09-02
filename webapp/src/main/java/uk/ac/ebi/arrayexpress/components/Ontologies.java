package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpandedHighlighter;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpansionLookupIndex;
import uk.ac.ebi.arrayexpress.utils.search.EFOQueryExpander;
import uk.ac.ebi.microarray.ontology.efo.EFONode;
import uk.ac.ebi.microarray.ontology.efo.EFOOntologyHelper;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;


public class Ontologies extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private EFOOntologyHelper ontology;

    private Map<String, Integer> expCountByEfoId;

    private final String EFO_NOT_LOADED_YET = "";

    private Experiments experiments;
    private SearchEngine search;
    private Autocompletion autocompletion;

    public Ontologies()
    {
        super("Ontologies");
    }

    public void initialize() throws Exception
    {
        experiments = (Experiments) getComponent("Experiments");
        search = (SearchEngine) getComponent("SearchEngine");
        autocompletion = (Autocompletion) getComponent("Autocompletion");

        this.expCountByEfoId = new HashMap<String, Integer>();
        ((JobsController)getComponent("JobsController")).executeJob("reload-ontology");
    }

    public void terminate() throws Exception
    {
    }

    public void setOntology( EFOOntologyHelper efoOntology ) throws IOException
    {
        this.ontology = efoOntology;

        autocompletion.rebuild();


        EFOExpansionLookupIndex ix = new EFOExpansionLookupIndex(
                getPreferences().getString("ae.efo.index.location")
        );

        ix.setOntology(getOntology());

        Controller c = search.getController();
        c.setQueryExpander(new EFOQueryExpander(ix));
        c.setQueryHighlighter(new EFOExpandedHighlighter());
    }

    public EFOOntologyHelper getOntology()
    {
        return this.ontology;
    }

    public String getEfoChildren( String efoId )
    {
        StringBuilder sb = new StringBuilder();

        if (null != getOntology()) {
            EFONode node = getOntology().getEfoMap().get(efoId);
            if (null != node) {
                Set<EFONode> children = node.getChildren();
                if (null != children) {
                    for (EFONode child : children) {
                        sb.append(child.getTerm()).append("|o|");
                        if (child.hasChildren()) {
                            sb.append(child.getId());
                        }
                        sb.append("\n");
                    }
                }
            }
        }
        return sb.toString();
    }
}
