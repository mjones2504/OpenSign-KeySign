FROM node:22

WORKDIR /app

# Copy everything
COPY . .

# Install backend dependencies
WORKDIR /app/apps/OpenSignServer
RUN npm install

# Install and build frontend
WORKDIR /app/apps/OpenSign
RUN npm install
RUN npm run build
RUN echo 'window.RUNTIME_ENV = { REACT_APP_SERVERURL: "https://keysign.usekeys.co/api/app" };' > build/env.js

# Install serve for frontend
RUN npm install -g serve

# Start both frontend and backend
WORKDIR /app
CMD ["sh", "-c", "serve -s apps/OpenSign/build -l 3000 & npm --prefix apps/OpenSignServer start"]
