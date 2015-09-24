#!/bin/bash
echo "running $0 $@"

################################################################
# Use this script to initialize the first (or only) host in
# a MarkLogic Server cluster. Use the options to control admin
# username and password, authentication mode, and the security
# realm. If no hostname is given, localhost is assumed. Only
# minimal error checking is performed, so this script is not
# suitable for production use.
#
# Usage:  this_command [options] hostname
#
################################################################

BOOTSTRAP_HOST="localhost"
USER="admin"
PASS="admin"
AUTH_MODE="anyauth"
VERSION="7"
SEC_REALM="public"
N_RETRY=10
RETRY_INTERVAL=5

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
  echo "Restart check for $1..."
  LAST_START=`$AUTH_CURL --max-time 1 -s "http://$1:8001/admin/v1/timestamp"`
  for i in `seq 1 ${N_RETRY}`; do
    # continue as long as timestamp didn't change, or no output was returned
    if [ "$2" == "$LAST_START" ] || [ "$LAST_START" == "" ]; then
      sleep ${RETRY_INTERVAL}
      echo "Retrying..."
      LAST_START=`$AUTH_CURL --max-time 1 -s "http://$1:8001/admin/v1/timestamp"`
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
while getopts ":a:p:r:u:v:" opt; do
  case "$opt" in
    a) AUTH_MODE=$OPTARG ;;
    p) PASS=$OPTARG ;;
    r) SEC_REALM=$OPTARG ;;
    u) USER=$OPTARG ;;
    v) VERSION=$OPTARG ;;
    \?) echo "Unrecognized option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ $# -ge 1 ]; then
  BOOTSTRAP_HOST=$1
  shift
fi

if [ -f /vagrant/ml_${VERSION}_license.properties ]; then
  source /vagrant/ml_${VERSION}_license.properties
elif [ -f ml_${VERSION}_license.properties ]; then
  source ml_${VERSION}_license.properties
elif [ -f /opt/vagrant/ml_${VERSION}_license.properties ]; then
  source /opt/vagrant/ml_${VERSION}_license.properties
fi

echo "BOOTSTRAP_HOST is ${BOOTSTRAP_HOST}"
echo "VERSION is ${VERSION}"
echo "USER is ${USER}"
echo "LICENSEE is ${LICENSEE}"

# Make sure curl is installed
yum -y install curl
# Make sure perl URI::Escape is installed
yum -y install perl-URI

# Suppress progress meter, but still show errors
CURL="curl -s -S"
#for debugging:
#CURL="curl -v"

# Backwards-compat with old curl
BOOTSTRAP_HOST_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$BOOTSTRAP_HOST")"
LICENSE_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LICENSE")"
LICENSEE_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LICENSEE")"

# Add authentication related options, required once security is initialized
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"

if [ "$VERSION" -eq "5" ] || [ "$VERSION" -eq "6" ]; then
  
  echo Uploading license..
  $CURL -i -X POST \
        --data "license-key=$LICENSE_ENC" \
        --data "licensee=$LICENSEE_ENC" \
        --data "ok=ok" \
        http://${BOOTSTRAP_HOST}:8001/license-go.xqy
  
  /sbin/service MarkLogic restart
  echo "Waiting for server restart.."
  sleep 5

  echo Agreeing license..
  $CURL -i -X GET \
      http://${BOOTSTRAP_HOST}:8001/agree.xqy > agree.html
  LOCATION=`grep "Location:" agree.html \
    | perl -p -e 's/^.*?Location:\s+([^\r\n\s]+).*/$1/'`
  echo "'$LOCATION'"
  
  $CURL -o "agree.html" -X GET \
      "http://${BOOTSTRAP_HOST}:8001/${LOCATION}"
  AGREE=`grep "accepted-agreement" agree.html \
    | sed 's%^.*value="\(.*\)".*$%\1%'`
  
  # Backwards-compat with old curl
  AGREE_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$AGREE")"
  
  echo "AGREEMENT is $AGREE"
  $CURL -X POST \
        --data "accepted-agreement=$AGREE_ENC" \
        --data "ok=ok" \
        http://${BOOTSTRAP_HOST}:8001/agree-go.xqy
  
  /sbin/service MarkLogic restart
  echo "Waiting for server restart.."
  sleep 5
  
  echo Initializing services..
  $CURL -X POST \
        --data "ok=ok" \
        http://${BOOTSTRAP_HOST}:8001/initialize-go.xqy
  
  /sbin/service MarkLogic restart
  echo "Waiting for server restart.."
  sleep 5
  
  echo Initializing security..
  $CURL -X POST \
        --data "user=$USER" \
        --data "password1=$PASS" \
        --data "password2=$PASS" \
        --data "realm=$SEC_REALM" \
        --data "ok=ok" \
        http://${BOOTSTRAP_HOST}:8001/security-install-go.xqy
  
  /sbin/service MarkLogic restart
  echo "Waiting for server restart.."
  sleep 5
  
  rm *.html
else
  
  #######################################################
  # Bring up the first (or only) host in the cluster. The following
  # requests are sent to the target host:
  #   (1) POST /admin/v1/init
  #   (2) POST /admin/v1/instance-admin?admin-user=X&admin-password=Y&realm=Z
  # GET /admin/v1/timestamp is used to confirm restarts.

  # (1) Initialize the server
  echo "Initializing $BOOTSTRAP_HOST and setting license..."
  $CURL -X POST -H "Content-type=application/x-www-form-urlencoded" \
        --data "license-key=$LICENSE_ENC" \
        --data "licensee=$LICENSEE_ENC" \
        http://${BOOTSTRAP_HOST}:8001/admin/v1/init
  sleep 10

  # (2) Initialize security and, optionally, licensing. Capture the last
  #     restart timestamp and use it to check for successful restart.
  echo "Initializing security for $BOOTSTRAP_HOST..."
  TIMESTAMP=`$CURL -X POST \
     -H "Content-type: application/x-www-form-urlencoded" \
     --data "admin-username=${USER}" --data "admin-password=${PASS}" \
     --data "realm=${SEC_REALM}" \
     http://${BOOTSTRAP_HOST}:8001/admin/v1/instance-admin \
     | grep "last-startup" \
     | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
  if [ "$TIMESTAMP" == "" ]; then
    echo "ERROR: Failed to get instance-admin timestamp." >&2
    exit 1
  fi

  # Test for successful restart
  restart_check $BOOTSTRAP_HOST $TIMESTAMP $LINENO
fi

echo "Removing network suffix from hostname"

$AUTH_CURL -o "hosts.html" -X GET \
           "http://${BOOTSTRAP_HOST}:8001/host-summary.xqy?section=host"
HOST_ID=`grep "statusfirstcell" hosts.html \
  | grep ${BOOTSTRAP_HOST} \
  | sed 's%^.*href="host-admin.xqy?section=host&amp;host=\([^"]*\)".*$%\1%'`
echo "HOST_ID is $HOST_ID"

$AUTH_CURL -X POST \
           --data "host=$HOST_ID" \
           --data "section=host" \
           --data "/ho:hosts/ho:host/ho:host-name=${BOOTSTRAP_HOST_ENC}" \
           --data "ok=ok" \
           "http://${BOOTSTRAP_HOST}:8001/host-admin-go.xqy"

/sbin/service MarkLogic restart
echo "Waiting for server restart.."
sleep 5

rm *.html

echo "Initialization complete for $BOOTSTRAP_HOST..."
