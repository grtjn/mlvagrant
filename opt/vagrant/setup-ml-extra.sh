#!/bin/bash
echo "running $0 $@"

################################################################
# Use this script to initialize and add one or more hosts to a
# MarkLogic Server cluster. The first (bootstrap) host for the
# cluster should already be fully initialized.
#
# Use the options to control admin username and password, 
# authentication mode, and the security realm. At least two hostnames
# must be given: A host already in the cluster, and at least one host
# to be added to the cluster. Only minimal error checking is performed, 
# so this script is not suitable for production use.
#
# Usage:  this_command [options] cluster-host joining-host(s)
#
################################################################
USER="admin"
PASS="admin"
AUTH_MODE="anyauth"
VERSION="7"
N_RETRY=5
RETRY_INTERVAL=10
SKIP=0

#######################################################
# restart_check(hostname, baseline_timestamp, caller_lineno)
#
# Use the timestamp service to detect a server restart, given a
# a baseline timestamp. Use N_RETRY and RETRY_INTERVAL to tune
# the test length. Include authentication in the curl command
# so the function works whether or not security is initialized.
#   $1 :  The hostname to test against
#   $2 :  The baseline timestamp
#   $3 :  Invokers LINENO, for improved error reporting
# Returns 0 if restart is detected, exits with an error if not.
#
function restart_check {
  LAST_START=`$AUTH_CURL "http://$1:8001/admin/v1/timestamp"`
  for i in `seq 1 ${N_RETRY}`; do
    echo "restart check for $1..."
    if [ "$2" == "$LAST_START" ] || [ "$LAST_START" == "" ]; then
      sleep ${RETRY_INTERVAL}
      LAST_START=`$AUTH_CURL "http://$1:8001/admin/v1/timestamp"`
    else 
      return 0
    fi
  done
  echo "ERROR: Line $3: Failed to restart $1"
  exit 1
}


#######################################################
# Parse the command line

OPTIND=1
while getopts ":a:p:u:v:" opt; do
  case "$opt" in
    a) AUTH_MODE=$OPTARG ;;
    p) PASS=$OPTARG ;;
    u) USER=$OPTARG ;;
    v) VERSION=$OPTARG ;;
    \?) echo "Unrecognized option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ $# -ge 2 ]; then
  BOOTSTRAP_HOST=$1
  shift
else
  echo "ERROR: Two hostnames are required." >&2
  exit 1
fi
JOINING_HOST=$1

source /opt/vagrant/ml_${VERSION}_license.properties

echo "BOOTSTRAP_HOST is ${BOOTSTRAP_HOST}"
echo "JOINING_HOST is ${JOINING_HOST}"
echo "VERSION is ${VERSION}"
echo "USER is ${USER}"
echo "LICENSEE is ${LICENSEE}"

# Suppress progress meter, but still show errors
CURL="curl -s -S"
#for debugging:
#CURL="curl -v"

# Add authentication related options, required once security is initialized
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"

