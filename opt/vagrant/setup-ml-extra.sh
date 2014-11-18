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

echo "VERSION is ${VERSION}"
echo "BOOTSTRAP_HOST is ${BOOTSTRAP_HOST}"
echo "JOINING_HOST is ${JOINING_HOST}"


# Curl command for all requests. Suppress progress meter (-s), 
# but still show errors (-S)
CURL="curl -s -S"
# Curl command when authentication is required, after security
# is initialized.
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"


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
    exit 1
  fi

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
      
#  echo "Restart check $JOINING_HOST $TIMESTAMP $LINENO..."
#  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  
  rm ./cluster-config.zip

  echo "...$JOINING_HOST successfully added to the cluster."
