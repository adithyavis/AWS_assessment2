# AWS_assessment2 
  
**Descriptions:** 

**1.sh:** Achieve automated cross-region replication of contents in an S3 bucket without using the Replication rules. 
 
**2.sh:** Automate the process of setting up passwordless between two AWS EC2 instances. 
 
**3.sh:** Develop a scalable architecture which does the resizing of an image uploaded by an user of an application(ex:facebook; Resized Image to have a maximum dimension of 200px; Original Images are saved in S3; Resized images need to be saved in s3 with prefix "resized_") 
 
**4.sh:** A Company is developing 2 applications which are hosted on AWS. To reduce the EC2 instance charges project owner has decided that development teams should work in specific time intervals and for the rest of the time, EC2 instances should be in STOP state. So to achieve this, the team should give the time intervals for the whole week at the starting of the week and EC2 instances should automatically start and stop accordingly. 
For simplicity assume that there is only 1 time interval per day. Implement a solution to achieve this. 
*/https://github.com/adithyavis/AWS_assessment2/blob/master/Architecture.pdf/*
 
**generatejson.py** To generate a json to configure cloudwatch event rule cronjobs. A lambda function L1 parses the json and updates a cloudwatch event rule E1 accordingly. 
 
 **weekly.json** and **default.json** Weekly.json is updated every week and the necessary changes are then to be reflected in the event rules E1 and E2, which will then trigger a lambda function L2 to create and delete instances respectively. 
  
  **function.zip** Zip file present in a S3 bucket which is to be uploaded to a lambda function 
   
  Disclaimer: Several sources were referred to during the process of developing shell scripts for the above questions. 
