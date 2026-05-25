#!/usr/bin/env python3
from flask import Flask, send_from_directory, redirect
import os

app = Flask(__name__, static_folder='web', static_url_path='')

@app.route('/')
def landing():
    return send_from_directory('web', 'landing.html')

@app.route('/app')
def index():
    return send_from_directory('build/web', 'index.html')

@app.route('/download')
def download_apk():
    apk_path = os.path.join(os.path.dirname(__file__), 'web')
    return send_from_directory(apk_path, 'app-release.apk',
                               as_attachment=True,
                               download_name='ExpensePro.apk')

@app.route('/<path:path>')
def static_files(path):
    # Try web/ folder first
    web_file = os.path.join('web', path)
    if os.path.exists(web_file):
        return send_from_directory('web', path)
    # Try build/web/ for Flutter assets
    build_file = os.path.join('build/web', path)
    if os.path.exists(build_file):
        return send_from_directory('build/web', path)
    # Fallback to Flutter app
    return send_from_directory('build/web', 'index.html')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    print(f'ExpensePro server running on port {port}')
    app.run(host='0.0.0.0', port=port)
