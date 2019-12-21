FROM centos:latest

COPY . /app

RUN yum -y update
RUN yum -y install make libcurl-devel gcc  perl cpan
RUN yum -y install epel-release
RUN yum -y install nginx

RUN curl -L http://cpanmin.us | perl - App::cpanminus

RUN cpanm JSON
RUN cpanm YAML
RUN cpanm WWW::Curl::Easy
RUN cpanm Data::Dump

EXPOSE 80
EXPOSE 443

CMD /app/start.sh
