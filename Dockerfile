FROM centos:8

COPY . /app

RUN yum -y update
#RUN yum -y install make libcurl-devel gcc  perl cpan
#RUN yum -y install epel-release
#RUN yum -y install nginx
#RUN yum -y install perl-WWW-Curl
#
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
#
#RUN cpanm --verbose --no-interactive JSON
#RUN cpanm --verbose --no-interactive YAML
##RUN cpanm --verbose --no-interactive WWW::Curl::Easy
#RUN cpanm --verbose --no-interactive Data::Dump
#
#EXPOSE 80
#EXPOSE 443
#
#CMD /app/start.sh
CMD sleep 100
