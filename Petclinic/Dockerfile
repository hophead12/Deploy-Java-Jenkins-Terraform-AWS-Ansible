FROM ubuntu:20.04

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install openjdk-17-jre -y

COPY target/* petclinic-app/

WORKDIR petclinic-app

EXPOSE 8080

CMD ["java", "-Dspring.profiles.active=mysql", "-jar","spring-petclinic-3.0.0-SNAPSHOT.jar"]