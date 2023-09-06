#!/usr/bin/env bash
# ############
# This script will check  the version of the COMPONENT.WAR/META-INF/MANIFEST.mf file by comparing the
# value of the "Implementation-Version" field which would match with the KIE_VERSION from the build properties
# file for some components.
#
# This script can be used to check the version the following Components:
#   - Dashbuilder
#   - KIE Server
#   - Controller
#   - Business Central Monitoring
#   - Business Central
#   - Smartrouter
#   - Process Instance Migration
#
# For Smartrouter, it is needed to extract the rhpam-7.13.x-smart-router.jar file to read this information
# from META-INF.
#
# For Business Central, the version is retrieved from META-INF/build.metadata
#
# For Process Instance Migration, the process is the same, but retrieving the information from the quarkus-run.jar
#
# ############
# Usage:
# bash check-image-version.sh $COMPONENT_IMAGE $KIE_VERSION
# e.g.:
#     bash check-image-version.sh rhpam-dashbuilder-rhel8 7.67.0.Final-redhat-00005
#
# There is a need to have the PROD_VERSION environment variable set as well, it is needed to correctly unzip the
# Smart Router component. On CI it is set, e.g. to 7.13.4, for local tests this needs to be set as well.
# The PROD_VERSION is also needed to correctly build the Container Image's name to query the version information.
#
# Exit codes:
# - 0: version matches
# - 10: version does not match
# - 5: missing inputs
# - 1: component not supported by this script
# ############

CONTAINER_ENGINE=${ENGINE:-podman}

# $1 - component image name
# $2 - KIE Version to compare with
check_version() {
    local component="${1}"
    local kie_version="${2}"

    if [ -z "${component}" ] || [ -z "${kie_version}" ]; then
        echo "Component or KIE Version is empty."
        exit 5
    fi

    case ${component} in
        rhpam-dashbuilder-rhel8|rhpam-kieserver-rhel8|rhpam-controller-rhel8|rhpam-businesscentral-monitoring-rhel8)
            result=$(${CONTAINER_ENGINE} run -it rhpam-7/${component}:${PROD_VERSION} cat /deployments/ROOT.war/META-INF/MANIFEST.MF | grep "Implementation-Version" | cut -d: -f2 | tr -d '[:space:]')
            test_version "${result}" "${component}" "${kie_version}"
            ;;
        rhpam-smartrouter-rhel8)
            result=$(${CONTAINER_ENGINE} run -it rhpam-7/${component}:${PROD_VERSION} sh -c 'jar xf /opt/rhpam-smartrouter/rhpam-'"${PROD_VERSION}"'-smart-router.jar && cat META-INF/MANIFEST.MF' | grep "Implementation-Version" | cut -d: -f2 | tr -d '[:space:]')
            test_version "${result}" "${component}" "${kie_version}"
            ;;
        rhpam-businesscentral-rhel8)
            result=$(${CONTAINER_ENGINE} run -it rhpam-7/${component}:${PROD_VERSION} cat /deployments/ROOT.war/META-INF/build.metadata | grep "build.version=" | cut -d= -f2 | tr -d '[:space:]')
            test_version "${result}" "${component}" "${kie_version}"
            ;;
        rhpam-process-migration-rhel8)
            result=$(${CONTAINER_ENGINE} run -it rhpam-7/${component}:${PROD_VERSION} sh -c 'jar xf /opt/rhpam-process-migration/quarkus-app/quarkus-run.jar && cat META-INF/MANIFEST.MF' | grep "Implementation-Version" | cut -d: -f2 | tr -d '[:space:]')
            test_version "${result}" "${component}" "${kie_version}"
            ;;
        *)
            echo "The component ${component} is not supported by this script."
            exit 1
            ;;
    esac
}

test_version() {
    test "${1}" = "${3}" && echo "Version of ${2} matches - ${1}." || echo "Version of ${2} does not match - ${1}, expected ${3}."; exit 10
}

# $1 - component image name
# $2 - KIE Version to compare with
check_version "$1" "$2"

