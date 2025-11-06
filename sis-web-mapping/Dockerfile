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
ARG API_URL
ARG API_KEY

# Set environment variables
ENV API_URL=$API_URL
ENV API_KEY=$API_KEY
ENV NODE_ENV=production

# Expose port
EXPOSE 1234

# Start Parcel dev server
CMD ["npm", "start"]