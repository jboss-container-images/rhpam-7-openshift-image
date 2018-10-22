.PHONY: build
db2:
	sh prepare.sh db2 ${artifact} ${version}
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

mariadb:
	sh prepare.sh mariadb
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

mssql:
	sh prepare.sh mssql
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

mysql:
	sh prepare.sh mysql
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

oracle:
	sh prepare.sh oracle ${artifact} ${version}
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

sybase:
	sh prepare.sh sybase ${artifact} ${version}
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml

postgresql:
	sh prepare.sh postgresql
	cekit build -v --overrides-file db-overrides.yaml
	cekit test -v --overrides-file db-overrides.yaml


# build and push to a postgresql, mysql and mariadb and extension images to quay.io
# permissions are required.
push-0: postgresql
	docker-squash kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5 --tag=quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5
	docker push quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5

push-1: push-0 mysql
	docker-squash kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12 --tag=quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12
	docker push quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12

push: push-0 push-1 mariadb
	docker-squash kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0 --tag=quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0
	docker push quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.4.0
