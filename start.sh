#!/bin/bash

# C. Constants
NS=devops
JENKINS_DEPLOY_FILE=jenkins-deploy.yaml
JENKINS_POD=""
JENKINS_SVC_FILE=jenkins-svc.yaml
PASSWORD_FILE=/var/jenkins_home/secrets/initialAdminPassword
now="--grace-period=0 --force"

# 0. Reset
kubectl delete ns $NS $now

# 1. Create ns
kubectl create ns $NS

# 2. Create deploy jenkins
kubectl replace -f $JENKINS_DEPLOY_FILE --force

# 3. Create service jenkins
kubectl replace -f $JENKINS_SVC_FILE --force

# 4. Wait until pod is ready
JENKINS_POD=$(kubectl -n $NS get pod --no-headers | grep -i jenkins | awk '{print $1}')
echo "JENKINS_POD: " $JENKINS_POD
until kubectl -n $NS get pod $JENKINS_POD|grep Running; do sleep 1; done
until kubectl -n $NS logs $JENKINS_POD |grep "Jenkins is fully up and running"; do sleep 1; done

# 5. Show password
echo -e "Jenkins password: "
kubectl -n $NS exec -it $JENKINS_POD -- cat $PASSWORD_FILE
