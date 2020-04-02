FROM maven:3.6.3-jdk-11 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn -e -B dependency:go-offline
COPY src ./src
RUN mvn -e -B clean package

FROM adoptopenjdk:8u242-b08-jre-hotspot
COPY --from=builder /app/target/*.jar /app.jar
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
