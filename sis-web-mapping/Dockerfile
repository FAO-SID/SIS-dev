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
ARG API_URL=http://localhost:8000
ARG API_KEY

# Set as regular environment variables (not prefixed)
ENV API_URL=$API_URL
ENV API_KEY=$API_KEY
ENV NODE_ENV=production

# Create .env file for Parcel to read at build time
RUN echo "API_URL=${API_URL}" > .env && \
    echo "API_KEY=${API_KEY}" >> .env

# Expose port
EXPOSE 1234

# Start Parcel dev server
CMD ["npm", "start"]