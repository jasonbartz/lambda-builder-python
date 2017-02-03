FROM python:2.7

RUN apt-get update && apt-get install -y zip

RUN pip install awscli

WORKDIR /src

ADD run.sh .

VOLUME /data

CMD ["/src/run.sh"]