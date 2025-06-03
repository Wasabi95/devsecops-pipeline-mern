# Using a Node.js base image for the Express backend.
FROM node:18-alpine

# Set the working directory inside the container.
WORKDIR /app

# Copy package.json and package-lock.json (if present) to leverage Docker cache.
# This step installs dependencies first.
COPY package.json package-lock.json ./

# Install project dependencies.
RUN npm install

# Copy the rest of the application source code.
COPY . .

# Expose port 7000, as specified in your server's .env file.
EXPOSE 7000

# Define the command to run the server.
# 'npm start' or 'node server.js' (assuming server.js is your main entry file).
# Ensure your package.json has a "start" script, e.g., "start": "node server.js".
CMD ["node", "server.js"]
