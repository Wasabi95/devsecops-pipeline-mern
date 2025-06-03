# Stage 1: Build the React application
# Using a Node.js base image for building the frontend.
FROM node:18-alpine AS builder

# Set the working directory inside the container.
WORKDIR /app

# Copy package.json and package-lock.json (if present) to leverage Docker cache.
# This step installs dependencies first.
COPY package.json package-lock.json ./

# Install project dependencies.
RUN npm install

# Copy the rest of the application source code.
COPY . .

# Define a build argument for the API base URL.
# This allows the API URL to be set during the Docker build process.
ARG VITE_API_BASE_URL

# Set the environment variable for Vite during the build.
# Vite will pick this up when running `npm run build`.
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Build the React application for production.
# This creates the optimized static files in the 'dist' directory.
RUN npm run build

# Stage 2: Serve the React application with Nginx
# Using a lightweight Nginx image to serve the static files.
FROM nginx:alpine

# Copy the built React application from the 'builder' stage to Nginx's default public directory.
COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]