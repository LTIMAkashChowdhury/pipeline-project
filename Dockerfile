
FROM tomcat:8.0
LABEL Owner="TOMCAT"
RUN cd /usr/local/tomcat/webapps && rm -rf *
COPY ROOT.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
