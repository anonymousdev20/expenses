# Optimized multi-stage build for CI with better memory management
FROM ghcr.io/cirruslabs/flutter:stable AS builder

# Increase memory limits and optimize for CI
ENV FLUTTER_WEB_USE_SKIA=true
ENV FLUTTER_WEB_CANVASKIT_URL="/canvaskit"

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Install dependencies with verbose output for debugging
RUN flutter pub get --verbose

# Copy source code
COPY . .

# Create necessary directories
RUN mkdir -p assets/images assets/icons assets/animations web

# Build with optimized flags for CI
RUN flutter build web \
    --release \
    --web-renderer canvaskit \
    --no-tree-shake-icons \
    --verbose

# Production stage - use nginx to serve static files
FROM nginx:alpine

# Copy built Flutter app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
RUN echo 'server { listen $PORT; location / { try_files $uri $uri/ /index.html; } location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { expires 1y; add_header Cache-Control "public, immutable"; } }' > /etc/nginx/conf.d/default.conf.template

# Expose port
EXPOSE 8080

CMD ["sh", "-c", "envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
