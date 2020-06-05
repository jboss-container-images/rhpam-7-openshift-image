#!/bin/bash

SOURCES_DIR="/tmp/artifacts"
SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
TARGET_DIR=/extensions

MODULE_DIR=${TARGET_DIR}/modules/${DRIVER_DIR}

mkdir -p ${MODULE_DIR}

cp ${ADDED_DIR}/{install.sh,install.properties}  ${TARGET_DIR}

# create the module
cp -rv ${SOURCES_DIR}/${JDBC_ARTIFACT} ${MODULE_DIR}
cp ${ADDED_DIR}/module.xml ${MODULE_DIR}/module.xml

# Necessary to permit running with a randomised UID
chmod -R g+rwX ${TARGET_DIR}