#!/bin/bash

: ${NAME?"NAME must be set."}
: ${LAMBDA_ROLE?"LAMBDA_ROLE must be set."}
: ${LAMBDA_HANDLER?"LAMBDA_HANDLER must be set."}

if [ -e /data/requirements.txt ]; then
    pip install --upgrade --target /lambda -r /data/requirements.txt && cd /lambda && zip -r /data/lambda.zip *
fi
fail=$?
if [ $fail -eq 1 ];then
    exit 1
fi
cd /data && zip -r /data/lambda.zip *

aws lambda get-function --function-name "${NAME}"
exists=$?

CONFIG="--role ${LAMBDA_ROLE} --timeout 300"
CONFIG="$CONFIG --handler ${LAMBDA_HANDLER}"

if [ ! -z ${VPC_CONFIG} ];then
    CONFIG="$CONFIG --vpc-config $VPC_CONFIG"
fi

if [ ! -z "${ENVIRONMENT_VARS}" ];then
    CONFIG="$CONFIG --environment \"Variables={"${ENVIRONMENT_VARS}"\"}"
fi

if [ $exists -eq 255 ];then
    eval aws lambda create-function --function-name ${NAME} --runtime python2.7 --zip-file fileb:///data/lambda.zip ${CONFIG}
else
    aws lambda update-function-code \
        --function-name "${NAME}" \
        --zip-file fileb:///data/lambda.zip
    eval aws lambda update-function-configuration --function-name ${NAME} ${CONFIG}
fi
