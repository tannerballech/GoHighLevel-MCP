# Stage 1: Build stage with all dependencies
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install all dependencies (including devDependencies)
COPY package*.json ./
RUN npm ci  # install prod + dev deps

# Copy source code and build
COPY . . 
RUN npm run build  # compile TypeScript to dist/

# Stage 2: Production stage with only prod dependencies
FROM node:18-alpine

WORKDIR /app

# Copy only package.json and package-lock.json to install prod deps
COPY package*.json ./
RUN npm ci --only=production  # install only production deps

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# If you have any other files needed at runtime (like a public folder or static files), copy them as well:
# COPY --from=builder /app/some/other/path ./some/other/path

# Expose the port (Railway will map the PORT env var to this)
EXPOSE 8000

# Set environment to production
ENV NODE_ENV=production

# Start the Express server
CMD ["npm", "start"]
