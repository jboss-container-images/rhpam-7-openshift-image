package org.kie.server.demo;

import org.kie.server.router.spi.RestrictionPolicy;

import io.undertow.server.HttpServerExchange;

/**
 * @author mswiderski
 * https://github.com/mswiderski/jbpm-examples
 */
public class ByPassUserNotAllowedRestrictionPolicy implements RestrictionPolicy {

    public boolean restrictedEndpoint(HttpServerExchange exchange, String containerId) {
        if (exchange.getQueryParameters().containsKey("user")) {
            return true;
        }
        return false;
    }

    @Override
    public String toString() {
        return "ByPassUserNotAllowedRestrictionPolicy";
    }

}
