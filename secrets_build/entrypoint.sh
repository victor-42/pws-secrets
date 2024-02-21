#!/bin/sh

# Start nginx
nginx -g "daemon off;" &

# Start gunicorn
exec gunicorn configuration.wsgi:application --bind 0.0.0.0:8000 --workers 4
