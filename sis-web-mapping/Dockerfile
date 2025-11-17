FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src ./src
COPY public ./public

# Build arguments for environment variables
ARG API_URL=http://localhost
ARG API_KEY
ARG MAPSERVER_URL=http://localhost/mapserver

# Set as regular environment variables (not prefixed)
ENV API_URL=$API_URL
ENV API_KEY=$API_KEY
ENV MAPSERVER_URL=$MAPSERVER_URL
ENV NODE_ENV=production

# Create .env file for Parcel to read at build time
RUN echo "API_URL=${API_URL}" > .env && \
    echo "API_KEY=${API_KEY}" >> .env && \
    echo "MAPSERVER_URL=${MAPSERVER_URL}" >> .env

# Expose port
EXPOSE 8000

# Start Parcel dev server
CMD ["npm", "start", "--", "--port", "8000", "--host", "0.0.0.0"]