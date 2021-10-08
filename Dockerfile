FROM perl:latest

COPY . /app

RUN apt update && apt -y upgrade && apt -y dist-upgrade

RUN cpanm Mojo::UserAgent
RUN cpanm JSON
RUN cpanm YAML
RUN cpanm Data::Dump

EXPOSE 80
EXPOSE 443

CMD sleep 100
