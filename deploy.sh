#! /bin/bash

SHA1=$1
EB_BUCKET=elasticbeanstalk-us-west-2-circleci

# Deploy image to Docker Hub
docker push apingjian/hello:$SHA1
# docker push circleci/hello:$SHA1

# Create new Elastic Beanstalk version
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-application-version --application-name hello \
    --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE --region us-east-1

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name hello-env --version-label $SHA1 --region us-east-1

