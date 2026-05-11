#!/usr/bin/env python3
import http.server
import socketserver
import os
from urllib.parse import unquote

class ExpenseTrackerHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=".", **kwargs)
    
    def do_GET(self):
        # Handle root path - serve landing page
        if self.path == '/':
            self.path = '/web/landing.html'
        
        # Handle app path - serve Flutter app
        elif self.path == '/app':
            self.path = '/build/web/index.html'
        
        # Handle Flutter app routes
        elif self.path.startswith('/app/'):
            self.path = '/build/web/' + self.path[5:]
        
        # Handle other static files
        elif self.path.startswith('/web/'):
            # Serve web files directly
            pass
        elif self.path.startswith('/build/web/'):
            # Serve build files directly
            pass
        else:
            # Default to Flutter app for unknown routes
            self.path = '/build/web/index.html'
        
        # Decode the path and check if file exists
        decoded_path = unquote(self.path).lstrip('/')
        if os.path.exists(decoded_path) and os.path.isfile(decoded_path):
            super().do_GET()
        else:
            # If file doesn't exist, serve the Flutter app index
            self.path = '/build/web/index.html'
            if os.path.exists('build/web/index.html'):
                super().do_GET()
            else:
                self.send_error(404, "File not found")
    
    def end_headers(self):
        # Add CORS headers for PWA functionality
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # Add PWA headers
        if self.path.endswith('.html'):
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        elif self.path.endswith(('.js', '.css')):
            self.send_header('Cache-Control', 'public, max-age=31536000')
        
        super().end_headers()

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 8080))
    
    with socketserver.TCPServer(("", port), ExpenseTrackerHandler) as httpd:
        print(f"Expense Tracker PWA Server running on port {port}")
        print(f"Root URL: http://localhost:{port}/")
        print(f"App URL: http://localhost:{port}/app")
        httpd.serve_forever()
