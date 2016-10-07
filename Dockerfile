FROM anapsix/alpine-java:8_server-jre
MAINTAINER vgg

ENV UAA_CONFIG_PATH=/uaa \
    CATALINA_HOME=/tomcat

ADD ./base.tar /tmp
RUN    mv /tmp/run.sh /tmp/run.sh   \
    && mkdir -p /tomcat /uaa        \
    && mv /tmp/dev.yml /uaa/uaa.yml    \
    && chmod +x /tmp/run.sh \
    && tar -xf /tmp/apache-tomcat-8.0.28.tar.gz -C /tomcat \
    && rm /tmp/apache-tomcat-8.0.28.tar.gz \
    && mv /tomcat/apache-tomcat-8.0.28/* /tomcat \
    && rm -fr /tomcat/webapps/*


VOLUME ["/tomcat/webapps/", "/uaa/"]
EXPOSE 8080
CMD ["/tmp/run.sh"]
