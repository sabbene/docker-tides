FROM perl:latest

RUN apt-get update && apt-get install -y make gcc libcurl

COPY . /app

RUN cpanm WWW::Curl::Easy
RUN cpanm JSON
RUN cpanm YAML
RUN cpanm Data::Dump

EXPOSE 80
EXPOSE 443

CMD sleep 100
