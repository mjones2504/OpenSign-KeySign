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

# Inject runtime config and monkey patch fetch
# Inject runtime config and monkey patch fetch + axios
RUN echo 'window.RUNTIME_ENV = { REACT_APP_SERVERURL: "https://p02--keysign--46qt8mw4frvn.code.run/api/app" };' > build/env.js \
 && echo 'window.fetch = ((orig => (url, opts) => { \
  if (typeof url === "string") { \
    if (url.startsWith("/functions/")) { \
      url = "https://p02--keysign--46qt8mw4frvn.code.run/api/app" + url; \
    } else if (url.startsWith("https://keysign.usekeys.co/api/app/functions/")) { \
      url = url.replace("https://keysign.usekeys.co/api/app", "https://p02--keysign--46qt8mw4frvn.code.run/api/app"); \
    } \
  } \
  return orig(url, opts); \
})(window.fetch));' >> build/env.js \
 && echo 'if (window.axios) { \
  const originalAxios = window.axios; \
  window.axios = function (...args) { \
    if (typeof args[0] === "string") { \
      if (args[0].startsWith("/functions/")) { \
        args[0] = "https://p02--keysign--46qt8mw4frvn.code.run/api/app" + args[0]; \
      } else if (args[0].startsWith("https://keysign.usekeys.co/api/app/functions/")) { \
        args[0] = args[0].replace("https://keysign.usekeys.co/api/app", "https://p02--keysign--46qt8mw4frvn.code.run/api/app"); \
      } \
    } \
    return originalAxios(...args); \
  }; \
}' >> build/env.js

# Install serve for frontend
RUN npm install -g serve

# Start both frontend and backend
WORKDIR /app
CMD ["sh", "-c", "PORT=1337 npm --prefix apps/OpenSignServer start & serve -s apps/OpenSign/build -l 3000"]
