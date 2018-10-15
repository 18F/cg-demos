#!/usr/bin/env bash 

set -e

# include the goodness
source ./init.sh
REPO=https://github.com/18F/cf-sample-app-spring
DIR=cf-sample-app-spring
APP=cf-spring

cleanup() {
  echo "DOING PRE-DEMO CLEAN UP" 
  cf delete cf-spring -f >/dev/null
  cf delete-service cf-spring-db -f >/dev/null
  rm -rf spring-music
}

function launch() {
cleanup
# clean up screen before continuing
clear

# put your demo awesomeness here
p "# cf help confirms that we have the CF CLI installed"
pe "cf help"

echo
p "# now lets clone the sample app from $REPO"

/bin/rm -rf $DIR
pe "git clone $REPO"

echo
p "# and cd into the directory, $DIR"
pe "cd $DIR"

echo
p "# at this point, login if you've not already done so, e.g:"
p "cf login -a https://api.fr.cloud.gov --sso"
cat<<END
API endpoint: https://api.fr.cloud.gov

One Time Code ( Get one at https://login.fr.cloud.gov/passcode )>
^C
END

echo
p "# set the target org and space"
pe "cf target -o $CFORG -s $CFUSER"


echo
p "# We can now push the app to Cloud Foundry"
p "# while it runs, we can walk the seq diagram at"
echo  "https://github.com/18F/cg-workshop/raw/master/images/app_push_flow_diagram_diego.png"
pe "cf push" 
}

launch


route=$(cf app $APP | perl -ane 'm/routes: *(\S+)/ && print "$1\n"')
echo 
p "# if you can't already, view the running app at it's route:"
echo "$route"

echo
p "# to add a backend service, see what's in the 'marketplace'"
pe "cf marketplace"

echo
p "# use the -s switch for details on the aws-rds offering"
pe "cf marketplace -s aws-rds"

echo 
p "# create a shared-mysql instance 'cf-spring-db'"
pe "cf create-service aws-rds shared-mysql cf-spring-db"

echo
p "# 'binding' provides the app the env vars to connect to the service"
pe "cf bind-service cf-spring cf-spring-db"

echo
(sleep $naptime && open -a "Google Chrome.app" https://logs.fr.cloud.gov ) &

pe "cf restage cf-spring"
pe "cf app cf-spring"

echo "Let's SSH in..."
pe "cf ssh cf-spring"

# show a prompt so as not to reveal our true nature after
# the demo has concluded
echo
echo "If you're done, run ./demo-cleanup.sh"
echo "-- fini $0 --"
echo
p ""
