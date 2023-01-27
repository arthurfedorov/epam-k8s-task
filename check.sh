#!/bin/bash
if [[ $# -eq 0 ]]; then
    echo -e "ERROR! You must enter your full name, for example:\n${0} \"Anton Butsko\""
    exit 1
fi

readonly FULL_NAME=$1
readonly FIRST_NAME_LETTER="${FULL_NAME:0:1}"
readonly LAST_NAME="${FULL_NAME##* }"
readonly USERNAME="${FIRST_NAME_LETTER,,}${LAST_NAME,,}"


GREEN='\033[0;32m' 
RED='\033[0;31m' 
NC='\033[0m'
YELLOW='\033[0;33m'
score=0
total_score=0
easy=1
midle=2
hard=5

# config_context_check
# echo "Checking current context"
# let "total_score+=$easy"
# if [[ $(kubectl config current-context) == "minikube-$USERNAME" ]]; then
#     echo -e "$GREEN Current context is correct $NC"
#     let "score+=$easy"
# else
#     echo -e "$RED ERROR! Current context is not correct. Context name should be \"minikube-$USERNAME\"!$NC"
#     exit 1
# fi

# application_general_check
echo "Checking deployment 'application' general info"
# deployment_name_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null) == 'application' ]]; then
    echo -e "$GREEN Deployment name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment name is not correct$NC"
fi
# deployment_label_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application --show-labels --no-headers 2> /dev/null | awk '{ print $6}' | cut -f2- -d=) == 'application' ]]; then
    echo -e "$GREEN Deployment label is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment label is not correct$NC"
fi
# deployment_container_name_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].name') == 'application' ]]; then
    echo -e "$GREEN Deployment container name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment container name is not correct$NC"
fi
# deployment_container_image_name_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].image' | grep -w "${USERNAME}_application") != '' ]]; then
    echo -e "$YELLOW Deployment container image name is correct. Do not forget to check if repo is private$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment container image name is not correct$NC"
fi
# service_name_check
let "total_score+=$easy"
if [[ $(kubectl get service application -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null ) == 'application' ]]; then
    echo -e "$GREEN Service name for application is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Service name for application is not correct$NC"
fi
# deployment_replicas_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.replicas') == 1 ]]; then
    echo -e "$GREEN Deployment replicas count is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment replicas count is not correct$NC"
fi
# deployment_ready_replicas_check
let "total_score+=$hard"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.status.readyReplicas') == 1 ]]; then
    echo -e "$GREEN Deployment replicas are ready$NC"
    let "score+=$hard"
else echo -e "$RED WARNING: Deployment replicas are not ready$NC"
fi
# deployment_strategy_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.strategy.type') == 'Recreate' ]]; then
    echo -e "$GREEN Deployment strategy is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Deployment strategy is not correct$NC"
fi
# deployment_init_container_check
let "total_score+=$hard"
if [[ $(kubectl get deployments.apps application -o jsonpath='{.spec.template.spec.initContainers[*]}') != '' ]]; then
    echo -e "$YELLOW Deployment init container exist. Do not forget to check functionality$NC"
    let "score+=$hard"
else echo -e "$RED WARNING: Deployment init container does not exist$NC"
fi

# application_env_check
echo "Checking application variables"
# configmap_name_check
let "total_score+=$easy"
if [[ $(kubectl get configmaps application -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null) == 'application' ]]; then
    echo -e "$GREEN Configmap name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Configmap name is not correct$NC"
fi
# application_configmap_refer_check
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o=json 2> /dev/null | grep configMap) != '' ]]; then
    echo -e "$YELLOW Configmap refer exists. Do not forget to check functionality$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Configmap refer does not exist$NC"
fi
# application_configmap_data_check
let "total_score+=$((midle*2))"
if [[ $(kubectl get configmap application -o=json 2> /dev/null | jq -r '.data.MONGO_HOST') == 'mongo' ]]; then
    echo -e "$GREEN Variable MONGO_HOST is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Variable MONGO_HOST is not correct$NC"
fi
if [[ $(kubectl get configmap application -o=json 2> /dev/null | jq -r '.data.MONGO_PORT') == '27017' ]]; then
    echo -e "$GREEN Variable MONGO_PORT is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Variable MONGO_PORT is not correct$NC"
