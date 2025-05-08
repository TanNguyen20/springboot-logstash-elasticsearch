# ---------------------------------------------
# 1) Builder stage: compile with Maven
# ---------------------------------------------
FROM maven:3-openjdk-17 AS builder
WORKDIR /app

# 1.1) Copy only the POM, go offline to pull dependencies
COPY springboot-app/pom.xml /app/pom.xml
RUN mvn dependency:go-offline -B

# 1.2) Copy source and build the fat JAR
COPY springboot-app/src /app/src
RUN mvn package -DskipTests -B

# Debug: confirm the JAR is in /app/target
RUN echo ">>> Builder: /app/target contents" && ls -l /app/target

# ---------------------------------------------
# 2) Runtime stage: slim JRE + your jar
# ---------------------------------------------
FROM eclipse-temurin:17 AS runtime
WORKDIR /app
VOLUME /tmp

# 2.1) Copy built JAR from builder
#    Adjust the wildcard if your final JAR name differs
COPY --from=builder /app/target/*.jar app.jar

# Debug: confirm the JAR landed in /app
RUN echo ">>> Runtime: /app contents" && ls -l /app

# 2.2) Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
