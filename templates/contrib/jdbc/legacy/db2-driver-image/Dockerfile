FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="IBM DB2 JDBC Driver" \
        version="11.1.4.4"

ARG ARTIFACT_MVN_REPO

COPY install.sh db2-driver-image/install.properties /extensions/
COPY db2-driver-image/modules /extensions/modules/

# copy local jar to driver module
# remember to have the ojdbc.jar file on the  oracle-driver-image directory before building the image
COPY db2-driver-image/jcc-11.1.4.4.jar /extensions/modules/system/layers/openshift/com/ibm/main/jcc-11.1.4.4.jar