#!/bin/bash
file=~/"AdithyaBase.pem"
if [ -e "$file" ];then

echo "$file found."
keypair="AdithyaBase"
subnet_id="subnet-de0385f2"
subnet_id="subnet-de0385f2"
aws ec2 run-instances --iam-instance-profile Name=FullAccess --image-id ami-b70554c8 --count 1 --subnet-id $subnet_id --instance-type t2.micro --key-name  $keypair --subnet-id $subnet_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=shell1_ec2_Adithya}]" --region us-east-1
aws ec2 run-instances --iam-instance-profile Name=FullAccess --image-id ami-b70554c8 --count 1 --subnet-id $subnet_id --instance-type t2.micro --key-name  $keypair --subnet-id $subnet_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=shell2_ec2_Adithya}]" --region us-east-1
instanceid1=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=shell1_ec2_Adithya" | grep InstanceId | grep -E -o "i\-[0-9A-Za-z]+")
instanceid2=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=shell2_ec2_Adithya" | grep InstanceId | grep -E -o "i\-[0-9A-Za-z]+")
ip1=$(aws ec2 describe-instances --instance-ids $instanceid1 --region us-east-1 | grep PublicIpAddress | awk -F ":" '{print $2}' | sed 's/[",]//g')
ip2=$(aws ec2 describe-instances --instance-ids $instanceid2 --region us-east-1 | grep PublicIpAddress | awk -F ":" '{print $2}' | sed 's/[",]//g')
ip1=$(echo "${ip1// /}")
ip2=$(echo "${ip2// /}")


echo "Generating public keys in both the instances"
ssh -o CheckHostIP=no -i `echo $file` ec2-user@`echo $ip1` 'bash -s'<<'ENDSSH' 
ssh-keygen -f .ssh/id_rsa -t rsa -N '' 
ENDSSH
sleep 5
ssh -o CheckHostIP=no -i `echo $file` ec2-user@`echo $ip2` 'bash -s'<<'ENDSSH' 
ssh-keygen -f .ssh/id_rsa -t rsa -N '' 
ENDSSH
sleep 5
echo "Copying the public keys of each instance into the other instance"
mkdir public1 public2
scp -i $file -r ec2-user@$ip1:.ssh/id_rsa.pub ~/public1
scp -i $file -r ec2-user@$ip2:.ssh/id_rsa.pub ~/public2
scp -i $file -r  ~/public1/id_rsa.pub ec2-user@$ip2:~/
scp -i $file -r  ~/public2/id_rsa.pub ec2-user@$ip1:~/


echo "Connecting the two instances"
ssh -i $file ec2-user@$ip1 <<'ENDSSH' 
echo $(cat id_rsa.pub) >> .ssh/authorized_keys
ENDSSH
ssh -i $file ec2-user@$ip2 <<'ENDSSH' 
echo $(cat id_rsa.pub) >> .ssh/authorized_keys
ENDSSH

echo "Now the instances can connect to each other password less"
rm -r public2
rm -r public1

else

echo "Key not found at $file. Contact Adithya V for access to key."

fi
