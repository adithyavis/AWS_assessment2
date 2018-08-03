#!/bin/bash

bucket1='adithyaawsassignment1'
bucket1arn=$(echo arn:aws:s3:::$bucket1)
bucket2='adithyaawsassignment2'
bucket2arn=$(echo arn:aws:s3:::$bucket2)
lambda=$(echo $bucket2)

aws s3api put-bucket-versioning --bucket $bucket1 --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket $bucket2 --versioning-configuration Status=Enabled

topicname=$(echo $bucket1-topic)
aws sns create-topic --name $topicname --region us-east-1
topicarn=$(aws sns create-topic --name $topicname --region us-east-1| grep -oP '(?<="TopicArn": ")[^"]*')

value=$(echo "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__default_statement_ID\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\",\"SNS:Receive\"],\"Resource\":\"$topicarn\",\"Condition\":{\"StringEquals\":{\"AWS:SourceArn\":\"$bucket1arn\"}}}]}")

aws sns set-topic-attributes --region us-east-1 --topic-arn $topicarn --attribute-name Policy --attribute-value $value   
#aws sns get-topic-attributes  --region us-east-1 --topic-arn $topicarn

eventname=$(cat <<EOF
{"TopicConfigurations":[{"Id":"S3objectchanges","TopicArn":"$topicarn","Events":["s3:ObjectCreated:*","s3:ObjectRemoved:*"]}]}
EOF
)
aws s3api put-bucket-notification-configuration --bucket $bucket1 --notification-configuration $eventname
#aws s3api get-bucket-notification-configuration --bucket $bucket1

pythonname=$bucket2
pythonname+='.py'
echo "import urllib
import boto3
import ast
import json
print('Loading function')

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    sns_message = ast.literal_eval(event['Records'][0]['Sns']['Message'])
    target_bucket = context.function_name
    source_bucket = str(sns_message['Records'][0]['s3']['bucket']['name'])
    key = str(urllib.unquote_plus(sns_message['Records'][0]['s3']['object']['key']).decode('utf8'))
    eventName = sns_message['Records'][0]['eventName']
    copy_source = {'Bucket':source_bucket, 'Key':key}
    if eventName == 'ObjectCreated:Put':
        print 'Copying %s from bucket %s to bucket %s ..' %(key, source_bucket, target_bucket)
        s3.copy_object(Bucket=target_bucket, Key=key, CopySource=copy_source)
    if eventName == 'ObjectRemoved:DeleteMarkerCreated':
        s3.delete_object(Bucket=target_bucket, Key=key)" > $pythonname
zip file.zip $pythonname

handler=$lambda
handler+='.lambda_handler'
aws lambda create-function --function-name $lambda --runtime python2.7 --role arn:aws:iam::488599217855:role/lambda_s3_access --handler $handler --zip-file fileb://file.zip --timeout 300 --region us-east-1
lambdaarn=$(aws lambda get-function-configuration --function-name $lambda --region us-east-1| grep -oP '(?<="FunctionArn": ")[^"]*')
aws lambda add-permission --function-name $lambda --statement-id 123Test --action lambda:* --principal sns.amazonaws.com --source-arn $topicarn --source-arn $topicarn --region us-east-1

aws sns subscribe --topic-arn $topicarn --protocol lambda --notification-endpoint $lambdaarn --region us-east-1
subscribearn=$(aws sns subscribe --topic-arn $topicarn --protocol lambda --notification-endpoint $lambdaarn --region us-east-1| grep -oP '(?<="SubscriptionArn": ")[^"]*')