fi
if [[ $(kubectl get configmap application -o=json 2> /dev/null | jq -r '.data.BG_COLOR') == 'teal' ]]; then
    echo -e "$GREEN Variable BG_COLOR is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Variable BG_COLOR is not correct$NC"
fi
if [[ $(kubectl get configmap application -o=json 2> /dev/null | jq -r '.data.FAIL_FLAG') == 'false' ]]; then
    echo -e "$GREEN Variable FAIL_FLAG is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Variable FAIL_FLAG is not correct$NC"
fi

# application_ports_check
echo "Checking application ports"
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].ports[0].containerPort') == '5000' ]]; then
    echo -e "$GREEN Application container port is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container port is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get services application -o json 2> /dev/null | jq -r '.spec.ports[0].port') == '80' ]]; then
    echo -e "$GREEN Service application port is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Service application port is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get services application -o json 2> /dev/null | jq -r '.spec.ports[0].targetPort') == '5000' ]]; then
    echo -e "$GREEN Service application target port is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Service application target port is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get services application -o json 2> /dev/null | jq -r '.spec.type') == 'ClusterIP' ]]; then
    echo -e "$GREEN Service application type is correct$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Service application type is not correct$NC"
fi

# application_limits_check
echo "Checking application limits"
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.limits.cpu') == '500m' ]]; then
    echo -e "$GREEN Application container cpu limit is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container cpu limit is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.limits.memory') == '128Mi' ]]; then
    echo -e "$GREEN Application container memory limit is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container memory limit is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.requests.cpu') == '200m' ]]; then
    echo -e "$GREEN Application container cpu request is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container cpu request is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.requests.memory') == '64Mi' ]]; then
    echo -e "$GREEN Application container memory request is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container memory request is not correct$NC"
fi

# application_probes_check
echo "Checking application probes"
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].livenessProbe.httpGet.path') == '/healthz' ]]; then
    echo -e "$GREEN Application container liveness probe is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container liveness probe is not correct$NC"
