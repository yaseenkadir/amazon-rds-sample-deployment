FROM openjdk:8-jdk-alpine

COPY ./build/libs/spring-boot2-aws-rds-sample-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 80

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=80", "-jar", "/app.jar"]
