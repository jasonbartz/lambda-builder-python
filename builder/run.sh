#!/bin/bash

: ${NAME?"NAME must be set."}
: ${LAMBDA_ROLE?"LAMBDA_ROLE must be set."}
: ${LAMBDA_HANDLER?"LAMBDA_HANDLER must be set."}

pip install --target /lambda -r /data/requirements.txt && cd /lambda && zip -r /data/lambda.zip *
fail=$?
if [ $fail -eq 1 ];then
    exit 1
fi
cd /data && zip -r /data/lambda.zip *

aws lambda get-function --function-name "${NAME}"
exists=$?
if [ $exists -eq 255 ];then
    echo $exists
    aws lambda create-function \
        --function-name "${NAME}" \
        --runtime python2.7 \
        --role ${LAMBDA_ROLE} \
        --handler ${LAMBDA_HANDLER} \
        --zip-file fileb:///data/lambda.zip
else
    aws lambda update-function-code \
        --function-name "${NAME}" \
        --zip-file fileb:///data/lambda.zip
    aws lambda update-function-configuration \
        --function-name "${NAME}" \
        --role ${LAMBDA_ROLE} \
        --handler ${LAMBDA_HANDLER}
fi