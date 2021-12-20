echo "******  RUNNING ADDITIONAL CONFIGURATIONS WITH JBOSS-CLI - ADDING EXTRA ELYTRON USERS TO KIE FS REALM **********"
echo "trying to execute /opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli"
/opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli
 echo "END - users added"
