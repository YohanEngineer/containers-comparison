FROM amazoncorretto:17

# Set the working directory in the image to /app
WORKDIR /app

# Copy the jar file from your local system into the docker image
COPY target/backend-0.0.1-SNAPSHOT.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
