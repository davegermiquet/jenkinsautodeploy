Description:

This project configures JENKIN automatically on a Mac Book or Linux Box (you have to configure your storage location / shared storage for docker in a docker)
It auto deploys jenkin with One Project QLedger as an example, and you can access it via http://localhost:8080 on your system (Laptop)

This project is tested on Macintosh with OS X 10.15.7 (19


Pre-Requisites:

Docker on SYSTEM Your installing on
A Storage folder at /workspace (i'd suggest doing an image and mounting on the folder)
A Free Tier AWS Account

Steps:

Modify the repository to your AWS Settings and change the bucket in qledger.tf


1. Fork the following repository 
https://github.com/davegermiquet/qledgerautodeploy.git

Update the new forked code on your system 

2. Add a S3 BUCKET in your AWS account
3. Modify the qledger.tf this segment:

 backend "s3" {
    bucket = "nameofbucket"
    key    = "autodeploy"
    region = "us-east-1"
}

commit code

4. run from shell ./installUseOfficialJenkins.sh

Modify the QLedger job in jenkins

1. Change the GITHUB location to the one forked
2. add the credentials of your AMAZON_CRED to your credentials of api key on amazon account to jenkins
3. Run the QLedger build



