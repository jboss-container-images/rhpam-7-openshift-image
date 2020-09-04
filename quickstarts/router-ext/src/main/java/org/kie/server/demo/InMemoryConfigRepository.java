package org.kie.server.demo;

import org.kie.server.router.Configuration;
import org.kie.server.router.spi.ConfigRepository;

/**
 * @author mswiderski
 * https://github.com/mswiderski/jbpm-examples
 */
public class InMemoryConfigRepository implements ConfigRepository {

    private Configuration configuration = new Configuration();
    
    public void persist(Configuration configuration) {
        this.configuration = configuration;

    }

    public Configuration load() {
        return configuration;
    }

    public void clean() {
        configuration = new Configuration();
    }

    @Override
    public String toString() {
        return "InMemoryConfigRepository";
    }

}
