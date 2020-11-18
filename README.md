Description:

This project configures JENKIN automatically on a Mac Book or Linux Box (you have to configure your storage location / shared storage for docker in a docker)
It auto deploys jenkin with One Project QLedger as an example, and you can access it via http://localhost:8080 on your system (Laptop)

This project is tested on Macintosh with OS X 10.15.7 (19

Pre-Knowledge:

This how to expects you to understand JENKINS, AWS and modifying text files and using GIT particularly GITHUB

Pre-Requisites:

Docker on SYSTEM Your installing on
A Storage folder at /workspace (i'd suggest doing an image and mounting on the folder)
A Free Tier AWS Account

Steps:

Modify the repository to your AWS Settings and change the bucket in qledger.tf


1. Fork the following repository 
https://github.com/davegermiquet/qledgerautodeploy.git

Update the new forked code on your system 
In order for this to work you need to add credentialsId in Jenkins:

AMAZON_CRED

Which contain your ACCESS KEY and SECRET KEY of Amazon Deployment

Fork the following repository https://github.com/davegermiquet/qledgerautodeploy.git

Modify the repository to your AWS Settings and change the bucket in qledger.tf
Update the new forked code on your system

    Add a S3 BUCKET in your AWS account
    Modify the qledger.tf this segment:

backend "s3" { bucket = "nameofbucket" key = "autodeploy" region = "us-east-1" }

Change line in ansible-docker-playbook.yml Add another bucket for your KOPS setup too:

command: kops create cluster  --name qledger --zones us-esat-1a us-west-2a  --state s3://kopsbucketqledger  --yes


The only thing that will cost some much i think in this deployment is route 53 but it should be minimal


All this could be automated due to lack of time, I haevn't been able to but should be easily to clean up.
I think it also can be used as an example of what can be done

 --- END OF EXAMPLE PROEJECT TO SETUP ----
`
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


Troubleshooting:

I noticed that the JENKINS update.jenkins.io has serious problems possibly the mirror to in load, try using another mirror if you can't download the modules
by updating the VARIABLE export JENKINS_DOWNLOAD_MIRROR_TO_USE=http://mirrors.jenkins-ci.org/ to point somewhere else in the script in step 4
I allso noticed problems after 50-60 builds sometimes docker-jenkins would crash.....just erase and reinstall it
IF YOU USE THIS IMAGE PLEASE NOTE THIS JENKINS USE AN OLDER VERSION OF ANSIBLE CAUSIGN ME PROBLEMS DUE TO IT HAS ALOT OF PYTHON2 -> PYTHON3 BUGS