if [ "$VERSION" -eq "5" ] || [ "$VERSION" -eq "6" ]; then
	
	yum -y install recode
	
	echo Uploading license..
	$CURL -i -X POST \
	    --data-urlencode "license-key=$LICENSE" \
	    --data-urlencode "licensee=$LICENSEE" \
	    --data-urlencode "ok=ok" \
	    http://${JOINING_HOST}:8001/license-go.xqy
	service MarkLogic restart
	echo "Waiting for server restart.."
	sleep 5

	echo Agreeing license..
	$CURL -i -X GET \
	    http://${JOINING_HOST}:8001/agree.xqy > agree.html
	LOCATION=`grep "Location:" agree.html \
		| perl -p -e 's/^.*?Location:\s+([^\r\n\s]+).*/$1/'`
	echo "'$LOCATION'"
	
	$CURL -o "agree.html" -i -X GET \
	    http://${JOINING_HOST}:8001/$LOCATION
	AGREE=`grep "accepted-agreement" agree.html \
		| sed 's%^.*value="\([^"]*\)".*$%\1%'`
	
	echo "AGREEMENT is $AGREE"
	$CURL -X POST \
	    --data-urlencode "accepted-agreement=$AGREE" \
	    --data-urlencode "ok=ok" \
	    http://${JOINING_HOST}:8001/agree-go.xqy
	service MarkLogic restart
	echo "Waiting for server restart.."
	sleep 5
	
	echo Initializing services..
	$CURL -X POST \
	    --data-urlencode "ok=ok" \
	    http://${JOINING_HOST}:8001/initialize-go.xqy
	service MarkLogic restart
	echo "Waiting for server restart.."
	sleep 5
	
	echo Joining cluster..
	$CURL -o "join-admin.html" -X GET \
	    http://${JOINING_HOST}:8001/join-admin.xqy
	HOSTID=`grep "new-server-host-id" join-admin.html \
		| sed 's%^.*value="\([^"]*\)".*$%\1%'`
	SSL=`grep "ssl-certificate" join-admin.html \
		| sed 's%^.*value="\([^"]*\)".*$%\1%'`
	
	echo $HOSTID
	#echo $SSL
	
	$CURL -i -X POST \
	    --data-urlencode "new-server=$JOINING_HOST" \
	    --data-urlencode "new-server-port=8001" \
	    --data-urlencode "bind=7999" \
	    --data-urlencode "connect=7999" \
	    --data-urlencode "foreign-bind=7998" \
	    --data-urlencode "foreign-connect=7998" \
	    --data-urlencode "new-server-host-id=$HOSTID" \
	    --data-urlencode "ssl-certificate=$SSL" \
	    --data-urlencode "server=$BOOTSTRAP_HOST" \
	    --data-urlencode "port=8001" \
	    --data-urlencode "protocol=http" \
	    --data-urlencode "ok=ok" \
	    http://${JOINING_HOST}:8001/join-admin-go.xqy > join-admin.html
	LOCATION=`grep "Location:" join-admin.html \
		| perl -p -e 's/^.*?Location:\s+([^\r\n\s]+).*/$1/'`
	echo "'$LOCATION'"
	
	$AUTH_CURL -o joiner.html -X GET $LOCATION
	GROUP=`grep "<option" joiner.html \
		| sed 's%^.*value="\([^"]*\)".*$%\1%'`
	echo $GROUP
	
	$AUTH_CURL -i -X POST \
	    --data-urlencode "bind=7999" \
	    --data-urlencode "connect=7999" \
	    --data-urlencode "foreign-bind=7998" \
	    --data-urlencode "foreign-connect=7998" \
	    --data-urlencode "port=8001" \
	    --data-urlencode "joiner-host-id=$HOSTID" \
		--data-urlencode "joiner-admin-host=${JOINING_HOST}:8001" \
	    --data-urlencode "ssl-certificate=$SSL" \
	    --data-urlencode "protocol=http" \
	    --data-urlencode "group=$GROUP" \
	    --data-urlencode "joiner=${JOINING_HOST}" \
	    --data-urlencode "ok=ok" \
		http://${BOOTSTRAP_HOST}:8001/accept-joiner-go.xqy > accepted.html
	LOCATION=`grep "Location:" accepted.html \
		| perl -p -e 's/^.*?Location:\s+([^\r\n\s]+).*/$1/'`
	echo "'$LOCATION'"
	
	$AUTH_CURL -o configs.html -X GET http://${BOOTSTRAP_HOST}:8001/$LOCATION
	grep assignmentsFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > assigns.xml
	grep databasesFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > databases.xml
	grep groupsFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > groups.xml
	grep hostsFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > hosts.xml
	grep clustersFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > clusters.xml
	grep mimetypesFile configs.html | sed 's%^.*value="\([^"]*\)".*$%\1%' | recode html..ascii > mimes.xml

	$CURL -X POST \
	    --data-urlencode "assignmentsFile@assigns.xml" \
	    --data-urlencode "databasesFile@databases.xml" \
	    --data-urlencode "groupsFile@groups.xml" \
	    --data-urlencode "hostsFile@hosts.xml" \
	    --data-urlencode "clustersFile@clusters.xml" \
	    --data-urlencode "mimetypesFile@mimes.xml" \
	    --data-urlencode "protocol=http" \
	    --data-urlencode "ok=ok" \
	    http://${JOINING_HOST}:8001/receive-config-go.xqy

	service MarkLogic restart
	echo "Waiting for server restart.."
	sleep 5
	
	# Debug purposes
	#mkdir /vagrant/${JOINING_HOST}
	#cp *.html /vagrant/${JOINING_HOST}/
	#cp *.xml /vagrant/${JOINING_HOST}/
	rm *.html
    rm *.xml
