package org.kie.server.demo;

import java.lang.invoke.MethodHandles;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.kie.server.router.ContainerInfo;
import org.kie.server.router.spi.ContainerResolver;

import io.undertow.server.HttpServerExchange;

/**
 * @author mswiderski
 * https://github.com/mswiderski/jbpm-examples
 */
public class LatestVersionContainerResolver implements ContainerResolver {

    private Logger log = Logger.getLogger(MethodHandles.lookup().lookupClass().getName());
    private Pattern p = Pattern.compile(".*/containers/([^/]+).*");

    @Override
    public String toString() {
        return "LatestVersionContainerResolver";
    }

    @Override
    public String resolveContainerId(HttpServerExchange exchange, Map<String, List<ContainerInfo>> containerInfoPerContainer) {
        String relativePath = exchange.getRelativePath();
        Matcher matcher = p.matcher(relativePath);
        log.info("Custom container resolver :: Resolving for url " + relativePath);
        if (matcher.find()) {
            String containerId = matcher.group(1);
            log.info("Custom container resolver :: Container id from URL " + containerId);
            List<ContainerInfo> containers = containerInfoPerContainer.get(containerId);
            if (containers != null && !containers.isEmpty()) {

                Optional<ContainerInfo> selected = containers.stream().sorted(new Comparator<ContainerInfo>() {

                    public int compare(ContainerInfo o1, ContainerInfo o2) {
                        String releaseId1 = o1.getReleaseId();
                        String releaseId2 = o2.getReleaseId();

                        String version1 = releaseId1.split(":")[2];
                        String version2 = releaseId2.split(":")[2];

                        Double v1 = Double.parseDouble(version1);
                        Double v2 = Double.parseDouble(version2);
                        return v1.compareTo(v2);
                    }
                }).findFirst();

                if (selected.isPresent()) {
                    String actualContainerId = selected.get().getContainerId();
                    log.info("Custom container resolver :: Selected container id " + actualContainerId);
                    return actualContainerId;
                }
            }
        }
        log.info("Custom container resolver :: No container resolved for url " + relativePath);
        return ContainerResolver.NOT_FOUND;
    }
}
