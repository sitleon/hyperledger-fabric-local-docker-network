FROM --platform=linux/amd64 python:3.9-slim

WORKDIR /opt

COPY ./scripts /opt/scripts

RUN chmod +x scripts/bootstrap/upload-creds.sh

RUN pip install awscli

RUN pip install awscli-local