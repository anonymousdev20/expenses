# Multi-stage build for Flutter PWA
FROM cirrusci/flutter:3.19.0 AS builder

WORKDIR /app

# Copy dependency files
COPY pubspec.yaml ./
RUN flutter pub get

# Copy source code
COPY . .

# Create necessary directories
RUN mkdir -p assets/images assets/icons assets/animations web

# Build Flutter web app
RUN flutter build web --release --no-sound-null-safety

# Production stage - use nginx to serve static files
FROM nginx:alpine

# Copy built Flutter app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
RUN echo 'server { listen 80; location / { try_files $uri $uri/ /index.html; } location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { expires 1y; add_header Cache-Control "public, immutable"; } }' > /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
