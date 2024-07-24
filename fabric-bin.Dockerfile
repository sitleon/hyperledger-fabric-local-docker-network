FROM --platform=linux/amd64 ubuntu:22.10 AS builder

WORKDIR /opt

RUN apt-get -y update && \
    apt-get -y install curl

COPY ./scripts /opt/scripts

RUN chmod +x scripts/bootstrap/fetch-cli-bin.sh

RUN scripts/bootstrap/fetch-cli-bin.sh


FROM --platform=linux/amd64 ubuntu:22.10

WORKDIR /opt

RUN apt-get -y update && \
    apt-get -y install ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get -y update && \
    apt-get -y install docker-ce-cli

COPY ./scripts /opt/scripts

COPY --from=builder /opt/bin /opt/bin

ENV PATH="${PATH}:/opt/bin"