FROM node:18.13.0-bullseye-slim AS builder

WORKDIR /app

# Copy everything
COPY . . 

RUN npm install
RUN npm run build

FROM node:18.13.0-alpine

WORKDIR /app

# Create a user and group to run the app
RUN addgroup --gid 1005 somegroup \
    && adduser --uid 1006 --ingroup somegroup --disabled-password --shell /bin/false someuser

# Copy the build folder from the builder image. Needs chown to change the owner of the files
COPY --from=builder --chown=someuser:somegroup /app/build build

# Change which user should run the commands
# Could also just use "node" or "1000" as user since the image includes addgroup and adduser
USER someuser 

# Expose PORT environment variable for react
ENV PORT=8080

CMD ["npx", "--yes", "serve", "build"]