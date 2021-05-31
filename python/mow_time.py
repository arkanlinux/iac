#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler, HTTPServer

from datetime import datetime
from pytz import timezone

zone = 'Europe/Moscow'
mow_time = datetime.now(timezone(zone))
time = str(mow_time)

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()

        message = ("Hello, World! Time is: %s" % time)
        self.wfile.write(bytes(message, "utf8"))

with HTTPServer(('', 8000), handler) as server:
    server.serve_forever()