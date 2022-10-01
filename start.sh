#!/bin/bash

# C. Constants
NS=devops
JENKINS_IMAGE=jenkins/jenkins:lts
JENKINS_POD=jenkins
JENKINS_SVC_FILE=jenkins-svc.yaml
PASSWORD_FILE=/var/jenkins_home/secrets/initialAdminPassword
now="--grace-period=0 --force"

# 0. Reset
kubectl delete ns $NS $now

# 1. Create ns
kubectl create ns $NS

# 2. Create pod jenkins
kubectl run -n $NS $JENKINS_POD --image $JENKINS_IMAGE

# 3. Create service jenkins
kubectl replace -f $JENKINS_SVC_FILE --force

# 4. Wait until pod is ready
until kubectl -n $NS get pod $JENKINS_POD|grep Running; do sleep 1; done
until kubectl -n $NS logs $JENKINS_POD |grep initialAdminPassword; do sleep 1; done

# 5. Show password
echo -e "Jenkins password: "
kubectl -n $NS exec -it $JENKINS_POD -- cat $PASSWORD_FILE
