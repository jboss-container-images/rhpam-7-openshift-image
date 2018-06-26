FROM scratch

LABEL   maintainer="rromerom@redhat.com" \
        name="Sybase JDBC Driver" \
        version="16.0_PL05"

ARG ARTIFACT_MVN_REPO

COPY install.sh sybase-driver-image/install.properties /extensions/
COPY sybase-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/com/sysbase/jconn4/16.0_PL05/jconn4-16.0_PL05.jar \
    /extensions/modules/system/layers/openshift/com/sybase/main/jconn4.jar