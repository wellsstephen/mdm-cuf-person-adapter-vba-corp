FROM vet360/tomcat

# Environment Variables used to configure that application
ENV SPRING_PROFILES_ACTIVE=ENV-LOCAL-DEV

ADD target/vet360-address-validation-service-server.war $TOMCAT_HOME/webapps/ROOT.war
