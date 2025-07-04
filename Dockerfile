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

# ✅ Fix: Include static files for ChatGPT connector
COPY --from=builder /app/public ./public

EXPOSE 8000

ENV NODE_ENV=production

CMD ["npm", "start"]
