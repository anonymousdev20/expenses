# Multi-stage build for Flutter PWA
FROM ghcr.io/cirruslabs/flutter:stable AS builder

# Create non-root user
RUN groupadd --gid 1001 flutter && \
    useradd --uid 1001 --gid 1001 --shell /bin/bash --create-home flutter

WORKDIR /app

# Copy dependency files
COPY pubspec.yaml ./
RUN flutter pub get

# Copy source code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p assets/images assets/icons assets/animations web && \
    chown -R flutter: flutter /app

# Switch to non-root user
USER flutter

# Build Flutter web app
RUN flutter build web --release

# Production stage - use nginx to serve static files
FROM nginx:alpine

# Copy built Flutter app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
RUN echo 'server { listen 80; location / { try_files $uri $uri/ /index.html; } location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { expires 1y; add_header Cache-Control "public, immutable"; } }' > /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
