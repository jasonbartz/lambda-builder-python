#!/bin/bash

: ${NAME?"NAME must be set."}
: ${LAMBDA_ROLE?"LAMBDA_ROLE must be set."}
: ${LAMBDA_HANDLER?"LAMBDA_HANDLER must be set."}

pip install -t /lambda -r /data/requirements.txt && cd /lambda && zip -r lambda.zip *
cd /data && zip -r /lambda/lambda.zip *

aws lambda get-function --function-name "${NAME}"
exists=$?
if [ $exists -eq 255 ];then
    echo $exists
    aws lambda create-function \
        --function-name "${NAME}" \
        --runtime python2.7 \
        --role ${LAMBDA_ROLE} \
        --handler ${LAMBDA_HANDLER} \
        --zip-file fileb:///lambda/lambda.zip
else
    aws lambda update-function-code \
        --function-name "${NAME}" \
        --zip-file fileb:///lambda/lambda.zip
fi