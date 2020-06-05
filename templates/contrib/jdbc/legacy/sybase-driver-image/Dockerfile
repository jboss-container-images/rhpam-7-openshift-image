FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="Sybase JDBC Driver" \
        version="16.0_PL05"

ARG ARTIFACT_MVN_REPO

COPY install.sh sybase-driver-image/install.properties /extensions/
COPY sybase-driver-image/modules /extensions/modules/

# copy local jar to driver module
# remember to have the ojdbc.jar file on the  oracle-driver-image directory before building the image
COPY sybase-driver-image/jconn4-16.0_PL05.jar /extensions/modules/system/layers/openshift/com/sybase/main/jconn4.jar