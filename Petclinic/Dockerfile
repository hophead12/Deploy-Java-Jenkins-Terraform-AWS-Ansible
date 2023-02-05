FROM openjdk:17

COPY target/* petclinic-app/

WORKDIR petclinic-app

EXPOSE 8080

CMD ["java", "-Dspring.profiles.active=mysql" "-jar","spring-petclinic-3.0.0-SNAPSHOT.jar"]