fi
let "total_score+=$easy"
if [[ $(kubectl get deployments.apps application -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].readinessProbe.httpGet.path') == '/healthx' ]]; then
    echo -e "$GREEN Application container readiness probe is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Application container readiness probe is not correct$NC"
fi

# data_layer_general_check
echo "Checking statefulset 'mongo' general info"
# statefulset_name_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null ) == 'mongo' ]]; then
    echo -e "$GREEN Statefulset name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Statefulset name is not correct$NC"
fi
# statefulset_label_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo --show-labels --no-headers 2> /dev/null | awk '{ print $4}' | cut -f2- -d=) == 'mongo' ]]; then
    echo -e "$GREEN Statefulset label is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Statefulset label is not correct$NC"
fi
# statefulset_container_name_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].name') == 'mongo' ]]; then
    echo -e "$GREEN Statefulset container name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Statefulset container name is not correct$NC"
fi
# statefulset_replicas_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.replicas') == 1 ]]; then
    echo -e "$GREEN Statefulset replicas count is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Statefulset replicas count is not correct$NC"
fi
# statefulset_ready_replicas_check
let "total_score+=$hard"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.status.readyReplicas') == 1 ]]; then
    echo -e "$GREEN Statefulset replicas are ready$NC"
    let "score+=$hard"
else echo -e "$RED WARNING: Statefulset replicas are not ready$NC"
fi

# data_layer_limits_check
echo "Checking data layer limits"
# mongo_cpu_limits_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.limits.cpu') == '500m' ]]; then
    echo -e "$GREEN Mongo container cpu limit is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo container cpu limit is not correct$NC"
fi
# mongo_memory_limits_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.limits.memory') == '256Mi' ]]; then
    echo -e "$GREEN Mongo container memory limit is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo container memory limit is not correct$NC"
fi
# mongo_cpu_request_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.requests.cpu') == '200m' ]]; then
    echo -e "$GREEN Mongo container cpu request is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo container cpu request is not correct$NC"
fi
# mongo_memory_request_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o json 2> /dev/null | jq -r '.spec.template.spec.containers[0].resources.requests.memory') == '128Mi' ]]; then
    echo -e "$GREEN Mongo container memory request is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo container memory request is not correct$NC"
fi

# data_layer_credentials_check
echo "Checking mongo credentials"
# mongo_secret_name_check
let "total_score+=$easy"
if [[ $(kubectl get secret mongo -o json 2> /dev/null | jq -r '.metadata.name') == 'mongo' ]]; then
    echo -e "$GREEN Mongo secret name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo secret name is not correct$NC"
fi
# mongo_secret_refer_check
let "total_score+=$easy"
if [[ $(kubectl get statefulsets.apps mongo -o=json 2> /dev/null | grep secretRef) != '' || $(kubectl get statefulsets.apps mongo -o=json 2> /dev/null | grep secretKeyRef) != '' || $(kubectl get statefulsets.apps mongo -o=json 2> /dev/null| grep secretName) != '' ]]; then
    echo -e "$YELLOW Secret refer exists. Do not forget to check functionality$NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Secret refer does not exist$NC"
fi
# mongo_secret_data_check
let "total_score+=$midle"
data=$(kubectl get secret mongo -o=jsonpath="{.data.*}" 2> /dev/null )
# mongo_secret_username_check
if [[ $(echo $data | awk '{print $1}' | base64 -d) == 'root' || $(echo $data | awk '{print $2}' | base64 -d) == 'root' ]]; then
    echo -e "$GREEN Mongo secret username is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo secret username is not correct$NC"
fi
# mongo_secret_password_check
if [[ $(echo $data | awk '{print $1}' | base64 -d) == 'example' || $(echo $data | awk '{print $2}' | base64 -d) == 'example' ]]; then
    echo -e "$GREEN Mongo secret password is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Mongo secret password is not correct$NC"
fi

# ingress_check
echo "Checking ingress"
# ingress_name_check
let "total_score+=$easy"
if [[ $(kubectl get ingress nginx -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null ) == 'nginx' ]]; then
    echo -e "$GREEN Ingress name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Ingress name is not correct$NC"
fi
# ingress_host_check
let "total_score+=$easy"
if [[ $(kubectl get ingress nginx --output jsonpath='{.spec.rules[0].host}' 2> /dev/null ) == "$USERNAME.application.com" ]]; then
    echo -e "$GREEN Ingress host name is correct $NC"
    let "score+=$easy"
else echo -e "$RED WARNING: Ingress host name is not correct$NC"
fi

INGRESS_NAME=$(kubectl get ingress -o custom-columns=NAME:.metadata.name --no-headers=true 2> /dev/null )
INGRESS_HOST=$(kubectl get ingress $INGRESS_NAME -o json 2> /dev/null | jq -r .spec.rules[].host 2> /dev/null)
# INGRESS_URL=$(kubectl get ing $INGRESS_NAME -o=jsonpath='{@.status.loadBalancer.ingress[0].ip}' 2> /dev/null )

# app_issue_check
echo "Checking app issue"
let "total_score+=$hard"
if [[ $(curl --silent http://$INGRESS_HOST/issue -H "Host: ${INGRESS_HOST}" 2> /dev/null | jq -r '.fixed' 2> /dev/null) == 'true' ]]; then
    echo -e "$GREEN Application issue was fixed$NC"
    let "score+=$hard"
else echo -e "$RED WARNING: Application was not fixed$NC"
fi

# db_connection_check
echo "Checking database connection"
let "total_score+=$hard"
if [[ $(curl --silent http://$INGRESS_HOST/db_message -H "Host: ${INGRESS_HOST}" 2> /dev/null | jq -r '.succeed' 2> /dev/null) == 'true' ]]; then
    echo -e "$GREEN Database connection is correct$NC"
    let "score+=$hard"
else echo -e "$RED WARNING: Database connection is not correct$NC"
fi
BGreen='\033[1;32m'
BRed='\033[1;31m' 
BYellow='\033[1;33m'
percentage=$(expr 100 \* $score / $total_score)
if [[ $percentage -lt 70 ]]; then
    echo -e "\n$BRed Your result is $score/$total_score or $percentage%. Come on, you can do it better!!!$NC"
elif [[ $percentage -ge 70 && $percentage != 100 ]]; then
    echo -e "\n$BYellow Your result is $score/$total_score or $percentage%. Good result, try to fix all other issues!$NC"
else echo -e "\n$BGreen Your result is $score/$total_score or $percentage%. You are rock!!!$NC"
fi
