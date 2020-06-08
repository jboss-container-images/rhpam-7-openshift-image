BUILD_ENGINE ?= docker

.PHONY: build
db2:
	sh prepare.sh db2 ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave

mariadb:
	sh prepare.sh mariadb
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave
	${BUILD_ENGINE} tag kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0 quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0

mssql:
	sh prepare.sh mssql
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave

mysql:
	sh prepare.sh mysql
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave
	${BUILD_ENGINE} tag kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12 quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12

oracle:
	sh prepare.sh oracle ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave

sybase:
	cp tests/features/sybase-feature.prepare tests/features/sybase.feature
	sh prepare.sh sybase ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave
	rm -rfv tests/features/sybase.feature

postgresql:
	sh prepare.sh postgresql
	cekit --verbose build --overrides-file db-overrides.yaml ${BUILD_ENGINE}
	cekit --verbose test --overrides-file db-overrides.yaml behave
	${BUILD_ENGINE} tag kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5 quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5

# build and push to a postgresql, mysql and mariadb and extension images to quay.io
# permissions are required.
push-0: postgresql
	${BUILD_ENGINE} push quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5

push-1: push-0 mysql
	${BUILD_ENGINE} push quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12

push: push-0 push-1 mariadb
	${BUILD_ENGINE} push quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0
