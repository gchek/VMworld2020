#!/usr/bin/env bash

clear
echo -e "\033[1m"   #Bold ON
echo " ==========================="
echo "     VMC deployment"
echo " ==========================="
echo "===== Set Credentials ============="
echo -e "\033[0m"   #Bold OFF

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TF_VAR_my_org_id
unset TF_VAR_vmc_token
unset TF_VAR_AWS_account
unset TF_VAR_host
unset VM1_DNS

DEF_ORG_ID="7421a286-xxx-xxxx-xxxx-779b83d75fb5"
#read -p "Enter your ORG ID (long format) [default=$DEF_ORG_ID]: " TF_VAR_my_org_id
TF_VAR_my_org_id="${TF_VAR_my_org_id:-$DEF_ORG_ID}"
#echo ".....Exporting $TF_VAR_my_org_id"
export TF_VAR_my_org_id=$TF_VAR_my_org_id
#echo ""

DEF_TOKEN="gCs8WlleUW3..........zDdnCcbypDOV0QXxBwiWkfZVD6"
#read -p "Enter your VMC API token [default=$DEF_TOKEN]: " TF_VAR_vmc_token
TF_VAR_vmc_token="${TF_VAR_vmc_token:-$DEF_TOKEN}"
#echo ".....Exporting $TF_VAR_vmc_token"
export TF_VAR_vmc_token=$TF_VAR_vmc_token
#echo ""

ACCOUNT="614........"
#read -p "Enter your AWS Account [default=$ACCOUNT]: " TF_VAR_AWS_account
TF_VAR_AWS_account="${TF_VAR_AWS_account:-$ACCOUNT}"
#echo ".....Exporting $TF_VAR_AWS_account"
export TF_VAR_AWS_account=$TF_VAR_AWS_account
#echo ""

ACCESS="AKIAY........."
#read -p "Enter your AWS Access Key [default=$ACCESS]: " TF_VAR_access_key
TF_VAR_access_key="${TF_VAR_access_key:-$ACCESS}"
#echo ".....Exporting $TF_VAR_access_key"
export AWS_ACCESS_KEY_ID=$TF_VAR_access_key
#echo ""

SECRET="7M/qn7.........."
#read -p "Enter your AWS Secret Key [default=$SECRET]: " TF_VAR_secret_key
TF_VAR_secret_key="${TF_VAR_secret_key:-$SECRET}"
#echo ".....Exporting $TF_VAR_secret_key"
export AWS_SECRET_ACCESS_KEY=$TF_VAR_secret_key

#echo ""

read  -p $'Press enter to continue (^C to stop)...\n'



echo -e "\033[1m"   #Bold ON
echo "===== PHASE 1: Creating SDDC ==========="
echo -e "\033[0m"   #Bold OFF
cd ./p1/main
terraform init
terraform apply
export VM1_DNS=$(terraform output VM1_DNS)

cd ../../
export TF_VAR_host=$(terraform output -state=./phase1.tfstate proxy_url)

read  -p $'Press enter to continue (^C to stop)...\n'
cd ./p2/main
terraform  init

echo -e "\033[1m"   #Bold ON
echo "===== PHASE 2: Networking and Security ==========="
echo -e "\033[0m"   #Bold OFF
echo ".....Importing CGW and MGW into Terraform phase2."

if [[ ! -f ../../phase2.tfstate ]]
then
  echo "Importing . . . . ."
  terraform import -lock=false module.NSX.nsxt_policy_gateway_policy.mgw mgw/default
  terraform import -lock=false module.NSX.nsxt_policy_gateway_policy.cgw cgw/default
fi
echo ".....CGW, MGW imported."

terraform  output -state=../../phase1.tfstate -json > ./outputs.json
terraform apply

read  -p $'Press enter to continue (^C to stop)...\n'
echo -e "\033[1m"   #Bold ON
echo "===== Preparing PHASE 3 on EC2 ==========="
echo -e "\033[0m"   #Bold OFF

scp -o StrictHostKeyChecking=no -i ~/AWS-SSH/set-emea-oregon.pem ./outputs.json ec2-user@${VM1_DNS}:
scp -o StrictHostKeyChecking=no -i ~/AWS-SSH/set-emea-oregon.pem -r ../../p3 ec2-user@${VM1_DNS}:
scp -o StrictHostKeyChecking=no -i ~/AWS-SSH/set-emea-oregon.pem -r ../../phase1.tfstate ec2-user@${VM1_DNS}:
scp -o StrictHostKeyChecking=no -i ~/AWS-SSH/set-emea-oregon.pem -r ../../phase2.tfstate ec2-user@${VM1_DNS}:


cd ../..
