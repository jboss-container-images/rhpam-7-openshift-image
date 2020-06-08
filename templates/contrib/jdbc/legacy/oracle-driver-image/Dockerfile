FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="Oracle JDBC Driver" \
        version="12.1.0.1"

# Provide the right value during build
ARG ARTIFACT_MVN_REPO

COPY install.sh oracle-driver-image/install.properties /extensions/
COPY oracle-driver-image/modules /extensions/modules/

# copy local jar to driver module
# remember to have the ojdbc.jar file on the  oracle-driver-image directory before building the image
COPY oracle-driver-image/ojdbc7.jar /extensions/modules/system/layers/openshift/com/oracle/main/ojdbc7.jar