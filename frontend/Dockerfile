# Define the base image. Node 14 is chosen here but you can choose another version.
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies in the container
RUN npm install

# Copy the rest of your app's source code to the working directory
COPY . .

# Define the network port that the container will listen on at runtime.
EXPOSE 3000

# Run the application
CMD [ "node", "server.js" ]
