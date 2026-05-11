# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for caching
COPY pubspec.yaml pubspec.lock* ./

# Get Flutter dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the Flutter web app
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Serve with Python
FROM python:3.12-slim

WORKDIR /app

# Copy the built Flutter web output
COPY --from=build /app/build/web ./build/web

# Copy the landing page and web assets
COPY web ./web

# Copy the server script
COPY server.py .

# Expose the port
ARG PORT=8080
ENV PORT=$PORT
EXPOSE $PORT

CMD ["python", "server.py"]
