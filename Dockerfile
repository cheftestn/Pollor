# Centos based container with Java and Tomcat                          
FROM centos:centos7                                                   
MAINTAINER V##RU                                                    
                                                                                                          
# Install prepare infrastructure                                                                          
RUN yum -y update && \                                                                                    
        yum -y install wget && \                                                                          
        yum -y install tar                                                                                
                                                                                                          
# Prepare environment 
ENV JAVA_HOME /opt/java
ENV CATALINA_HOME /opt/tomcat 
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin        
                                                                                                            
# Install Oracle Java7                                                                                      
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \  
        http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz && \                 
        tar -xvf jdk-7u79-linux-x64.tar.gz && \                                                             
        rm -rf jdk*.tar.gz && \                                                                                 
        mv jdk* ${JAVA_HOME}


# Install Tomcat
RUN wget http://apache-mirror.rbc.ru/pub/apache/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz && \
	tar -xvf apache-tomcat-7.0.68.tar.gz && \
	rm -rf apache-tomcat*.tar.gz && \
	mv apache-tomcat* ${CATALINA_HOME}  && \
        sed -i '97i JAVA_OPTS="-Xms512m -Xmx1024m -XX:MaxPermSize=256m -Dspring.profiles.active=prod,main,poll  -Duser.timezone=UTC"' ${CATALINA_HOME}/bin/catalina.sh
# Create tomcat user
RUN groupadd -r tomcat && \
	useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
	chown -R tomcat:tomcat ${CATALINA_HOME}
RUN  sed -i '36i  <role rolename="manager-gui"/>'  $CATALINA_HOME/conf/tomcat-users.xml  && \
     sed -i '37i  <user username="tomcat" password="G00Gl#" roles="tomcat,manager-gui"/>'  $CATALINA_HOME/conf/tomcat-users.xml
 
WORKDIR /opt/tomcat
RUN rm -rf /opt/tomcat/webapps/*

ADD ISMaintenance.war $CATALINA_HOME/webapps/ISMaintenance.war

EXPOSE 8080
EXPOSE 8009


CMD ${CATALINA_HOME}/bin/catalina.sh run