else
	
#######################################################
# Add one or more hosts to a cluster. For each host joining
# the cluster:
#   (1) POST /admin/v1/init (joining host)
#   (2) GET /admin/v1/server-config (joining host)
#   (3) POST /admin/v1/cluster-config (bootstrap host)
#   (4) POST /admin/v1/cluster-config (joining host)
# GET /admin/v1/timestamp is used to confirm restarts.

  echo "Adding host to cluster: $JOINING_HOST..."

  # (1) Initialize MarkLogic Server on the joining host
  $CURL -X POST -d "" \
    http://${JOINING_HOST}:8001/admin/v1/init
  sleep 20

  echo "Retrieve $JOINING_HOST configuration..."
   # (2) Retrieve the joining host's configuration
  JOINER_CONFIG=`$CURL -X GET -H "Accept: application/xml" \
        http://${JOINING_HOST}:8001/admin/v1/server-config`
  echo $JOINER_CONFIG | grep -q "^<host"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Failed to fetch server config for $JOINING_HOST"
    SKIP=1
  fi

  if [ "$SKIP" -ne 1 ]; then
	  echo "Send $JOINING_HOST configuration to the bootstrap host $BOOTSTRAP_HOST ..."
	  # (3) Send the joining host's config to the bootstrap host, receive
	  #     the cluster config data needed to complete the join. Save the
	  #     response data to cluster-config.zip.
	  $AUTH_CURL -X POST -o cluster-config.zip -d "group=Default" \
	        --data-urlencode "server-config=${JOINER_CONFIG}" \
	        -H "Content-type: application/x-www-form-urlencoded" \
	        http://${BOOTSTRAP_HOST}:8001/admin/v1/cluster-config
	  if [ "$?" -ne 0 ]; then
	    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST"
	    exit 1
	  fi
	  if [ `file cluster-config.zip | grep -cvi "zip archive data"` -eq 1 ]; then
	    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST"
	    exit 1
	  fi
	  
	  echo "Send the cluster config data to the joining host $JOINING_HOST, completing the join sequence..."
	  # (4) Send the cluster config data to the joining host, completing 
	  #     the join sequence.
	  TIMESTAMP=`$CURL -X POST -H "Content-type: application/zip" \
	      --data-binary @./cluster-config.zip \
	      http://${JOINING_HOST}:8001/admin/v1/cluster-config \
	      | grep "last-startup" \
	      | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
      
	  echo "Restart check $JOINING_HOST $TIMESTAMP $LINENO..."
	  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  
	  rm ./cluster-config.zip
  fi

fi

echo "Removing network suffix from hostname"

$AUTH_CURL -o "hosts.html" -X GET \
    "http://${JOINING_HOST}:8001/host-summary.xqy?section=host"
HOST_URL=`grep "statusfirstcell" hosts.html \
	| grep ${JOINING_HOST} \
	| sed 's%^.*href="\(host-admin.xqy?section=host&amp;host=[^"]*\)".*$%\1%'`
HOST_ID=`grep "statusfirstcell" hosts.html \
	| grep ${JOINING_HOST} \
	| sed 's%^.*href="host-admin.xqy?section=host&amp;host=\([^"]*\)".*$%\1%'`
echo "HOST_URL is $HOST_URL"
echo "HOST_ID is $HOST_ID"

$AUTH_CURL -o "host.html" -X GET "http://${JOINING_HOST}:8001/$HOST_URL"
HOST_XPATH=`grep host-name host.html \
	| grep input \
	| sed 's%^.*name="\([^"]*\)".*$%\1%'`
echo "HOST_XPATH is $HOST_XPATH"

$AUTH_CURL -X POST \
	--data-urlencode "host=$HOST_ID" \
	--data-urlencode "section=host" \
	--data-urlencode "$HOST_XPATH=${JOINING_HOST}" \
	--data-urlencode "ok=ok" \
	"http://${JOINING_HOST}:8001/host-admin-go.xqy"

service MarkLogic restart
echo "Waiting for server restart.."
sleep 5

rm *.html

echo "...$JOINING_HOST successfully added to the cluster."
