FROM ubuntu:20.04

RUN apt-get update -y; \
    apt-get install -y xorriso mkisofs openssh-* python;


WORKDIR /opt
COPY ./scripts /opt/scripts

ENV PATH $PATH:/opt/scripts
