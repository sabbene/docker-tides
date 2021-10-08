FROM perl:latest


RUN apt update && apt -y upgrade && apt -y dist-upgrade && apt -y install nginx

RUN useradd nginx
RUN cpanm Mojo::UserAgent
RUN cpanm JSON
RUN cpanm YAML
RUN cpanm Data::Dump
RUN cpanm IO::Socket::SSL

COPY . /app

EXPOSE 80
EXPOSE 443

CMD /app/start.sh
