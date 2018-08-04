#!/bin/bash
##########################################################################################################
instanceid=i-0214ec7642a681fc2
region=us-east-1
##########################################################################################################
pythonname=adithya
handler=$pythonname
handler+='.lambda_handler'
pythonname+='.py'
echo "import boto3
def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    objects_to_delete = s3.meta.client.list_objects(Bucket='s3-read-weakly', Prefix='weekly')
    print ('objects_to_delete')
    delete_keys = {'Objects' : []}
    delete_keys['Objects'] = [{'Key' : k} for k in [obj['Key'] for obj in objects_to_delete.get('Contents', [])]]

    s3.meta.client.delete_objects(Bucket='s3-read-weakly, Delete=delete_keys)"> $pythonname

sudo zip file.zip $pythonname
echo Creating deletes3object lambda

aws lambda create-function --function-name adithyadeletes3object --runtime python3.6 \
--role arn:aws:iam::488599217855:role/lambda_s3_access --handler $handler \
 --zip-file fileb://file.zip --timeout 300 --region us-east-1

lambdaarn=$(aws lambda get-function --function-name adithyadeletes3object \
 --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')

echo Creating a new rule, and adding permission to the event to trigger lambda
aws events put-rule --name "adithyaeventweeklydelete" --schedule-expression "cron(40 23 ? * 7 *)" \
  --region us-east-1 #sat 23:40
rulearn=`aws events describe-rule --name adithyaeventweeklydelete --region us-east-1 --query Arn --output text`
aws events put-targets --rule adithyaeventweeklydelete \
 --targets "Id"="1","Arn"="$lambdaarn" --region us-east-1

aws lambda add-permission --function-name adithyadeletes3object --statement-id Yes1 --action "lambda:*" \
--principal events.amazonaws.com --source-arn "$rulearn" --region us-east-1

#######################################################################################################
pythonname=adithya1
handler=$pythonname
handler+='.lambda_handler'
pythonname+='.py'
echo "import boto3
import json
from datetime import date,datetime
import calendar
s3_client = boto3.client('s3')
client = boto3.client('events')
my_date = datetime.utcnow().date()
today = calendar.day_name[my_date.weekday()]
#print(today)
def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    json_file_name = event['Records'][0]['s3']['object']['key']
    #print(bucket)
    #print(json_file_name)
    json_object = s3_client.get_object(Bucket=bucket, Key=json_file_name)
    #print(json_object)
    jsonFileReader = json_object['Body'].read()
    #print(jsonFileReader)
    jsonDict = json.loads(jsonFileReader)
    #print(type(jsonDict))
    today1 = today[0:3]
    cron = jsonDict[today1][0]['startcron']
    cron1 = jsonDict[today1][0]['stopcron']
    #print(cron)
    response = client.put_rule(
        Name='adithyaeventrulestart',
        ScheduleExpression=cron,
        State='ENABLED'
        )
    response1 = client.put_rule(
        Name='adithyaeventrulestop',
        ScheduleExpression=cron1,
        State='ENABLED'
        )
    return 'Hello from Lambda'" > $pythonname
sudo zip file1.zip $pythonname

echo Creating a new lambda for detecting s3objectcreated and adding new rule
aws lambda create-function --function-name adithyas3createtrigger --runtime python3.6 \
--role arn:aws:iam::488599217855:role/lambda_s3_access --handler $handler \
 --zip-file fileb://file1.zip --timeout 300 --region us-east-1

lambdaarn=$(aws lambda get-function --function-name adithyas3createtrigger \
 --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')

aws lambda add-permission --function-name adithyas3createtrigger --statement-id Yes1 \
  --action "lambda:*" --principal s3.amazonaws.com --source-arn "arn:aws:s3:::s3-read-weakly" --region us-east-1

eventconfig=$(cat <<EOF
{
    "LambdaFunctionConfigurations": [
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Prefix", 
                            "Value": "weekly"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "weekly", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        },
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Prefix", 
                            "Value": "Weekly"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "Weekly", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }
    ]
}
EOF
)
eventconfig=`echo $eventconfig | tr -d ' '`
aws s3api put-bucket-notification-configuration --bucket s3-read-weakly --notification-configuration $eventconfig

################################################################################################################

pythonname=adithya2
handler=$pythonname
handler+='.lambda_handler'
pythonname+='.py'
echo "import json
import boto3
import calendar
from datetime import date,datetime,timedelta

def lambda_handler(event, context):
    
    #getting next day
    today = datetime.utcnow().date()
    nextday=today+timedelta(days=1)
    nextday1=nextday.strftime('%A')
    nextday2=nextday1[0:3]
    print(nextday)
    
    #changing rule
    client = boto3.client('s3')
    s3 = boto3.resource('s3')
    bucket = s3.Bucket('s3-read-weakly')
    key = 'weekly.json'
    key1='Weekly.json'
    objs1 = list(bucket.objects.filter(Prefix=key))
    objs = list(bucket.objects.filter(Prefix=key))
    if (len(objs) > 0 and objs[0].key == key) or (len(objs1) > 0 and objs1[0].key == key1):
        json_object = client.get_object(Bucket='s3-read-weakly', Key='weekly.json')
        print(json_object)
        jsonFileReader = json_object['Body'].read()
        print(jsonFileReader)
        jsonDict = json.loads(jsonFileReader)
        #print(type(jsonDict)
        cron=jsonDict[nextday2][0]['startcron']
        cron1=jsonDict[nextday2][0]['stopcron']
        print(cron)
    
        cweclient = boto3.client('events')
    
        response = cweclient.put_rule(
           Name='adithyaeventrulestart',
           ScheduleExpression=cron,
           State='ENABLED'
           )
        response1 = cweclient.put_rule(
           Name='adithyaeventrulestop',
           ScheduleExpression=cron1,
           State='ENABLED'
           )
    else:
    	json_object = client.get_object(Bucket='s3-read-weakly', Key='default.json')
        print(json_object)
        jsonFileReader = json_object['Body'].read()
        print(jsonFileReader)
        jsonDict = json.loads(jsonFileReader)
        #print(type(jsonDict)
        cron=jsonDict[nextday2][0]['startcron']
        cron1=jsonDict[nextday2][0]['stopcron']
        print(cron)
    
        cweclient = boto3.client('events')
    
        response = cweclient.put_rule(
           Name='adithyaeventrulestart',
           ScheduleExpression=cron,
           State='ENABLED'
           )
        response1 = cweclient.put_rule(
           Name='adithyaeventrulestop',
           ScheduleExpression=cron1,
           State='ENABLED'
           )
    
        return 'Hello from Lambda'" > $pythonname

sudo zip file2.zip $pythonname
echo Creating adithyadailyupdatelambda lambda
aws lambda create-function --function-name adithyadailyupdatelambda --runtime python3.6 \
--role arn:aws:iam::488599217855:role/lambda_s3_access --handler $handler\
 --zip-file fileb://file2.zip --timeout 300 --region us-east-1

lambdaarn=$(aws lambda get-function --function-name adithyadailyupdatelambda\
 --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')

echo Creating a new rule, and adding permission to the event to trigger lambda
aws events put-rule --name "adithyadailyupdateevent" --schedule-expression "cron(50 23 ? * 7 *)"\
  --region us-east-1 #sat 23:50
rulearn=`aws events describe-rule --name adithyadailyupdateevent --region us-east-1 --query Arn --output text`
aws events put-targets --rule adithyadailyupdateevent\
 --targets "Id"="1","Arn"="$lambdaarn" --region us-east-1

aws lambda add-permission --function-name adithyadailyupdatelambda --statement-id Yes1 --action "lambda:*" \
--principal events.amazonaws.com --source-arn "$rulearn" --region us-east-1

###################################################################################################################

pythonname=adithya3
handler=$pythonname
handler+='.lambda_handler'
pythonname+='.py'
echo "import boto3

# Enter the region your instances are in. Include only the region without specifying Availability Zone; e.g.; 'us-east-1'
region = '$region'
instances = ['$instanceid']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.start_instances(InstanceIds=instances)
    print ('Started your instance: ' + str(instances))" > $pythonname

sudo zip file3.zip $pythonname
echo Creating adithyastartinstance lambda
aws lambda create-function --function-name adithyastartinstance --runtime python3.6 \
--role arn:aws:iam::488599217855:role/Lambda_EC2_fullaccess --handler $handler\
 --zip-file fileb://file3.zip --timeout 300 --region us-east-1

lambdaarn=$(aws lambda get-function --function-name adithyastartinstance\
 --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')

echo Creating a new rule, and adding permission to the event to trigger lambda
aws events put-rule --name "adithyaeventrulestart" --schedule-expression "cron(0 0 1 1 ? *)"\
  --region us-east-1 
rulearn=`aws events describe-rule --name adithyaeventrulestart --region us-east-1 --query Arn --output text`
aws events put-targets --rule adithyaeventrulestart\
 --targets "Id"="1","Arn"="$lambdaarn" --region us-east-1

aws lambda add-permission --function-name adithyastartinstance --statement-id Yes1 --action "lambda:*" \
--principal events.amazonaws.com --source-arn "$rulearn" --region us-east-1

####################################################################################################################
pythonname=adithya4
handler=$pythonname
handler+='.lambda_handler'
pythonname+='.py'
echo "import boto3

region = '$region'
instances = ['$instanceid']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.stop_instances(InstanceIds=instances)
    print ('Stopped your instance: ' + str(instances))" > $pythonname

sudo zip file4.zip $pythonname
echo Creating adithyastopinstance lambda
aws lambda create-function --function-name adithyastopinstance --runtime python3.6 \
--role arn:aws:iam::488599217855:role/Lambda_EC2_fullaccess --handler $handler\
 --zip-file fileb://file4.zip --timeout 300 --region us-east-1

lambdaarn=$(aws lambda get-function --function-name adithyastopinstance\
 --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')

echo Creating a new rule, and adding permission to the event to trigger lambda
aws events put-rule --name "adithyaeventrulestop" --schedule-expression "cron(0 0 1 1 ? *)"\
  --region us-east-1 
rulearn=`aws events describe-rule --name adithyaeventrulestop --region us-east-1 --query Arn --output text`
aws events put-targets --rule adithyaeventrulestop\
 --targets "Id"="1","Arn"="$lambdaarn" --region us-east-1

aws lambda add-permission --function-name adithyastopinstance --statement-id Yes1 --action "lambda:*" \
--principal events.amazonaws.com --source-arn "$rulearn" --region us-east-1