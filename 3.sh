#!/bin/bash

#Create the lambda function and giving necessary permission
aws lambda create-function --function-name adithyaresize --runtime python3.6 --role arn:aws:iam::488599217855:role/lambda_s3_access --handler adithyaresize.lambda_handler --code S3Bucket="adithyaresize",S3Key="function.zip" --memory-size 512 --timeout 300 --region us-east-1
lambdaarn=$(aws lambda get-function --function-name adithyaresize --region us-east-1 | grep -oP '(?<="FunctionArn": ")[^"]*')
aws lambda add-permission --function-name adithyaresize --statement-id Yes1 --action "lambda:*" --principal s3.amazonaws.com --source-arn "arn:aws:s3:::adithyaresize" --region us-east-1

#Event notification configuration
#eventconfig=$(cat <<EOF
#{\"LambdaFunctionConfigurations\":[{\"Id\":\"EventHappening\",\"LambdaFunctionArn\":"$lambdaarn",\"Events\":[\"s3:ObjectCreated:*\"]}}]}
#EOF
#)
eventconfig=$(cat <<EOF
{
    "LambdaFunctionConfigurations": [
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".jpg"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "jpgevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }, 
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".jpeg"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "jpegevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }, 
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".png"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "pngevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }, 
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".tiff"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "tiffevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }, 
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".bmp"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "bmpevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }, 
        {
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {
                            "Name": "Suffix", 
                            "Value": ".tif"
                        }
                    ]
                }
            }, 
            "LambdaFunctionArn": "$lambdaarn", 
            "Id": "tifevent", 
            "Events": [
                "s3:ObjectCreated:*"
            ]
        }
    ]
}
EOF
)
eventconfig=`echo $eventconfig | tr -d ' '`

#Create a notification configuration in S3 bucket
aws s3api put-bucket-notification-configuration --bucket adithyaresize --notification-configuration $eventconfig