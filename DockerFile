# Base image with Node.js
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Install dependencies
RUN npm install

# Build the frontend
RUN npm run build

# Inject runtime environment config
# This creates env.js with your public HOST_URL
RUN echo 'window.RUNTIME_ENV = { REACT_APP_SERVERURL: "https://keys--keysign--46qt8mw4frvn.code.run" };' > build/env.js

# Use a lightweight server to serve static files
FROM node:18-alpine

WORKDIR /app

# Install serve package globally
RUN npm install -g serve

# Copy built files from builder stage
COPY --from=builder /app/build ./build

# Expose port 3000
EXPOSE 3000

# Start the app
CMD ["serve", "-s", "build", "-l", "3000"]
