.PHONY: build
db2:
	sh prepare.sh db2 ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml docker
	cekit --verbose test --overrides-file db-overrides.yaml behave

mariadb:
	sh prepare.sh mariadb
	cekit --verbose build --overrides-file db-overrides.yaml docker --tag=quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0
	cekit --verbose test --overrides-file db-overrides.yaml behave

mssql:
	sh prepare.sh mssql
	cekit --verbose build --overrides-file db-overrides.yaml docker
	cekit --verbose test --overrides-file db-overrides.yaml behave

mysql:
	sh prepare.sh mysql
	cekit --verbose build --overrides-file db-overrides.yaml docker --tag=quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12
	cekit --verbose test --overrides-file db-overrides.yaml behave

oracle:
	sh prepare.sh oracle ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml docker
	cekit --verbose test --overrides-file db-overrides.yaml behave

sybase:
	sh prepare.sh sybase ${artifact} ${version}
	cekit --verbose build --overrides-file db-overrides.yaml docker
	cekit --verbose test --overrides-file db-overrides.yaml behave

postgresql:
	sh prepare.sh postgresql
	cekit --verbose build --overrides-file db-overrides.yaml docker --tag=quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5
	cekit --verbose test --overrides-file db-overrides.yaml behave


# build and push to a postgresql, mysql and mariadb and extension images to quay.io
# permissions are required.
push-0: postgresql
	docker push quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5

push-1: push-0 mysql
	docker push quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12

push: push-0 push-1 mariadb
	docker push quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0
